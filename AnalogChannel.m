classdef AnalogChannel < TimingControllerChannel
    %AnalogChannel Defines an analog channel as an extension
    %to the TimingControllerChannel class.
    %
    %At the moment, there is nothing to extend...

    methods
        function ch = AnalogChannel(parent)
            ch = ch@TimingControllerChannel(parent);
            ch.IS_ANALOG = true;
        end
    end




end