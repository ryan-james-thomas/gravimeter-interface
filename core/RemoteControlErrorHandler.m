classdef RemoteControlErrorHandler < handle
    %REMOTECONTROLERRORHANDLER Handles errors in running sequences
    
    properties(SetAccess = protected)
        max_num_errors  %Maximum number of consecutive errors
        log             %Log of errors of size max_num_errors x 1
    end
    
    methods
        function self = RemoteControlErrorHandler(varargin)
            if nargin > 0
                self.setup(varargin{:});
            end
        end
        
        function self = setup(self,max_num_errors)
            self.max_num_errors = max_num_errors;
            self.reset;
        end
        
        function self = reset(self)
            self.log = false(self.max_num_errors,1);
        end
        
        function self = set(self,varargin)
            r = false;
            for nn = 1:numel(varargin)
                r = r || varargin{nn};
            end
            self.log(1:(self.max_num_errors - 1)) = self.log(self.max_num_errors);
            self.log(self.max_num_errors) = r;
        end
        
        function self = add(self,varargin)
            self.set(varargin{:});
        end
        
        function r = is_error(self)
            r = all(self.log) && ~isempty(self.log);
        end
        
        function r = fail(self)
            r = self.is_error;
        end
    end
    
    
end