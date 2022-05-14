function NeededVoltage = DipolePtoV(DipoleType,DesiredPower)

% Powers measured on 26/04/2022
% RedPower has P_max = 20 W
% Keopsys FA has P_max (for Keopsys MO Voltage of 3.9 V) = 12.6 W at FA
% voltage of 3.5 V
% Keopsys MO has P_max (for Keopsys FA Voltage of 0 V) = 0.4 W 
    % (i.e if Amp is off, the seed has a power out of 400 mW)


if ~(strcmpi(DipoleType,'RedPower') || strcmpi(DipoleType,'Keopsys'))
	error('Must be RedPower or Keopsys')
end

if strcmpi(DipoleType,'RedPower')
    if DesiredPower > 20 || DesiredPower < 0
        error('Power cannot be out of range [0,20] W!');
    end
    NeededVoltage = (DesiredPower + 1.5543)/2.8943;
elseif strcmpi(DipoleType,'Keopsys')
    data = [ 0.00000,  0.40000;
             0.25000,  0.40000;
             0.50000,  1.18000;
             0.75000,  2.24000;
             1.00000,  3.23000;
             1.50000,  5.00000;
             2.00000,  5.84000;
             2.50000,  6.39000;
             2.90000,  8.73000;
             2.25000,  5.97000;
             1.25000,  4.16000;
             1.75000,  5.62000;
             2.75000,  7.25000;
             3.00000,  9.72000;
             3.20000,  11.00000;
             3.50000,  12.60000];
    
    if DesiredPower < 0.4
        NeededVoltage = 0;
    elseif DesiredPower > max(data(:,2))
        error('Power must be less than %.3f!',max(data(:,2)));
    else
        NeededVoltage = interp1(data(2:end,2),data(2:end,1),DesiredPower,'pchip');
    end
end


end




