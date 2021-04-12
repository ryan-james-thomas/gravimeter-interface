classdef DDSChannel < TimingControllerChannel
    %DDSChannel Defines a DDS channel as an extension
    %to the TimingControllerChannel class.  DDSChannel objects have values
    %that have 3 sub-values for frequency, normalized power, and phase
    
    properties
        channel
        rfscale
    end
    
    properties(Constant)
        CLK = 1e6;
        DEFAULT_FREQ = 110;
    end
    
    methods
        function ch = DDSChannel
            ch = ch@TimingControllerChannel;
            ch.default = [110,0,0];
            ch.bounds = [80,    0,  0;
                         150,   1,  360];
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
            %   freq, power, and phase, is within the given ranges
            str = {'Frequency','Power','Phase'};
            for nn = 1:size(v,2)
                if any(v(:,nn) < ch.bounds(1,nn)) || any(v(:,nn) > ch.bounds(2,nn))
                    idx = find((v(:,nn) < ch.bounds(1,nn)) | (v(:,nn) > ch.bounds(2,nn)),1,'first');
                    error('%s %f is out of range [%f,%f]',str{nn},v(idx,nn),ch.bounds(1,nn),ch.bounds(2,nn));
                end
            end
        end
        
        function ch = expand(ch,tin)
            ch.sort;
            tin = tin(:);
            fnew = interp1(ch.times,ch.values(:,1),tin,'previous','extrap');
            pownew = interp1(ch.times,ch.values(:,2),tin,'previous','extrap');
            phnew = interp1(ch.times,ch.values(:,3),tin,'previous','extrap');
            ch.times = tin;
            ch.values = [fnew,pownew,phnew];
            ch.numValues = numel(ch.times);
        end
        
        function data = compile(ch,delay)
            if ch.numValues == 0
                data.t = 0;
                data.freq = ch.default(1);
                data.pow = ch.default(2);
                data.phase = ch.default(3);
                return
            end
            t = ch.times - delay;
            idx = (t >= 0);
            t = t(idx);
            v = ch.values(idx,:);
            
            if t(1) ~= 0
                t = [0;t];
                v = [ch.DEFAULT_FREQ,0,0;v];
            end
            data.t = t;
            data.freq = v(:,1);
            data.pow = 30 + 10*log10(ch.opticalToRF(v(:,2),1,ch.rfscale));
            data.phase = v(:,3);
        end

    end
    
    methods(Static)
        function rf = opticalToRF(P,Pmax,rfmax)
            rf = (asin((P/Pmax).^0.25)*2/pi).^2*rfmax;
        end
    end
    
end