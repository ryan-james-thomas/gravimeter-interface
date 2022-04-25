function makeOpticalEvapSequence(sq,varargin)

%
% Define default parameters
%

tOpticalEvap = 2.5;
tOpticalEvapStep = 10e-3;
TimeConstant = 1/2.5;
RedDipoleEnd = 0.75;
KeyDipoleEnd = 1.07;

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
            case 'opticalevaptime'
                tOpticalEvap = v;
            case 'opticalevapstep'
                tOpticalEvapStep = v;
            case 'timeconstant'
                TimeConstant = v;
            case 'reddipoleend'
                RedDipoleEnd = v;
            case 'keydipoleend'
                KeyDipoleEnd = v;
            otherwise
                error('Unsupported option %s',p);
        end
    end
end

%error Check 
if RedDipoleEnd > 5
    error('Redpower Has max of 5 V (i.e. RedDipoleEnd max is 5)')
end
if KeyDipoleEnd > 3.2
    error('Keopsys has a max of 3.2 V (i.e. KeoDipoleEnd max is 3.2')
end

%% Optical Evap Sequence 
%Turn off mag fields
sq.find('CD0 Fast').set(0);
sq.find('CD Fine/Fast').set(0);

% Ramp the dipoles
t = linspace(0,tOpticalEvap,tOpticalEvap/tOpticalEvapStep+1); 
sq.find('Redpower CW').after(t,sq.expramp(t,sq.find('Redpower CW').values(end),RedDipoleEnd,TimeConstant)); 
sq.find('Keopsys FA').after(t,sq.expramp(t,sq.find('Keopsys FA').values(end),KeyDipoleEnd,TimeConstant)); 
sq.delay(tOpticalEvap); %move to end of optical evap

%Compress again
% tOptical = 400e-3;
% t = linspace(0,tOptical,tOptical/20e-3+1);
% sq.find('Redpower CW').after(t,sq.minjerk(t,0.65,1.2));
% sq.find('Keopsys FA').after(t,sq.minjerk(t,1.15,1.3));
% sq.delay(tOptical);
% 
% tOpticalHold= 100e-3; %%100e-3
% sq.find('Redpower CW').set(0);
% sq.delay(tOpticalHold);




end