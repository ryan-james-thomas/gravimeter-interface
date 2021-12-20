classdef GravimeterOptions
    %GRAVIMETEROPTIONS Defines a class for passing options to the
    %gravimeter make sequence function
    
    properties
        %
        % Preparation properties
        %
        detuning
        final_dipole_power
        tof
        imaging_type
        %
        % Raman settings
        %
        raman_width
        raman_power
        raman_df
        %
        % Interferometer properties
        %
        Tint
        t0
        final_phase
        bragg_power
        Tasym
        Tsep
        chirp
        %
        % Other properties
        %
        params
    end
    
    methods
        function self = GravimeterOptions(varargin)
            self = self.set(varargin{:});
        end
        
        function self = set(self,varargin)
            if mod(numel(varargin),2) ~= 0
                error('Arguments must be in name/value pairs');
            else
                for nn = 1:2:numel(varargin)
                    v = varargin{nn+1};
                    switch lower(varargin{nn})
                        case 'detuning'
                            self.detuning = v;
                        case {'dipole','final_dipole_power'}
                            self.final_dipole_power = v;
                        case 'tof'
                            self.tof = v;
                        case {'imaging_type','camera'}
                            self.imaging_type = v;
                        case 'raman_power'
                            self.raman_power = v;
                        case 'raman_width'
                            self.raman_width = v;
                        case 'raman_df'
                            self.raman_df = v;
                        case 't0'
                            self.t0 = v;
                        case {'tint','t'}
                            self.Tint = v;
                        case {'final_phase','phase'}
                            self.final_phase = v;
                        case {'bragg_power','power'}
                            self.bragg_power = v;
                        case {'tasym','asym'}
                            self.Tasym = v;
                        case {'tsep','separation'}
                            self.Tsep = v;
                        case 'chirp'
                            self.chirp = v;
                        case 'params'
                            self.params = v;
                        otherwise
                            warning('Option ''%s'' not supported',varargin{nn})
                    end
                end
            end
        end
        
        function self = replace(self,opt)
            p = properties(opt);
            for nn = 1:numel(p)
                if ~isempty(opt.(p{nn}))
                    self.(p{nn}) = opt.(p{nn});
                end
            end
        end
        
        function s = print(self)
            p = properties(self);
            sargs = {};
            for nn = 1:numel(p)
                v = self.(p{nn});
                if isempty(v)
                    sargs{nn} = sprintf('''%s'',%s',p{nn},'[]');
                elseif ischar(v) || isstring(v)
                    sargs{nn} = sprintf('''%s'',''%s''',p{nn},v);
                else
                    sargs{nn} = sprintf('''%s'',%.6g',p{nn},v);
                end
            end
            s = strjoin(sargs,',');
            s = sprintf('GravimeterOptions(%s);',s);
        end
        
    end
    
end