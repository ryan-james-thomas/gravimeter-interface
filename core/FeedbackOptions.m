classdef FeedbackOptions < SequenceOptionsAbstract
    
    properties
        pulse_amp
        pulse_time
        pulse_delay
        cycle_time

        num_images
        ref_images
    end

    methods
        function self = FeedbackOptions(varargin)
            self.setDefaults;
            self = self.set(varargin{:});
        end

        function self = setDefaults(self)
            self.pulse_amp = 8;
            self.pulse_time = 20e-6;
            self.pulse_delay = 10e-6;
            self.cycle_time = 2e-3;
            self.num_images = 0;
            self.ref_images = 1;
        end
    end
end