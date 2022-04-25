function [NeededVoltage] = MOTPtoV(MOTType,DesiredRelativePower)

if strcmpi(MOTType,'Trapping') == 1 || strcmpi(MOTType,'Repump') == 1 
else
	error('Must be RedPower, KeopsysMO, or KeopsysFA')
end

if DesiredRelativePower > 1
    error('You cannot have power greater than 1')
end


if strcmpi(MOTType,'Trapping') == 1
    Voltage = (0:0.1:6.5);
    Power = 0.0008367*(Voltage.^5) - 0.01658*(Voltage.^4) + 0.1039*(Voltage.^3) - 0.1945*(Voltage.^2) + 0.08989*Voltage + 0.004437;
    NeededVoltage = interp1(Power,Voltage,DesiredRelativePower);
    if NeededVoltage > 8
        NeededVoltage = 8;
    end
	if NeededVoltage < 0
        NeededVoltage = 0;
    end
end


if strcmpi(MOTType,'Repump') == 1
    Voltage = (0:0.1:6.5);
    Power = 0.001864*(Voltage.^5) - 0.0358*(Voltage.^4) + 0.2442*(Voltage.^3) - 0.7133*(Voltage.^2) + 1.088*Voltage - 0.7023;
    NeededVoltage = interp1(Power,Voltage,DesiredRelativePower);
    if NeededVoltage > 8
        NeededVoltage = 8;
    end
	if NeededVoltage < 0
        NeededVoltage = 0;
    end
end


end