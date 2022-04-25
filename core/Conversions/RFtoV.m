function [VoltageNeeded] = RFtoV(DesiredFrequency)

if DesiredFrequency >20 || DesiredFrequency < 0
    error('Frequency Range is 20 to 0 MHz')
end

VoltageNeeded = (DesiredFrequency-10)/2;

end



