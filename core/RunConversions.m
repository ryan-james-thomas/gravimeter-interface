classdef RunConversions < handle
    methods(Static)
        function V = dipole25(power)
            V = (power + 39.3e-3)/2.6165;
        end
        
        function V = dipole50(power)
            V = (power + 66.9e-3)/4.9909;
        end
        
        function V = mot_coil(current)
%             V = (current - 0.3)/6;
%             V(current == 0) = -0.075;
            V = (current - 0.45)/6;
        end
        
        function V = imaging(f)
            V = -f*0.472/6.065 + 8.533;
        end
        
        function V = microwave(f)
            V = 7.9141 - 0.0152*f - 2.555e-5*f.^2 + 3.6751e-7*f.^3;
        end
    end
end