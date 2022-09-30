classdef SequenceOptions < SequenceOptionsAbstract
    %SEQUENCEOPTIONS Defines a class for passing options to the
    %make sequence function
    
    properties
        %
        % Preparation properties. These are native properties to this set
        % of sequence options
        %
        detuning        %Detuning of imaging light
        dipoles         %Final power for the two dipole beams
        tof             %Time-of-flight
        imaging_type    %Imaging system to use (drop 1, 2, 3, or 4)
        params          %Additional parameters for optimisation
        %
        % These are sub-groupings of options
        %
        raman
        bragg
        mw
    end
   
    
    methods
        function self = SequenceOptions(varargin)
            %SEQUENCEOPTIONS Create a SequenceOptions object
            self.raman = RamanSequenceOptions;
            self.bragg = BraggSequenceOptions;
            self.mw = MicrowaveSequenceOptions;
            
            self.setDefaults;
            self = self.set(varargin{:});
        end
        
        function self = setDefaults(self)
            %SETDEFAULTS Set default property values
            self.detuning = 0;
            self.dipoles = 1.35;
            self.tof = 216.5e-3;
            self.imaging_type = 'drop 2';
            self.params = [];
            self.raman.setDefaults;
            self.bragg.setDefaults;
            self.mw.setDefaults;
        end
        
        function self = set(self,varargin)
            %SET Sets the options
            %
            %   SELF = SELF.SET(VARARGIN) Sets properties according to
            %   name/value pairs.  For nested options, use name/value pairs
            %   as 'bragg',{'name',value,'name2',value2,...}
            set@SequenceOptionsAbstract(self,varargin{:});
            
            if mod(numel(varargin),2) ~= 0
                error('Arguments must be in name/value pairs');
            else
                for nn = 1:2:numel(varargin)
                    v = varargin{nn+1};
                    switch lower(varargin{nn})
                        case 'camera'
                            self.imaging_type = v;
                        case 't0'
                            self.bragg.t0 = v;
                        case 'ti'
                            self.bragg.ti = v;
                        case {'tint','t'}
                            self.bragg.T = v;
                        case 'phase'
                            self.bragg.phase = v;
                        case 'power'
                            self.bragg.power = v;
                        case {'tasym','asym'}
                            self.bragg.Tasym = v;
                        case {'tsep','separation'}
                            self.bragg.Tsep = v;
                        case 'chirp'
                            self.bragg.chirp = v;
                    end
                end
            end
        end
        
    end
    
end