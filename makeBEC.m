function sq = makeBEC(varargin)

opt = GravimeterOptions('detuning',0,'dipole',1.35,'tof',216.5e-3,'imaging_type','drop 2',...
        'Tint',1e-3,'t0',[],'ti',[],'final_phase',0,'bragg_power',0.15,'Tasym',0,'Tsep',[],...
        'chirp',25.106258428e6,'raman_width',200e-6,'raman_power',0.285,'raman_df',152e-3,...
        'P25',@(x) (x + 39.3e-3)/2.6165,'P50',@(x) (x + 66.9e-3)/4.9909);

if nargin == 1
    %
    % If first argument is of type GravimeterOptions, use that
    %
    if ~isa(varargin{1},'GravimeterOptions')
        error('If using one argument it must be of type GravimeterOptions');
    end
    opt = opt.replace(varargin{1}); 

elseif mod(nargin,2) ~= 0
    error('Arguments must be in name/value pairs');
else 
    opt = opt.set(varargin{:});
end
%% Initialize sequence - defaults should be handled here
sq = initSequence;
%
% Define useful conversion functions
%
% Dipole trap powers for 25 W (P25) and 50 W (P50) lasers. Gives
% voltage for powers in W
%     P25 = @(x) (x+2.6412)/2.8305;
%     P50 = @(x) (x+3.7580)/5.5445;
P25 = opt.P25;
P50 = opt.P50;
%
% Imaging detuning. Gives voltage for detuning in MHz
%
%     imageVoltage = -varargin{1}*0.4231/6.065 + 8.6214;    %At second drop?
imageVoltage = -opt.detuning*0.472/6.065 + 8.533;
%     imageVoltage = varargin{1};
%
% Voltage value that guarantees that the MOT coils are off
%
motCoilOff = -0.2;

%    U/D bias field converter to amps to volts (possible values are -0.58 A to 14 A) which corresponds to a voltage from (2.823V to -0.14V)
UD = @(x) x* -0.2031 + 2.707; %this converts the input value in amps to the appropriate voltage
% UDreverse = @(y) y*-4.924 + 13.33; %This is just the inverted function to get the amps out of the voltage in case needed.

sq.find('Imaging Freq').set(imageVoltage);
sq.find('3D MOT Freq').set(6.85);
sq.find('50w ttl').set(1);
sq.find('25w ttl').set(1);
sq.find('50w amp').set(P50(15));
sq.find('25w amp').set(P25(12.5)); 

%% Set up the MOT loading values                
sq.find('MOT coil TTL').set(1);     %Turn on the MOT coils
sq.find('3d coils').set(0.38);
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
sq.find('3D coils').set(0.18);
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
sq.find('3D coils').after(t,f(0.15,0.025));

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
sq.find('3D coils').set(2);
sq.find('mw amp ttl').set(1);   %Turn on MW once bias fields have reached their final values
% sq.delay(3.0);

%% Microwave evaporation
sq.delay(20e-3);
evapRate = 0.2;
evapStart = 7.25;
evapEnd = 7.775;
Tevap = (evapEnd-evapStart)/evapRate;
t = linspace(0,Tevap,100);
sq.find('mw freq').after(t,sq.linramp(t,evapStart,evapEnd));
sq.delay(Tevap);

%% Weaken trap while MW frequency fixed
Trampcoils = 180e-3;
t = linspace(0,Trampcoils,50);
sq.find('3d coils').after(t,sq.minjerk(t,sq.find('3d coils').values(end),1));
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
sq.find('3d coils').after(t,sq.linramp(t,sq.find('3d coils').values(end),motCoilOff));
sq.find('mw amp ttl').anchor(sq.find('3d coils').last).before(100e-3,0);
sq.find('mot coil ttl').at(sq.find('3d coils').last,0);
%
% At the same time, start optical evaporation
%
sq.delay(30e-3);
Tevap = 1.97*1.5;
t = linspace(0,Tevap,200);
sq.find('50W amp').after(t,sq.expramp(t,sq.find('50w amp').values(end),P50(opt.final_dipole_power),0.8));
sq.find('25W amp').after(t,sq.expramp(t,sq.find('25w amp').values(end),P25(opt.final_dipole_power),0.8));
sq.find('bias e/w').after(t(1:end/2),@(x) sq.linramp(x,sq.find('bias e/w').values(end),10));
sq.find('bias n/s').after(t(1:end/2),@(x) sq.linramp(x,sq.find('bias n/s').values(end),0));
sq.find('bias u/d').after(t(1:end/2),@(x) sq.linramp(x,sq.find('bias u/d').values(end),0));
sq.delay(Tevap);

end