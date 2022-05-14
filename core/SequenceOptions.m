classdef SequenceOptions < matlab.mixin.Copyable
    %SEQUENCEOPTIONS Defines a class for passing options to the
    %gravimeter make sequence function
    
    properties
        %
        % Preparation properties
        %
        load_time
        detuning
        redpower
        keopsys
        tof
        %
        % Other properties
        %
        params
    end
    
    methods
        function self = SequenceOptions(varargin)
            self.setDefaults;
            self = self.set(varargin{:});
        end

        function self = setDefaults(self)
            self.load_time = 7.5;
            self.detuning = 0;
            self.redpower = 2;
            self.keopsys = 2;
            self.tof = 20e-3;
            self.params = [];
        end
        
        function self = set(self,varargin)
            if mod(numel(varargin),2) ~= 0
                error('Arguments must be in name/value pairs');
            else
                for nn = 1:2:numel(varargin)
                    switch lower(varargin{nn})
                        case 'dipoles'
                            self.keopsys = varargin{nn+1};
                            self.redpower = varargin{nn+1};
                        otherwise
                            self.(varargin{nn}) = varargin{nn+1};
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
                    sargs{nn} = sprintf('''%s'',%s',p{nn},'[]'); %#ok<*AGROW> 
                elseif ischar(v) || isstring(v)
                    sargs{nn} = sprintf('''%s'',''%s''',p{nn},v);
                else
                    sargs{nn} = sprintf('''%s'',%.6g',p{nn},v);
                end
            end
            s = strjoin(sargs,',');
            s = sprintf('SequenceOptions(%s);',s);
        end
        
    end
    
end