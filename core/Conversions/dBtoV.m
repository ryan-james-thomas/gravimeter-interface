function [VoltageNeeded] = dBtoV(CDType,DesiredMagGradient)

% Error Check
if  strcmpi(CDType,'fine') == 0 && strcmpi(CDType,'normal') == 0
    error('Must be "fine" (CD Fine/Fas) or "normal" (CD 0,1,2,3).');
end

%See section 11 of current driver manual: fine driver has 0.16 A/V while the others are 1.6A/V
%See section 4.4.3 In Everitt's Thesis: Coils provide a 8.6 G/Cm/A gradient
%when in anti-helmholtz configuration


%Set Convert from dB to current and then from current to voltage
if strcmpi(CDType,'normal') == 1

%     TotalCurrent = (0:0.08:16);
%     dB = 8.6*TotalCurrent;
%     CurrentNeeded = interp1(dB,TotalCurrent,DesiredMagGradient);
    CurrentNeeded = DesiredMagGradient/8.6;

    if CurrentNeeded > 16
        error('Maximum magnetic gradient achieved with fine control is 137.6 G/cm')
    else
        VoltageNeeded = round(CurrentNeeded/1.6,3);
    end         

elseif strcmpi(CDType,'fine') == 1

%     TotalCurrent = (0:0.008:1.6);
%     dB = 8.6*TotalCurrent;
%     CurrentNeeded = interp1(dB,TotalCurrent,DesiredMagGradient);
    CurrentNeeded = DesiredMagGradient/8.6;
    
    if CurrentNeeded > 1.6
        error('Maximum magnetic gradient achieved with fine control is 13.76 G/cm')
    else
        VoltageNeeded = round(CurrentNeeded/0.16,3);
    end
    
end

end





% %% Using Pat's thesis values, I cannot match Figure 4.12 AND I cannot match the values quoted in section 4.4.3
% % constants
% VacuumPermeability = 1.2566370614e-6;
% % CoilRadius = (37)*1e-3; %radiys that gives value quoted in pat's thesis
% % CoilSeparation = 51e-3;
% AverageCoilRadius = ((96/2 + 50/2)/2)*1e-3;
% AverageCoilSeparation = 51e-3;%((91+51)/2)*1e-3;
% Turns = 120;
%
% % Interpolation range
% TotalCurrent = (0:0.16:17.6);
%
% % Conversion Factors(in Tesla per m & Gauss per cm)
% F1 = (VacuumPermeability*48*AverageCoilSeparation*Turns*AverageCoilRadius^2);
% F2 = ((4*AverageCoilRadius^2 + AverageCoilSeparation^2)^(5/2));
% ConversionFactorSI = F1/F2;
% ConversionFactor = ConversionFactorSI*1e2;
%
% % Voltage to Current (see specifications - section 11 of current driver manual)
% % Current = 1.6*Voltage + CDFast*0.16*Voltage;
%
%
% % % % Intermediate = Current/1.6
% % % % Voltage2 = rem(Current,1.6)/0.16
% % % % Voltage1 = Current/
% % Current to Mag Gradient
% %%%% a_min = 25e-3, a_max = 25e-3 + 23e-3 = 48e-3, a_av = 36.5e-3
% %%%% d_min = 51e-3, d_max = 51e-3 + 40e-3 = 91e-3, d_av = 71e-3
% a = 81.5e-3;
% d = 51e-3;
%
% number1 = (150*10^-4)/(6.4*VacuumPermeability*Turns)
% number2 = ((a^2) / (( ((d^2)/2) + a^2)^(3/2)))

