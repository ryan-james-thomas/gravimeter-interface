classdef TimingControllerChannel < matlab.mixin.Heterogeneous
    %TimingControllerChannel Defines a generic timing
    %controller channel.  This class should be extended
    %before it is used.
    %
    %   The matlab.mixin.Heterogeneous is needed to allow for arrays
    %   of different subclasses of this base class
    properties
        name        %Name of the channel
        description %Description of the channel
        default     %Default value for this channel
        manual      %Manual value
    end
    
    properties(Access = protected)
        parent      %Parent timing controller object
        
        bounds      %Allowed bounds for values
        values      %Array of values in channel sequence.  Only 0 or 1 values are allowed
        times       %Array of times in the channel sequence in seconds
        numValues   %Number of time/value pairs
        
        lastTime    %Last time written - used for before/after functions
    end

    properties(SetAccess = immutable)
        IS_DIGITAL  %Indicates if a channel is a digital channel
        IS_ANALOG   %Indicates if a channel is an analog channel
    end
    
    methods
        function ch = TimingControllerChannel(parent)
            %TimingControllerChannel Contructs a channel
            %   ch = TimingControllerChannel(parent) Contructs a channel
            %   with the given parent
            if nargin >= 1
                if ~isa(parent,'TimingController')
                    error('Parent must be a TimingController object!');
                end
                ch.parent = parent;
            end
            ch.IS_DIGITAL = false;
            ch.IS_ANALOG = false;
            ch.bounds = [0,0];
            ch.default = 0;
            ch.manual = ch.default;
            ch.reset;
        end
        
        function ch = setParent(ch,parent)
            %setParent Sets the parent TimingController
            %
            %   ch = ch.setParent(PARENT) sets the parent to PARENT if
            %   PARENT is a TimingController object.  Returns the channel object
            %   ch
            if ~isa(parent,'TimingController')
                error('Parent must be a TimingController object!');
            end
            ch.parent = parent;
        end
        
        function p = getParent(ch)
            %getParent Returns the parent object
            %
            %   p = ch.getParent Returns the parent object for
            %   TimingControllerChannel object ch
            p = ch.parent;
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
            if ch.numValues==0
                t = 0;
                v = ch.default;
            elseif ch.times(1) == 0
                t = ch.times;
                v = ch.values;
            else
                t = [0;ch.times];
                v = [ch.default;ch.values];
            end
        end
        
        function N = getNumValues(ch)
            %getNumValues Returns the number of time/value pairs
            %
            %   N = ch.getNumValues returns the number of time/value pairs
            %   N
            N = ch.numValues;
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
  
            if numel(time) == numel(value) && numel(time) > 1
                %If TIME and VALUE are Nx1 arrays of the same length, recursively add events
                for nn = 1:numel(time)
                    ch.at(time(nn),value(nn));
                end
            else
                %Otherwise add single events
                ch.checkValue(value);   %Check that value is within bounds

                time = round(time*TimingController.SAMPLE_CLK)/TimingController.SAMPLE_CLK;   %Round time to multiple of sample clock
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
        
        function ch = after(ch,delay,value)
            %AFTER Adds a value to the events after the last added event
            %
            %   ch = ch.after(DELAY,VALUE) adds value to the events a time
            %   DELAY seconds after the property lastTime.  Note that this
            %   is not necessarily the latest time in the sequence.
            
            time = ch.lastTime+delay;
            ch.at(time,value);
        end
        
        function ch = before(ch,delay,value)
            %BEFORE Adds a value to the events before the last added event
            %
            %   ch = ch.before(DELAY,VALUE) adds value to the events a time
            %   DELAY seconds before the property lastTime.  Note that this
            %   is not necessarily the latest time in the sequence.
            
            time = ch.lastTime-delay;
            ch.at(time,value);
        end
        
        function ch = anchor(ch,time)
            %ANCHOR Sets the lastTime property
            %
            %   ch.anchor(TIME) sets the lastTime property to TIME
            
            ch.lastTime = round(time*TimingController.SAMPLE_CLK)/TimingController.SAMPLE_CLK;
        end
        
        function [time,value] = last(ch)
            %LAST Returns the last time and last value
            %
            %   [t,v] = ch.last returns the last time t and last value v
            time = ch.times(end);
            value = ch.values(end);
        end
        
        function ch = reset(ch)
            %RESET Resets the channel sequence so that there are no events
            %   ch = ch.reset resets the channel
            ch.times = [];
            ch.values = [];
            ch.numValues = 0;
            ch.lastTime = [];
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
        end
        
        function ch = checkTimes(ch)
            %CHECKTIMES Checks times to make sure that they are all >= 0
            %
            %   Also checks to see if unique events actually occur, and
            %   removes sequence if nothing happens
            %
            %   ch = ch.check checks the event times and removes sequence
            %   if nothing happens
            if numel(unique(ch.values))==1
                ch.reset;
            end
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

        
        function ch = plot(ch,offset)
            %PLOT Plots the current sequence as a function of time.
            %
            %   ch.plot plots the current sequence as a function of time.
            %   If there are no events, a message is displayed.
            %
            %   ch.plot(OFFSET) plots the current sequence with a vertical 
            %   offset given by OFFSET.  This is useful if you want to plot
            %   multiple signals on the same plot
            [t,v] = ch.getEvents;
            tplot = sort([t;t-1/ch.parent.SAMPLE_CLK]);
            if numel(v)==1
                fprintf(1,'No events on this channel (%d). Plot not generated.\n',ch.bit);
                return
            end
            vplot = interp1(t,v,tplot,'previous');
            if nargin==2
                vplot = vplot+offset;
            end
            plot(tplot,vplot,'.-','linewidth',1.5);
        end
        
    end
    
    
end