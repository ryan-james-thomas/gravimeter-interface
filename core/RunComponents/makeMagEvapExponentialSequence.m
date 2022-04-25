% function makeMagEvapExponentialSequence(sq,varargin)

%
% Define default parameters
%
%RF Evap
tMicrowaveEvap = 4;
tMicrowaveEvapStep = 50e-3;
KnifeStart = 4;
KnifeEnd = -2.667;
TimeConstant = 5;
RampType = 'exp';

%On/Offs 
MagRampOnOff = 0;
FinalRFRamp = 1;

%Mag trap loosening
tMagRamp = 1.5;
tMagRampStep = 10e-3;
MagEnd = 2.04;
MagKnifeEnd = -4.49;


%
% Parse input arguments as name/value pairs
%

if mod(numel(varargin),2) ~= 0
    error('Input arguments must be in name/value pairs');
else
    for nn = 1:2:numel(varargin)
        p = lower(varargin{nn});
        v = varargin{nn+1};
        switch p
            case 'microwaveevaptime'
                tMicrowaveEvap = v;
            case 'microwaveevapstep'
                tMicrowaveEvapStep = v;
            case 'knifestart'
                KnifeStart = v;
            case 'knifeend'
                KnifeEnd = v;
            case 'magramponoff'
                MagRampOnOff = v;
            case 'finalrframp'
                FinalRFRamp = v;
            case 'timeconstant'
                TimeConstant = v;
            case 'magramptime'
                tMagRamp = v;
            case 'magrampstep'
                tMagRampStep = v;
            case 'magend'
                MagEnd = v;
            case 'magknifeend'
                MagKnifeEnd = v;
            case 'ramptype'
                RampType = v;
            otherwise
                error('Unsupported option %s',p);
        end
    end
end

% error check

if MagRampOnOff == 1 || MagRampOnOff == 0

else
    error('Dipoles must be on (1) or off (0)');
end

if FinalRFRamp == 1 || FinalRFRamp == 0

else
    error('RF ramp must end (1) or stay on (0)');
end

%% Mag Evap Sequence

sq.find('RF atten').set(1); %turn off the rf attenuation
% t = linspace(0,tMicrowaveEvap,tMicrowaveEvap/tMicrowaveEvapStep+1);
t = linspace(0,tMicrowaveEvap,100);
if strcmpi(RampType,'exp')
    sq.find('RF frequency').after(t,sq.expramp(t,KnifeStart,KnifeEnd,TimeConstant)); %ramp rf frequency from 4 to -2.667
elseif strcmpi(RampType,'lin')
    sq.find('RF frequency').after(t,sq.linramp(t,KnifeStart,KnifeEnd));
end
sq.delay(tMicrowaveEvap);

if MagRampOnOff == 1
    t = linspace(0,tMagRamp,tMagRamp/tMagRampStep+1);
    sq.find('CD0 Fast').after(t,sq.linramp(t,sq.find('CD0 Fast').values(end),MagEnd));
    sq.find('RF frequency').after(t,sq.linramp(t,sq.find('RF frequency').values(end),MagKnifeEnd));
    sq.delay(tMagRamp);
end

if FinalRFRamp == 1
    sq.find('RF atten').set(0); %turn off rf
    sq.find('RF frequency').set(5); %move rf freq back away from resonance
end



end