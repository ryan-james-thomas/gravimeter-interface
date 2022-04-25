function [PowerOut] = DipoleFractionalPtoP(DipoleType,PowerFraction)

% Powers measured on 15/02/2022
% RedPower has P_max = 13 W
% Keopsys FA has P_max (for Keopsys MO Voltage of 3.9 V) = 10.8W
% Keopsys MO has P_max (for Keopsys FA Voltage of 0 V) = 0.4 W 
    % (i.e if Amp is off, the seed has a power out of 400 mW)


if strcmpi(DipoleType,'RedPower') == 1 || strcmpi(DipoleType,'KeopsysMO') == 1 || strcmpi(DipoleType,'KeopsysFA') == 1
else
	error('Must be RedPower, KeopsysMO, or KeopsysFA')
end

if PowerFraction > 1
    error('You cannot have power greater than 1')
end

if strcmpi(DipoleType,'RedPower') == 1
    PowerOut = 13*PowerFraction;
end

if strcmpi(DipoleType,'KeopsysFA') == 1
    PowerOut = 10.8*PowerFraction;
end



end




