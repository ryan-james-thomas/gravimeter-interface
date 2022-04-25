function [out] = AmpToV(LightType,Frequency)


%Interpolation Range
Voltage = (0:0.05:8);

if  strcmpi(LightType,'trap') == 0 && strcmpi(LightType,'repump') == 0  && strcmpi(LightType,'image') == 0 
    error('Must be trap, repump or image');    
elseif strcmpi(LightType,'trap') == 1
    TrappingFrequnecy = 0.0008*Voltage.^5 - 0.0166*Voltage.^4 +0.1039*Voltage.^3 - 0.1945*Voltage.^2 + 0.0899.*Voltage+0.0044;
    out = interp1(TrappingFrequnecy,Voltage,-Frequency);
elseif strcmpi(LightType,'repump') == 1 
    RepumpFrequency = 2*(51.919+8.5694*(Voltage)-1.5263*(Voltage.^2)+.24217*(Voltage.^3)-.010947*Voltage.^4) -211.79;
    out = interp1(RepumpFrequency,Voltage,-Frequency);
elseif strcmpi(LightType,'image') == 1
    ImagingFrequency = 0.5168+16.0185*(Voltage-8.386)-0.112*(Voltage-8.386).^2;
    out = interp1(ImagingFrequency,Voltage,-Frequency);
end



% have I sat found 
% see foot pdf page 157.

end
