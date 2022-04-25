function [NeededVoltage] = DipolePtoV(DipoleType,DesiredRelativePower)

% Powers measured on 15/02/2022
% RedPower has P_max = 13 W
% Keopsys FA has P_max (for Keopsys MO Voltage of 3.9 V) = 10.8W
% Keopsys MO has P_max (for Keopsys FA Voltage of 0 V) = 0.4 W 
    % (i.e if Amp is off, the seed has a power out of 400 mW)


if strcmpi(DipoleType,'RedPower') == 1 || strcmpi(DipoleType,'KeopsysMO') == 1 || strcmpi(DipoleType,'KeopsysFA') == 1
else
	error('Must be RedPower, KeopsysMO, or KeopsysFA')
end

if DesiredRelativePower > 1
    error('You cannot have power greater than 1')
end

if strcmpi(DipoleType,'RedPower') == 1
    NeededVoltage = (DesiredRelativePower + 0.1255)/0.2249;
    if NeededVoltage > 5
        NeededVoltage = 5;
    end
end

if strcmpi(DipoleType,'KeopsysMO') == 1
    NeededVoltage = (DesiredRelativePower + 0.4974)/0.3835;
    if NeededVoltage > 3.9
        NeededVoltage = 3.9;
    end
end

if strcmpi(DipoleType,'KeopsysFA') == 1
    Voltage = (0:0.01:3);
    Power = 0.0256281813328552*(Voltage.^5) - 0.0839296270976739*(Voltage.^4) - 0.107959995604612*(Voltage.^3) + 0.51437944281788*(Voltage.^2) - 0.0556330111734857*Voltage + 0.0352680508741484;      
    NeededVoltage = interp1(Power,Voltage,DesiredRelativePower);
    if NeededVoltage > 3
        NeededVoltage = 3;
    end
end

end




