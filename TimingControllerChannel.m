classdef TimingControllerChannel < handle & matlab.mixin.Heterogeneous
    %TimingControllerChannel Defines a generic timing
    %controller channel.  This class should be extended
    %before it is used.
    %
    %   The matlab.mixin.Heterogeneous is needed to allow for arrays
    %   of different subclasses of this base class
    properties
        name        %Name of the channel
        port        %Fixed port of the channel
        description %Description of the channel
        
        manual      %Manual value
    end
    
    properties(SetAccess = protected)
        default     %Default value for this channel
        
        values      %Array of values in channel sequence.  Only 0 or 1 values are allowed
        times       %Array of times in the channel sequence in seconds
        numValues   %Number of time/value pairs
        
        lastTime    %Last time written - used for before/after functions
        
        bounds      %Allowed bounds for values
        IS_DIGITAL  %Indicates if a channel is a digital channel
        IS_ANALOG   %Indicates if a channel is an analog channel
    end
    
    methods
        function ch = TimingControllerChannel
            %TimingControllerChannel Contructs a channel

            ch.IS_DIGITAL = false;
            ch.IS_ANALOG = false;
            ch.bounds = [0,0];
            ch.setDefault(0);
            ch.manual = ch.default;
            ch.reset;
            ch.numValues = 0;
            ch.lastTime = 0;
        end
        
        function ch = setName(ch,name,port,description)
            %SETNAME Sets the name and optionally the description
            %
            %   ch = setName(ch,NAME,PORT) sets the name property to NAME and
            %   port property to PORT
            %
            %   ch = setName(ch,NAME,PORT,DESC) sets the name property to NAME
            %   and the description property to DESC
            ch.name = name;
            ch.port = port;
            if nargin == 4
                ch.description = description;
            end
        end

        function ch = setDefault(ch,v)
            %SETDEFAULT Sets the default value
            %
            %   ch = setDefault(ch,v) sets the default value of channel ch
            %   to v
            ch.checkValue(v);
            ch.default = v;
            if numel(ch.times) == 0
                ch.times = 0;
                ch.values = ch.default;
            else
                idx = find(ch.times == 0);
                if isempty(idx)
                    ch.times(end+1) = 0;
                    ch.values(end+1) = ch.default;
                    lt = ch.lastTime;
                    ch.sort;
                    ch.lastTime = lt;
                else
                    ch.values(idx) = ch.default;
                end
            end
            ch.numValues = numel(ch.times);
        end
        
        function [t,v] = getEvents(ch)
            %getEvents Returns the times and values as separate Nx1 arrays.
            % 
            %   Events are checked for errors and sorted before being
            %   returned.
            %   [t,v] = ch.getEvents returns times t and values v
            %   Events are always returned starting at time 0 - if no 
            %   value at time 0 is specified, the default value is used
            ch.check;
            ch.sort;
            if isempty(ch.numValues) || (ch.numValues == 0)
                t = 0;
                v = ch.default;
            elseif ch.times(1) == 0
                t = ch.times;
                v = ch.values;
            else
                t = [0;ch.times];
                v = [ch.default;ch.values];
            end
%             ch.numValues = numel(t);
        end
        
        function r = exists(ch)
            %EXISTS Indicates if channel sequence is more than just the
            %default value
            
            r = ~(numel(ch.times) == 1 && ch.times(1) == 0);
        end

        function ch = setBounds(ch,bounds)
            %SETBOUNDS Sets the bounds for channel
            %
            %   CH = setBounds(CH,BOUNDS) Sets the bounds to the 2-element
            %   array BOUNDS.  BOUNDS can be in any order
            ch.bounds(1) = min(bounds);
            ch.bounds(2) = max(bounds);
        end
        
        function ch = at(ch,time,value)
            %AT Adds a value at the given time
            %
            %   ch = ch.at(TIME,VALUE) adds VALUE to the events at the time 
            %   given by TIME.  Assumes that TIME and VALUE are scalars.  TIME must 
            %   be in seconds.  Sets the lastTime property to TIME
            %
            %   CH = CH.at(TIME,VALUE) if TIME and VALUE are Nx1 arrays adds each element
            %   in VALUE to events at time given by corresponding element in VALUE.
            %   This uses a recursive call to AT, so may run into memory issues
            %
            %   CH = CH.at(TIME,VALUEFUNC) if TIME is an Nx1 array and VALUEFUNC is a function
            %   handle, adds the calculated values VALUEFUNC(TIME) to events.  Uses recursive
            %   calls, so may run into memory issues


            if numel(ch) > 1
                %If an array of channels is passed, loop through each individually
                for nn = 1:numel(ch)
                    ch(nn).at(time,value);
                end
            elseif ~isa(value,'function_handle') && (numel(time) == numel(value)) && (numel(time) > 1)
                %If TIME and VALUE are Nx1 arrays of the same length, recursively add events
                for nn = 1:numel(time)
                    ch.at(time(nn),value(nn));
                end
            elseif isa(value,'function_handle') && (numel(time) > 1)
                %If TIME is an array and VALUE is a function handle, loop through each time and calculate a value
                for nn = 1:numel(time)
                    ch.at(time(nn),value(time(nn)));
                end
            else
                %Otherwise add single events
                ch.checkValue(value);   %Check that value is within bounds

                time = round(time*TimingSequence.SAMPLE_CLK)/TimingSequence.SAMPLE_CLK;   %Round time to multiple of sample clock
                idx = find(ch.times==time,1,'first');   %Try and find first time
                if isempty(idx)
                    %If this time has not been used previously, add a new value at this time
                    N = ch.numValues+1;
                    ch.values(N,1) = value;
                    ch.times(N,1) = time;
                    ch.numValues = N;
                    ch.lastTime = time;
                else
                    %If time has been used, replace that value
                    ch.values(idx,1) = value;
                    ch.times(idx,1) = time;
                    ch.lastTime = time;
                end
            end
        end
        
        function ch = on(ch,varargin)
            %ON Alias of AT method
            ch.at(varargin{:});
        end
        
        function ch = set(ch,value)
            %SET Sets a value at the current lastTime
            %
            %   ch = set(ch,value) sets the current value to be value at time
            %   lastTime
            if numel(ch) > 1
                for nn = 1:numel(ch)
                    ch(nn).at(ch(nn).lastTime,value);
                end
            else
                ch.at(ch.lastTime,value);
            end
        end
        
        function ch = after(ch,delay,value)
            %AFTER Adds a value to the events after the last added event
            %
            %   ch = ch.after(DELAY,VALUE) adds value to the events a time
            %   DELAY seconds after the property lastTime.  Note that this
            %   is not necessarily the latest time in the sequence.
            
            if numel(ch) > 1
                for nn = 1:numel(ch)
                    ch(nn).after(delay,value);
                end
            else
                time = ch.lastTime+delay;
                ch.at(time,value);
            end
        end
        
        function ch = before(ch,delay,value)
            %BEFORE Adds a value to the events before the last added event
            %
            %   ch = ch.before(DELAY,VALUE) adds value to the events a time
            %   DELAY seconds before the property lastTime.  Note that this
            %   is not necessarily the latest time in the sequence.
            
            if numel(ch) > 1
                for nn = 1:numel(ch)
                    ch(nn).before(delay,value);
                end
            else
                time = ch.lastTime-delay;
                ch.at(time,value);
            end
        end
        
        function ch = anchor(ch,time)
            %ANCHOR Sets the lastTime property
            %
            %   ch.anchor(TIME) sets the lastTime property to TIME
            
            if numel(ch) > 1
                for nn = 1:numel(ch)
                    ch(nn).anchor(time);
                end
            else
                ch.lastTime = round(time*TimingSequence.SAMPLE_CLK)/TimingSequence.SAMPLE_CLK;
            end
        end
        
        function [time,value] = last(ch)
            %LAST Returns the last time and last value
            %
            %   [t,v] = ch.last returns the last time t and last value v
            [t,v] = ch.getEvents;
            time = t(end);
            value = v(end);
        end
        
        function ch = reset(ch)
            %RESET Resets the channel sequence so that there are no events
            %   ch = ch.reset resets the channel
            ch.times = [];
            ch.values = [];
            ch.setDefault(ch.default);
            ch.sort;
        end
        
        function ch = sort(ch)
            %SORT Sorts the events so that they are ordered chronologically
            %
            %   ch = ch.sort sorts the events.  The lastTime property is
            %   set to the last time in the sorted events
            if numel(ch.times)>0
                [B,K] = sort(ch.times);
                ch.times = B;
                ch.values = ch.values(K);
                ch.lastTime = ch.times(end);
            end
            ch.numValues = numel(ch.times);
        end
        
        function ch = checkTimes(ch)
            %CHECKTIMES Checks times to make sure that they are all >= 0
            %
            %   Also checks to see if unique events actually occur, and
            %   removes sequence if nothing happens
            %
            %   ch = ch.check checks the event times and removes sequence
            %   if nothing happens
%             if numel(unique(ch.values))==0
%                 ch.reset;
%             end
            if any(ch.times<0)
                error('All times must be greater than 0 (no acausal events)!');
            end
        end

        function ch = checkValue(ch,v)
            %CHECKVALUE Checks a given value to make sure it is in a valid range
            %
            %   CH = CHECKVALUE(CH,V) checks value v to make sure it is within 
            %   a valid range
            if v < ch.bounds(1) || v > ch.bounds(2)
                error('Value %.3f is outside of bounds [%.3f,%.3f]',v,ch.bounds);
            end
        end

        function ch = check(ch)
            %CHECK Checks events to ensure correct times and values are given
            %
            %   CH = CHECK(CH) Checks events to make sure times are positive and that unique times
            %   are given.  Also checks that values are within bounds
            ch.checkTimes();
            for nn = 1:numel(ch.values)
                ch.checkValue(ch.values(nn));
            end
        end

        function ch = reduce(ch)
            %REDUCE Reduces channel events to only those which change the value

            ch.sort;
            [t,v] = ch.getEvents;
            ch.times = t(1);ch.values = v(1);
            idx = 2;
            for nn = 2:numel(v)
                if v(nn) ~= v(nn-1)
                    ch.times(idx,1) = t(nn);
                    ch.values(idx,1) = v(nn);
                    idx = idx + 1;
                end
            end
            ch.sort;
        end

        
        function ch = plot(ch,offset,finalTime)
            %PLOT Plots the current sequence as a function of time.
            %
            %   ch.plot plots the current sequence as a function of time.
            %   If there are no events, a message is displayed.
            %
            %   ch.plot(OFFSET) plots the current sequence with a vertical 
            %   offset given by OFFSET.  This is useful if you want to plot
            %   multiple signals on the same plot
            %
            %   ch.plot(OFFSET,FINALTIME) plots the current sequence with
            %   OFFSET and extends plot to FINALTIME
            [t,v] = ch.getEvents;
            if ~ch.exists
                return
            end
            
            if nargin >= 3 && t(end) ~= finalTime
                t = [t;finalTime];
                v = [v;v(end)];
            end
            tplot = sort([t;t-1/TimingSequence.SAMPLE_CLK]);
            vplot = interp1(t,v,tplot,'previous');
            if nargin >= 2
                vplot = vplot+offset;
            end
            if ~ch.IS_DIGITAL
                plot(tplot,vplot,'.-','linewidth',1.5);
            else
                plot(tplot,vplot,'.--','linewidth',1.5);
            end
        end
        
    end
    
    
end