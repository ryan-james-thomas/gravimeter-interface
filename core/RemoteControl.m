classdef RemoteControl < handle
    properties
        %% TCPIP properties
        conn            %TCPIP connection
        connected       %Is LabVIEW client connected?
        %% Sequence properties
        status          %Current status of run: RUNNING or STOPPED
        sq              %Sequence object representing current sequence
        makerCallback   %Callback function for creating a TimingSequence object
        %% Data properties
        mode            %Mode of callback function: SET, ANALYZE, or INIT
        devices         %Structure listing MATLAB devices used in callback
        data            %Data structure to use in callback function
        callback        %Callback function, takes argument of Rebeka object
        %% DDS properties
        mog             %MOGLabs parent object
    end
    
    properties(SetAccess = protected)
        remoteAddress = 'localhost';  %Connect to local host
        remotePort = 6666;            %Remote port to use
        waitTime = 0.1;               %Wait time for querying BytesAvailable and between successive writes

    end %end constant properties
    
    properties(SetAccess = immutable)
        c               %Rollover counter object, keeps track of runs
    end
    
    properties(Constant, Hidden=true)
        readyWord = 'ready';          %Word indicating that client is ready
        startWord = 'start';          %Word telling host to start
        endWord = 'end';              %Word telling host to stop TCP loop
        uploadDWord = 'uploadD';      %Word telling host to upload digital (uint32) data
        uploadAWord = 'uploadA';      %Word telling host to upload analog (float) data

        SET = 'set/check';
        ANALYZE = 'analyze';
        INIT = 'init';
        
        RUNNING = 'running';
        STOPPED = 'stopped';
    end    
    
    events
        sequenceChanged
    end
    
    methods
        function self = RemoteControl(varargin)
            self.setRemoteProperties(varargin{:});
            self.connected = false;
            self.mode = self.INIT;
            self.status = self.STOPPED;
            self.makerCallback = @SequenceBuilder;
            self.c = RolloverCounter();
            self.reset;
        end %end constructor
        
        function self = setRemoteProperties(self,varargin)
            if numel(varargin) >= 1
                self.remoteAddress = varargin{1};
            end
            if numel(varargin) >= 2
                self.remotePort = varargin{2};
            end
        end
        
        function open(self)
            %OPEN Opens a tcpip port           
            %open Creates and opens a TCP conn.  Waits for ready word
            self.conn = instrfindall('type','tcpip','RemotePort',self.remotePort,'RemoteHost',self.remoteAddress,...
                'Terminator','CR/LF');
            if isempty(self.conn) || ~isvalid(self.conn)
                self.conn = tcpip(self.remoteAddress,self.remotePort,'networkrole','client');
                self.conn.Terminator = 'CR/LF';
                self.conn.BytesAvailableFcn = @(src,event) self.resp(src,event);
                self.connected = false;
                self.conn.OutputBufferSize = 2^24;
            end
            
            if strcmpi(self.conn.Status,'closed')
                fprintf(1,'Attempting connection...\n');
                fopen(self.conn);
                fprintf(1,'Connection successful!\n');
                self.connected = true;
            end
        end %end open
        
        function setFunc(self)
            %SETFUNC Sets the BytesAvailableFcn to self.resp()
            self.open;
            self.conn.BytesAvailableFcn = @(src,event) self.resp(src,event);
        end
        
        function instr = findTCPPort(self)
            %FINDTCPPORT Finds all existing TCP ports
            instr = instrfindall('type','tcpip','RemotePort',self.remotePort,'RemoteHost',self.remoteAddress);      
        end
        
        function r = read(self)
            %READ Reads available data from TCP connection
            r = fgetl(self.conn);
        end %end read
        
        function r = waitForReady(self)
            %WAITFOREADY Returns true when the readyWord appears
            while self.conn.BytesAvailable <= length(self.readyWord)
                pause(self.waitTime); 
            end
            r = strcmpi(self.read,self.readyWord);
        end %end waitForReady
        
        function stop(self)
            %STOP Releases client from remote control and closes TCP conn
            if ~isempty(self.conn) && isvalid(self.conn) && strcmpi(self.conn.Status,'open')
%                 fprintf(self.conn,'%s',self.endWord);
                fclose(self.conn);
            end
            delete(self.conn);
            fprintf(1,'Remote control session terminated\n');
            self.connected = false;
            self.status = self.STOPPED;
        end
        
        function delete(self)
            %DELETE Deletes this object
            %
            %   Closes then deletes the tcpip connection with the LabVIEW
            %   interface before deleting the object
            self.stop;
        end

        function self = make(self,varargin)
            %MAKE Makes the sequence to be uploaded
            %
            %   r = make(r,varargin) runs r.sq = r.makerCallback(varargin{:})
            %   If r.makerCallback is empty, then uses default makeSequence() function
            if isempty(self.makerCallback) || ~isa(self.makerCallback,'function_handle')
                self.makerCallback = @makeSequence;
            end
            self.sq = self.makerCallback(varargin{:});
            notify(self,'sequenceChanged');
        end
        
        function self = upload(self,data)
            %UPLOAD uploads data to host
            %
            %   r = upload(r) uploads data to control interface using the 
            %   current sequence stored in the r.sq field
            %
            %   r = upload(r,data) with r the RemoteControl object and data a
            %   2D array with times in the first column, a 32 bit digital
            %   value in the second column, and 24 analog values in the rest
            if nargin < 2
                data = self.sq.compile;
            end

            if isnumeric(data)
                if size(data,2) ~= 26
                    error('Numeric input array must have 26 columns!');
                end
                d = uint32(round(data(:,2)));
                a = data(:,[1,3:end]);
            elseif isstruct(data)
                d = uint32(data.d);
                a = [data.t,data.a];
                if size(d,1) ~= size(a,1)
                    error('Analog and digital columns must have the same size!');
                elseif size(data.a) ~= 24
                    error('Data ''a'' field must have 24 columns');
                end
            end
            
            %% Upload DDS data
            self.uploadDDSData(data.dds);
            
            %% Upload R&S synthesizer list data if present
            if isfield(self.devices,'rs') && isfield(self.devices.rs,'list') && ~isempty(self.devices.rs.list.freq)
                self.devices.rs.writeList;
            end
            
            %% Open connection with LabVIEW VI
            self.open;
            
            %% Upload analog data
            fprintf(self.conn,'%s\n',self.uploadAWord);
            s = sprintf(['%.6f',repmat(',%.6f',1,24),'%%'],a');
            pause(0.1);
            fprintf(self.conn,s);
            
            %% Upload digital data
            fprintf(self.conn,'%s\n',self.uploadDWord);
            s = sprintf('%d,%%',d);
            s = s(1:end-2);
            pause(0.1);
            fprintf(self.conn,s);

        end
        
        function uploadDDSData(self,dds)
            if isempty(self.mog)
                return
            end
            
            if isempty(self.mog.cx)
                error('Connect to MOGLabs ARF box first!');
            end
            % Create mogtable objects
            tb = mogtable(self.mog,1);
            tb(2) = mogtable(self.mog,2);
            
            % Put data into mogtable objects
            for nn = 1:numel(tb)
                tb(nn).t = dds(nn).t;
                tb(nn).freq = dds(nn).freq;
                tb(nn).pow = dds(nn).pow;
                tb(nn).phase = dds(nn).phase;
            end
            
            % Reduce instruction sizes and make sure both tables have
            % instructions at the same time
            tb(1).reduce;
            if sum(tb(1).sync) == 1
                tb(2).reduce;
                tb(1).reduce(tb(2).sync);
            else
                tb(2).reduce(tb(1).sync);
            end
            
            % Send commands to device
            for nn = 1:numel(tb)
                self.mog.cmd('mode,%d,%s',tb(nn).channel,tb(nn).MODE);
                self.mog.cmd('table,stop,%d',tb(nn).channel);
            end
            self.mog.cmd('table,sync,1');
            numInstr = tb.upload;
            estUploadTime = numInstr*11/3280;
            if estUploadTime > (7/8*self.sq.ddsTrigDelay)
                pause(estUploadTime - self.sq.ddsTrigDelay + 1);
            end
        end
        
        function run(self)
            %RUN Starts a single client run by sending the start word
            self.open;
            fprintf(self.conn,'%s\n',self.startWord);
        end %end run
        
        function start(self)
            %START Starts a full run through the sequence of numRuns
            self.status = self.RUNNING;
            self.init;
            self.set;
            self.run;
        end
        
        function resume(self)
            %RESUME sets and runs a sequence
            self.status = self.RUNNING;
            self.set;
            self.run;
        end
        
        function resp(self,~,~)
            %RESP responds to the arrival a new word over TCPIP
            %   Controls the next run of the sequence, either ending it or
            %   analyzing the results and stepping forward
            s = self.read;
            if ~self.connected && strcmpi(s,self.readyWord)
                fprintf(1,'Interface connected!\n');
                self.connected = true;
                self.status = self.STOPPED;
            elseif strcmpi(s,self.readyWord) && strcmpi(self.status,self.RUNNING)
                if self.c.done()
                    % Analyze
                    self.analyze;
                    % Stop
                    self.stop;
                else
                    % Analyze
                    self.analyze;
                    % Run again
                    self.c.increment();
                    self.set;
                    self.run;
                end
            end
        end
        
        function self = init(self)
            %SET Sets the mode to INIT and calls the callback function if
            %currentRun is 1
            self.setFunc;
            if self.c.current() == 1
                self.mode = self.INIT;
                self.callback(self);
            end
        end
        
        function self = set(self)
            %SET Sets the mode to SET and calls the callback function
            self.mode = self.SET;
            self.callback(self);
        end
        
        function self = analyze(self)
            %ANALYZE Sets the mode to ANALYZE and calls the callback
            %function
            self.mode = self.ANALYZE;
            self.callback(self);
        end
        
        function r = isInit(self)
            %ISSET Returns true if the mode is INIT
            r = strcmpi(self.mode,self.INIT);
        end
        
        function r = isSet(self)
            %ISSET Returns true if the mode is SET
            r = strcmpi(self.mode,self.SET);
        end
        
        function r = isAnalyze(self)
            %ISANALYZE Returns true if the mode is ANALYZE
            r = strcmpi(self.mode,self.ANALYZE);
        end
        
        function reset(self)
            %RESET Resets currentRun to 1, data to [], mode to INIT
            self.c.reset;
            self.data = [];
            self.mode = self.INIT;
        end
        
    end %end methods

end %end classdef