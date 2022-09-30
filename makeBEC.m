function sq = makeBEC(varargin)

opt = SequenceOptions;

if nargin == 1
    %
    % If first argument is of type GravimeterOptions, use that
    %
    if ~isa(varargin{1},'SequenceOptions')
        error('If using one argument it must be of type SequenceOptions');
    end
    opt = opt.replace(varargin{1}); 
elseif mod(nargin,2) == 0
    opt.set(varargin{:});
elseif mod(nargin - 1,2) == 0 && isa(varargin{1},'SequenceOptions')
    opt = opt.replace(varargin{1});
    opt.set(varargin{2:end});    
else 
    error('You must supply either a SequenceOptions object, a set of name/value pairs for options, or a SequenceOptions object followed by name/value pairs');
end

%% Create a conversion object to handle conversions to volts
convert = RunConversions;

%% Initialize sequence - defaults should be handled here
sq = initSequence;

%    U/D bias field converter to amps to volts (possible values are -0.58 A to 14 A) which corresponds to a voltage from (2.823V to -0.14V)
UD = @(x) x* -0.2031 + 2.707; %this converts the input value in amps to the appropriate voltage
% UDreverse = @(y) y*-4.924 + 13.33; %This is just the inverted function to get the amps out of the voltage in case needed.

sq.find('Imaging Freq').set(convert.imaging(opt.detuning));
sq.find('3D MOT Freq').set(6.85);
sq.find('50w ttl').set(1);
sq.find('25w ttl').set(1);
sq.find('50w amp').set(convert.dipole50(15));
sq.find('25w amp').set(convert.dipole25(12.5)); 

%% Set up the MOT loading values                
sq.find('MOT coil TTL').set(1);     %Turn on the MOT coils
sq.find('3d coils').set(convert.mot_coil(2.58));
sq.find('bias u/d').set(-0.02);
sq.find('bias e/w').set(0);
sq.find('bias n/s').set(10*0);

Tmot = 4;                           %6 s MOT loading time
sq.delay(Tmot);                     %Wait for Tmot
%% Compressed MOT stage
%Turn off the 2D MOT and push beam 10 ms before the CMOT stage
sq.find('2D MOT Amp TTL').before(10e-3,0);
sq.find('push amp ttl').before(10e-3,0);

%Increase the cooling and repump detunings to reduce re-radiation
%pressure, and weaken the trap
sq.find('3D MOT freq').set(6);
sq.find('repump freq').set(2.7);
sq.find('3D coils').set(convert.mot_coil(1.38));
sq.find('bias e/w').set(5);
sq.find('bias n/s').set(7);
sq.find('bias u/d').set(1.75);

Tcmot = 10e-3;                      %10 ms CMOT stage
sq.delay(Tcmot);                    %Wait for time Tcmot
%% PGC stage
Tpgc = 15e-3;
%Define a function giving a 100 point smoothly varying curve
t = linspace(0,Tpgc,50);
f = @(vi,vf) sq.minjerk(t,vi,vf);

%Smooth ramps for these parameters
sq.find('3D MOT Amp').after(t,f(5,3.8));
sq.find('3D MOT Freq').after(t,f(sq.find('3D MOT Freq').values(end),3.5));
sq.find('3D coils').after(t,convert.mot_coil(f(1.2,0.45)));

sq.delay(Tpgc);
%Turn off the repump field for optical pumping - 1 ms
T = 1e-3;
sq.find('repump amp ttl').set(0);
sq.find('liquid crystal repump').set(7);
sq.find('bias u/d').set(-0.1);
sq.find('bias e/w').set(0);
sq.find('bias n/s').set(7.5);
sq.delay(T);

%% Load into magnetic trap
sq.find('liquid crystal bragg').set(-3);
sq.find('3D mot amp ttl').set(0);
sq.find('MOT coil ttl').set(1);
sq.find('3D coils').set(convert.mot_coil(12.3));
sq.find('mw amp ttl').set(1);   %Turn on MW once bias fields have reached their final values
% sq.delay(3.0);

%% Microwave evaporation
%
% Provide detunings in MHz from the Rb hyperfine splitting
%
sq.delay(20e-3);
evapRate = 0.2;
evapStart = convert.microwave(42.5);
evapEnd = convert.microwave(9.03);
Tevap = (evapEnd-evapStart)/evapRate;
t = linspace(0,Tevap,100);
sq.find('mw freq').after(t,sq.linramp(t,evapStart,evapEnd));
sq.delay(Tevap);

%% Weaken trap while MW frequency fixed
Trampcoils = 180e-3;
t = linspace(0,Trampcoils,50);
sq.find('3d coils').after(t,sq.minjerk(t,sq.find('3d coils').values(end),convert.mot_coil(1)));
sq.find('bias e/w').after(t,sq.minjerk(t,sq.find('bias e/w').values(end),0));
sq.find('bias n/s').after(t,sq.minjerk(t,sq.find('bias n/s').values(end),0));
sq.find('bias u/d').after(t,sq.minjerk(t,sq.find('bias u/d').values(end),-0.12));
sq.delay(Trampcoils);

%% Optical evaporation
%
% Ramp down magnetic trap in 1.01 s
%
Trampcoils = 1.01;
t = linspace(0,Trampcoils,100);
sq.find('3d coils').after(t,sq.linramp(t,sq.find('3d coils').values(end),convert.mot_coil(0)));
sq.find('mw amp ttl').anchor(sq.find('3d coils').last).before(100e-3,0);
sq.find('mot coil ttl').at(sq.find('3d coils').last,0);
%
% At the same time, start optical evaporation
%
sq.delay(30e-3);
Tevap = 1.97*1.5;
t = linspace(0,Tevap,200);
sq.find('50W amp').after(t,sq.expramp(t,sq.find('50w amp').values(end),convert.dipole50(opt.dipoles),0.8));
sq.find('25W amp').after(t,sq.expramp(t,sq.find('25w amp').values(end),convert.dipole25(opt.dipoles),0.8));
% sq.find('bias e/w').after(t(1:end/2),@(x) sq.linramp(x,sq.find('bias e/w').values(end),opt.params(1) - opt.params(2)/2));
sq.find('bias e/w').after(t(1:end/2),@(x) sq.linramp(x,sq.find('bias e/w').values(end),10));
sq.find('bias n/s').after(t(1:end/2),@(x) sq.linramp(x,sq.find('bias n/s').values(end),0));
sq.find('bias u/d').after(t(1:end/2),@(x) sq.linramp(x,sq.find('bias u/d').values(end),0));
sq.delay(Tevap);

end