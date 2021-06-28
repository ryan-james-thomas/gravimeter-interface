classdef RolloverCounter < handle
    properties
        N
        maxRuns
        total
        
        initial
        final
        idx
    end
    
    methods
        function self = RolloverCounter(final,initial)
            if nargin == 1
                initial = ones(size(final));
            end
            
            if numel(initial) ~= numel(final)
                error('Initial and final indices must have the same number of elements!');
            end
            
            self.N = numel(initial);
            self.initial = initial(:)';
            self.final = final(:)';
            self.reset;
        end
        
        function self = reset(self)
            self.idx = self.initial;
            self.maxRuns = self.final - self.initial + 1;
            self.total = prod(self.maxRuns);
        end
        
        function c = current(self)
            c = 1;
            for nn = 1:self.N
                c = c + (self.idx(nn)-1)*prod(self.maxRuns((nn-1):-1:1));
            end
        end
        
        function self = increment(self)
            for nn = 1:self.N
                if nn == 1
                    self.idx(nn) = self.idx(nn) + 1;
                end
                
                if self.idx(nn) > self.final(nn)
                    self.idx(nn) = self.initial(nn);
                    if nn < self.N
                        self.idx(nn+1) = self.idx(nn+1) + 1;
                    end
                end
                    
            end
        end
        
        function varargout = print(self)
            s = '';
            for nn = 1:self.N
                s = [s,sprintf('%d/%d',self.idx(nn),self.maxRuns)]; %#ok<*AGROW>
                if nn ~= self.N
                    s = [s,' '];
                end
            end
            if nargout == 0
                fprintf(1,'%s\n',s);
            else
                varargout{1} = s;
            end
        end
    end
    
    
end