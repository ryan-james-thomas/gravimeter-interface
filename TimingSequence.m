classdef TimingSequence < handle
    %TimingSequence Defines a sequence of output values
    %based on the events in each channel

    properties
        channels        %Array of TimingControllerChannel objects
    end

    properties(SetAccess = immutable)
        numDigitalChannels
        numAnalogChannels
        numChannels
    end

    properties(SetAccess = protected)
        compiledData
    end

    properties(Constant)
        SAMPLE_CLK = 1e6;
        MAX_INSTRUCTIONS = 1024;
    end


    methods
        function self = TimingSequence(numDigitalChannels,numAnalogChannels)
            %TimingSequence Constructs a TimingSequence object
            %
            %   seq = TimingSequence(numDigitalChannels,numAnalogChannels)
            %   constructs a TimingSequence object with numDigitalChannels 
            %   digital channels and numAnalogChannels analog channels

            self.numDigitalChannels = numDigitalChannels;
            self.numAnalogChannels = numAnalogChannels;
            self.numChannels = self.numDigitalChannels + self.numAnalogChannels;
            tmp(self.numChannels) = TimingControllerChannel;
            self.channels = tmp;
            for nn = 1:self.numDigitalChannels
                self.channels(nn) = DigitalChannel(nn-1);
            end

            for nn = (self.numDigitalChannels+1):self.numChannels
                self.channels(nn) = AnalogChannel;
            end
        end


        function self = reset(self)
            %RESET Resets the TimingSequence channels to their default state
            
            for nn = 1:self.numChannels
                self.channels(nn).reset;
            end
        end

        function ch = find(self,name)
            %FIND Finds a channel with the same name as NAME
            %
            %   ch = self.find(NAME) finds channel ch with name NAME
            ch = [];
            for nn = 1:self.numChannels
                if strcmpi(self.channels(nn).name,name)
                    ch = self.channels(nn);
                    break;
                end
            end
        end

        function self = compile(self)
            %COMPILE Compiles the channel sequences
            %
            %   self = self.compile creates a set of values for each 
            %   unique time

            %Forms two arrays - one is Nx1 of times, and one is NxNUM_CHANNELS and is values
            t = [];
            v = [];
            for nn = 1:self.numChannels
                self.channels(nn).check.sort;
                [t2,v2] = self.channels(nn).getEvents;
                t = [t;t2];   %#ok
                vtmp = NaN(numel(v2),self.numChannels);
                vtmp(:,nn) = v2;
                v = [v;vtmp];   %#ok
            end

            %Now we need to create a smaller list of times and values which correspond
            %to unique updates
            [t,k] = sort(round(t*self.SAMPLE_CLK));
            v = v(k,:);
            buf = NaN(size(t,1),1+self.numChannels);    %One column for time, one for all other channels
            buf(1,:) = [t(1),v(1,:)];
            numBuf = 1;
            for nn = 2:numel(t)
                if t(nn) ~= t(nn-1)
                    numBuf = numBuf + 1;
                    buf(numBuf,1) = t(nn);
                end
                idx = find(~isnan(v(nn,:)));
                buf(numBuf,1+idx) = v(nn,idx);
            end
            buf = buf(1:numBuf,:);
            
            %Replace NaNs with previous values
            for nn = 2:size(buf,1)
                tmpOld = buf(nn-1,2:end);
                tmpCurrent = buf(nn,2:end);
                tmpCurrent(isnan(tmpCurrent)) = tmpOld(isnan(tmpCurrent));
                buf(nn,2:end) = tmpCurrent;
            end
            %One column for time, one for all digital channels, and one for each analog channel
            bits = zeros(1,self.numDigitalChannels);
            for nn = 1:numel(bits)
                bits(nn) = self.channels(nn).bit;
            end
            data = [buf(:,1),sum(buf(:,1+(1:self.numDigitalChannels)).*repmat(2.^bits,size(buf,1),1),2),buf(:,1+(self.numDigitalChannels+1):self.numChannels)];
            if size(data,1) > self.MAX_INSTRUCTIONS
                error('Instruction set size of %d is larger than maximum size of %d!',size(data,1),self.MAX_INSTRUCTIONS);
            end
            data(:,1) = data(:,1)/self.SAMPLE_CLK;
            self.compiledData = data;
        end

        function plot(self,offset)
            %PLOT Plots all channel sequences
            %
            %   tc.plot plots all channel sequences on the same graph
            %
            %   tc.plot(offset) plots all channel sequences on the
            %   same graph but with each channel's sequence offset from the
            %   next by offset
            jj = 1;
            if nargin < 2
                offset = 0;
            end
            str = {};
            for nn = 1:self.numChannels
                self.channels(nn).plot((jj-1)*offset);
                hold on;
                if self.channels(nn).getNumValues > 0
                    if isempty(self.channels(nn).name)
                        str{jj} = sprintf('Ch %d',nn);  %#ok<AGROW>
                    else
                        str{jj} = sprintf('%s',self.channels(nn).name); %#ok<AGROW>
                    end
                    jj = jj+1;
                end
            end
            hold off;
            legend(str);
            xlabel('Time [s]');
        end

    end


end