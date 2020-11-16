classdef DigitalChannel < TimingControllerChannel
    %DigitalChannel Defines a digital channel as an extension
    %to the TimingControllerChannel class.  Adds the BIT property
    %and fixes the bounds to 0 and 1

    properties(Access = protected)
        bit     %Bit number [0,31] indicating which output port this is associated with
    end

    methods
        function ch = DigitalChannel(parent,bit)
            ch = ch@TimingControllerChannel(parent);
            ch.bit = bit;
            ch.bounds = [0,1];
        end

        function ch = checkValue(ch,v)
            %CHECKVALUE Checks a given value to make sure it is either 0 or 1
            %
            %   CH = CHECKVALUE(CH,V) checks value v to make sure it is 0 or 1
            if v ~= ch.bounds(1) || v ~= ch.bounds(2)
                error('Value %.3f is neither 0 nor 1!',v);
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


    end


end