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
        
        function data = compile(ch,delay)
            t = ch.times - delay;
            idx = (t >= 0);
            t = [0;t(idx)];
            v = [ch.values(1,:);ch.values(idx,:)];
            if any(t < 0)
                error('Trigger delay cannot be later than first DDS time!');
            end
            dt = [0;round(diff(t)*ch.CLK)];
%             dt(end+1) = 10;
            N = numel(dt);
            if N > 8191
                error('Maximum number of table entries is 8191');
            end
            
            for nn = 1:N
                data(nn).dt = dt(nn); %#ok<*AGROW>
                data(nn).freq = v(nn,1);
                data(nn).amp = v(nn,2);
                data(nn).phase = v(nn,3);
            end
        end
        
        
    end
    
end