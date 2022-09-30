classdef SequenceOptionsAbstract < matlab.mixin.Copyable
    %SEQUENCEOPTIONS Defines an abstract class for handling sequence
    %options.  The actual sequence options should be a subclass of this.
    
    
    methods(Abstract)
        self = setDefaults(self)
    end

    methods       
        function self = set(self,varargin)
            if mod(numel(varargin),2) ~= 0
                error('Arguments must be in name/value pairs');
            else
                for nn = 1:2:numel(varargin)
                    if isa(self.(varargin{nn}),'SequenceOptionsAbstract')
                        self.(varargin{nn}).set(varargin{nn+1}{:});
                    else
                        self.(varargin{nn}) = varargin{nn+1};
                    end
                end
            end
        end

        function self = replace(self,opt)
            p = properties(opt);
            for nn = 1:numel(p)
                if isa(self.(p{nn}),'SequenceOptionsAbstract')
                    self.(p{nn}).replace(opt.(p{nn}));
                else
                    if ~isempty(opt.(p{nn}))
                        self.(p{nn}) = opt.(p{nn});
                    end
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
            s = sprintf('%s(%s);',class(self),s);
        end
        
    end
    
end