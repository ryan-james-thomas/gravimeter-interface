function [out] = FtoV(LightType,Frequency)
% Interpolation range
Voltage = (0:0.05:10);

% Voltage to Frequency Functions
TrappingFrequnecy = 2*(53.051+8.6164*(Voltage)-1.5183*((Voltage).^2)+.24203*((Voltage).^3)-.010976*Voltage.^4)-211.79;
% RepumpFrequency = 2*(51.919+8.5694*(Voltage)-1.5263*(Voltage.^2)+.24217*(Voltage.^3)-.010947*Voltage.^4) -211.79;
RepumpFrequency = 55.1531 + 5.514*Voltage - 0.3122*Voltage.^2 + 0.048*Voltage.^3 - 156.947/2;
ImagingFrequency = 0.5168+16.0185*(Voltage-8.386)-0.112*(Voltage-8.386).^2;

%use input string, the input desired frequency and the above functions to get the required voltage
if  strcmpi(LightType,'trap') == 0 && strcmpi(LightType,'repump') == 0  && strcmpi(LightType,'image') == 0
    error('Must be trap, repump or image');
elseif strcmpi(LightType,'trap') == 1
    out = interp1(TrappingFrequnecy,Voltage,-Frequency);
elseif strcmpi(LightType,'repump') == 1
    out = interp1(RepumpFrequency,Voltage,-Frequency);
elseif strcmpi(LightType,'image') == 1
%     out = interp1(ImagingFrequency,Voltage,-Frequency);
    out = Frequency*0.5473/6 + 8.498;
end

%Check if frequency is possible 
if isnan(out)
    error('Voltage is greater than 10 V or less than 0V. Frequency range is -27.5 to 105.5 MHz');
end

end