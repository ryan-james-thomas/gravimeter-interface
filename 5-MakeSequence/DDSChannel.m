classdef DDSChannel < TimingControllerChannel
    %DDSChannel Defines a DDS channel as an extension
    %to the TimingControllerChannel class.  DDSChannel objects have values
    %that have 3 sub-values for frequency, amplitude, and phase
    
    properties
        channel
        
    end
    
    properties(Constant)
        CLK = 1e6;
    end
    
    methods
        function ch = DDSChannel
            ch = ch@TimingControllerChannel;
            ch.default = [110,0,0];
            ch.bounds = [80,0,0;150,2^16-1,360];
            ch.IS_DDS = true;
        end
        
        function ch = setDefault(ch,v)
            if numel(v) == 1 && v == 0
                v = [110,0,0];
            end
            ch = setDefault@TimingControllerChannel(ch,v);
        end
        
        function ch = checkValue(ch,v)
            %CHECKVALUE Checks a given value, given as freq, amp, and
            %phase, is within the given ranges
            %
            %   CH = CHECKVALUE(CH,V) checks a given value V, given as
            %   freq, amp, and phase, is within the given ranges
            str = {'Frequency','Amplitude','Phase'};
            for nn = 1:numel(v)
                if v(nn) < ch.bounds(1,nn) || v(nn) > ch.bounds(2,nn)
                    error('%s %f is out of range [%f,%f]',str{nn},v(nn),ch.bounds(1,nn),ch.bounds(2,nn));
                end
            end
        end
        
        function ch = expand(ch,tin)
            ch.sort;
            tin = tin(:);
            fnew = interp1(ch.times,ch.values(:,1),tin,'previous','extrap');
            ampnew = interp1(ch.times,ch.values(:,2),tin,'previous','extrap');
            phnew = interp1(ch.times,ch.values(:,3),tin,'previous','extrap');
            ch.times = tin;
            ch.values = [fnew,ampnew,phnew];
            ch.numValues = numel(ch.times);
        end
        
        function data = compile(ch,delay)
            if ch.numValues == 0
                data.dt = 1;
                data.freq = ch.default(1);
                data.amp = ch.default(2);
                data.phase = ch.default(3);
                return
            end
            t = ch.times - delay;
            idx = (t >= 0);
            t = t(idx);
            v = ch.values(idx,:);
            if any(t < 0)
                error('Trigger delay cannot be later than first DDS time!');
            end
            dt = [round(diff(t)*ch.CLK);10];
%             delay = round(delay*ch.CLK);
%             if dt(1) < delay
%                 error('Instructions for the DDS cannot change before the DDS trigger!');
%             end
%             dt(1) = dt(1) - delay;
%             v = ch.values;
            N = numel(dt);
            if N > 8191
                error('Maximum number of table entries is 8191');
            end
            
            data.dt = dt;
            data.freq = v(:,1);
            data.amp = max(round(v(:,2)),0);
            data.phase = v(:,3);
            
%             for nn = 1:N
%                 data(nn).dt = dt(nn); %#ok<*AGROW>
%                 data(nn).freq = v(nn,1);
%                 data(nn).amp = v(nn,2);
%                 data(nn).phase = v(nn,3);
%             end
        end
        
        
    end
    
end