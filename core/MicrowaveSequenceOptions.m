classdef MicrowaveSequenceOptions < SequenceOptionsAbstract
    
    properties
        enable
        analyze
        enable_sg
    end

    methods
        function self = MicrowaveSequenceOptions(varargin)
            self.setDefaults;
            self = self.set(varargin{:});
        end

        function self = setDefaults(self)
            self.enable = [0,0];
            self.analyze = [0,0];
            self.enable_sg = 0;
        end
    end
end