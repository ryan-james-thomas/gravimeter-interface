classdef BraggSequenceOptions < SequenceOptionsAbstract
    
    properties
        t0
        ti
        T
        Tasym
        Tsep
        phase
        power
        chirp
        width
    end

    methods
        function self = BraggSequenceOptions(varargin)
            self.setDefaults;
            self = self.set(varargin{:});
        end

        function self = setDefaults(self)
            self.t0 = [];
            self.ti = [];
            self.T = 20e-3;
            self.Tsep = [];
            self.Tasym = 0;
            self.phase = 0;
            self.power = 0;
            self.chirp = 25.106258428e6;
            self.width = 30e-6;
        end
    end
end