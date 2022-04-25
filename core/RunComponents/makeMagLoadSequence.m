function makeMagLoadSequence(sq,varargin)

%
% Define default parameters
%
DipoleOnOff = 0;

%Mag Ramp Values
MagRampTime = 100e-3;
MagRampTimeSteps = 2e-3;
MagStart = 4;
MagEnd = 8;
MagFineStart = 0;
MagFineEnd = 0;

%Dipole Ramp Values
DipoleRampTime = 100e-3;
DipoleRampTimeSteps = 2e-3;
RedDipoleEnd = 5;
KeoDipoleEnd = 3.2;
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
            case 'magramptime'
                MagRampTime = v;
            case 'magramptimesteps'
                MagRampTimeSteps = v;
            case 'magstart'
                MagStart = v;
            case 'magend'
                MagEnd = v;
            case 'magfinestart'
                MagFineStart = v;
            case 'magfineend'
                MagFineEnd = v;                
            case 'dipoleonoff'
                DipoleOnOff = v;
            case 'dipoleramptime'
                DipoleRampTime = v;
            case 'dipoleramptimesteps'
                DipoleRampTimeSteps = v;
            case 'reddipoleend'
                RedDipoleEnd = v;
            case 'keodipoleend'
                KeoDipoleEnd = v;
            otherwise
                error('Unsupported option %s',p);
        end
    end
end

% error check

if DipoleOnOff == 1 || DipoleOnOff == 0

else
    error('Dipoles must be on (1) or off (0)');
end

if RedDipoleEnd > 5
    error('RedPower Cannot go above 5V, i.e. RedDipoleEnd cannot be above 5')
end

if KeoDipoleEnd > 3.2
    error('Keopsys has a max of 3.2 V (i.e. KeoDipoleEnd max is 3.2')
end



%% Mag Load Sequence
if DipoleOnOff == 0
    %Add current with CD0
    t = linspace(0,MagRampTime,MagRampTime/MagRampTimeSteps+1);
    sq.find('CD0 Fast').after(t,sq.minjerk(t,MagStart,MagEnd));
    sq.delay(MagRampTime);
    
    %Add current with CD0 Fine/Fast (fine tuning the gradient)
    sq.find('CD Fine/Fast').after(t,sq.minjerk(t,MagFineStart,MagFineEnd));
    sq.delay(MagRampTime);  
elseif DipoleOnOff == 1

    % % Mag Ramp
    %Add current with CD0
    t = linspace(0,MagRampTime,MagRampTime/MagRampTimeSteps+1);
    sq.find('CD0 Fast').after(t,sq.minjerk(t,MagStart,MagEnd));
    sq.delay(MagRampTime);
    
    %Add current with CD0 Fine/Fast (fine tuning the gradient)
    sq.find('CD Fine/Fast').after(t,sq.minjerk(t,MagFineStart,MagFineEnd));
    sq.delay(MagRampTime);  

    % % Dipole Ramp
    t = linspace(0,DipoleRampTime,DipoleRampTime/DipoleRampTimeSteps+1);
    sq.find('Keopsys MO').set(3.9);                             
    sq.find('Redpower TTL').set(1);                            
    sq.find('Keopsys FA').after(t,sq.minjerk(t,0,KeoDipoleEnd));       
    sq.find('Redpower CW').after(t,sq.minjerk(t,0,RedDipoleEnd));

end






end