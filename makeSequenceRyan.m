function varargout = makeSequenceRyan(varargin)   
%% Parse input arguments
opt = SequenceOptions('load_time',15,'detuning',0,'tof',20e-3,'redpower',2,...
    'keopsys',2);

if nargin == 1
    if ~isa(varargin{1},'SequenceOptions')
        error('If using only one argument it must of type SequenceOptions');
    end
    opt.replace(varargin{1});
elseif mod(nargin,2) == 0
    opt.set(varargin{:});
elseif mod(nargin - 1,2) == 0 && isa(varargin{1},'SequenceOptions')
    opt.replace(varargin{1});
    opt.set(varargin{2:end});
else
    error('Either supply a single SequenceOptions argument, or supply a set of name/value pairs, or supply a SequenceOptions argument followed by name/value pairs');
end

ImageFreq = opt.detuning*0.6238/6 + 8.3;
% ImageFreq = opt.params(1);
dipole_field = 3 - 0.025;
% dipole_field = opt.params(1);
imaging_field = 0.5;
ImageAmp = 7;
%% Initialize sequence
sq = initSequence;  %load default values (OLD MOT values are default) 
sq.find('87 imag freq').set(8.35);
sq.find('87 imag amp').set(4);
%% MOT loading
%
% We use CD channel 0b10 = 2 for loading the MOT 
%
sq.find('2DMOT').set(1);
sq.find('3DMOT').set(1);
sq.find('87 push').set(1);
% 3D MOT beam settings
sq.find('3DMOT Freq').set(FtoV('trap',22));
sq.find('3DMOT amp').set(TrapPtoV('trap',1));
% 3D repump beam settings
sq.find('87 repump').set(1);
sq.find('Repump Switch').set(0);
sq.find('87 repump freq').set(FtoV('repump',0));
sq.find('87 repump amp').set(TrapPtoV('repump',1));
% 3D coil settings
sq.find('H-Bridge Quad').set(1);
sq.find('CD bit 0').set(0); 
sq.find('CD bit 1').set(1);
sq.find('CD2').set(dBtoV('normal',11)); %Coarse control of 3D coils
sq.find('CD Fine/Fast').set(dBtoV('fine',8)); % fine control of 3D coils
%Delay for the load time
sq.delay(opt.load_time);
%
% Turn off the 2D MOT and coils as well as the push beam
%
sq.find('2D MOT Coils').before(10e-3,0);
sq.find('2DMOT').before(10e-3,0);
sq.find('87 push').before(10e-3,0);
sq.find('85 push').before(10e-3,0);

%% CMOT sequence
%
% Apply a compressed MOT sequence to temporarily increase the density by
% reducing spontaneous emission.  We switch to CD channel 0b00 = 0 because
% it is the fast channel
%
Tcmot = 15e-3;
t = 0:1e-3:Tcmot;
%3D Coils
sq.find('CD bit 0').set(0);
sq.find('CD bit 1').set(0);
sq.find('CD0 Fast').set(dBtoV('normal',0));
sq.find('CD Fine/Fast').set(dBtoV('fine',9)); 
%Trapping light
sq.find('3DMOT freq').after(t,sq.linramp(t,sq.find('3DMOT freq').values(end),FtoV('trap',45))); 
sq.find('3DMOT amp').set(TrapPtoV('trap',1));
%Repump
sq.find('87 repump freq').set(FtoV('repump',-4)); 
sq.find('87 repump amp').set(TrapPtoV('repump',0.8)); 

sq.delay(Tcmot);

%% PGC sequence
%
% Apply polarization gradient cooling to reduce the temperature of the
% atoms.  We use CD channel 0b00 = 0 as it is the fast-switching channel
%
Tpgc = 22e-3;
t = 0:1e-3:Tpgc;
sq.find('CD fine/fast').set(dBtoV('fine',7));
sq.find('CD0 Fast').set(dBtoV('normal',0));
sq.find('3DMOT freq').after(t,sq.minjerk(t,sq.find('3DMOT freq').values(end),FtoV('trap',70)));
sq.find('3DMOT amp').after(t,sq.minjerk(t,sq.find('3DMOT amp').values(end),TrapPtoV('trap',1)));

sq.find('87 repump freq').set(FtoV('repump',-2.5));
sq.find('87 repump amp').set(TrapPtoV('repump',0.05));

sq.delay(Tpgc);

%% Optical pump atoms into the F = 1 manifold
%
% Turn off repump field so that atoms are optically pumped into the F = 1
% manifold.
%
Tdepump = 1e-3;
sq.find('repump switch').set(1); %fiber switch off (it's inverted)
sq.find('87 repump').set(0);
sq.find('87 repump amp').set(0);
sq.find('85 repump').set(0);
sq.find('85 repump amp').set(0);
sq.delay(Tdepump);
sq.find('3DMOT').set(0);

%% Load into magnetic trap
%
% Load into the magnetic trap at a high gradient.  We switch quickly to a
% low value and then ramp up to the target value
%
Tmagload = 150e-3;
% t = linspace(0,Tmagload,51);
t = 0:5e-3:Tmagload;
dBLoad = 110;
sq.find('CD0 Fast').after(t,sq.linramp(t,dBtoV('normal',dBLoad/2),dBtoV('normal',dBLoad)));
sq.find('CD Fine/Fast').set(dBtoV('fine',0));
%  sq.delay(Tmagload);

Toptload = 400e-3;
% t = linspace(0,Toptload,51);
t = 0:10e-3:Toptload;
% sq.find('Keopsys MO').set(3.9);
% sq.find('Keopsys FA').after(t,sq.minjerk(t,0,DipolePtoV('Keopsys',5)));
% sq.find('Redpower TTL').set(1);
% sq.find('Redpower CW').after(t,sq.minjerk(t,0,DipolePtoV('RedPower',15)));
sq.find('MOT bias').set(1);
sq.find('MOT bias coil').after(t,sq.linramp(t,0,dipole_field));
sq.delay(max(Toptload,Tmagload));

%% RF evaporation
%
% Remove hot atoms from the sample using RF transitions between the trapped
% |F = 1, m_F = -1> state and the untrapped |F = 1, m_F = 0> state.  All
% frequencies are in MHz
%
% rf_start = 20;
% rf_end = 3;
% rf_rate = 3;    %MHz/s
% Tevap = (rf_start - rf_end)/rf_rate;
% rf_ramp_type = 'lin';
% rf_exp_time_constant = 2;
% t = linspace(0,Tevap,50);
% 
% sq.find('RF atten').set(1);
% if strcmpi(rf_ramp_type,'exp')
%     sq.find('RF frequency').after(t,sq.expramp(t,RFtoV(rf_start),RFtoV(rf_end),rf_exp_time_constant)); %ramp rf frequency from 4 to -2.667
% elseif strcmpi(rf_ramp_type,'lin')
%     sq.find('RF frequency').after(t,sq.linramp(t,RFtoV(rf_start),RFtoV(rf_end)));
% end
% sq.delay(Tevap);
% 
% sq.find('RF atten').set(0);
% sq.find('RF Frequency').set(RFtoV(20));
%
% Ramp up the MOT bias coil for loading into dipole trap
%
% T = 0.25;
% t = linspace(0,T,50);
% sq.find('MOT bias').set(1);
% sq.find('MOT bias coil').after(t,sq.linramp(t,0,0.5));
% sq.delay(T);

%% Take dummy images
% time_at_evap_end = sq.time;
% sq.anchor(sq.time - 3);
% sq.camDelay = sq.time - 2;
% makeNDImagingSequence(sq,'pulse time',opt.nd.pulse_time,'cam time',5e-6,'cycle time',100e-3,...
%     'imaging freq',8.5,'imaging amplitude',opt.nd.pulse_amp,'species',85,'num_images',opt.nd.ref_images,...
%     'pulse delay',opt.nd.pulse_delay);
% sq.anchor(time_at_evap_end);

%% Turn off magnetic trap
% sq.find('CD0 Fast').set(0);
% sq.find('CD Fine/Fast').set(0);
% sq.delay(20e-3 - opt.tof);

%% Optical evaporation
% Tevap = 3;
% t = linspace(0,Tevap,150);
% final_dipole.RP = opt.redpower;
% final_dipole.FA = opt.keopsys;
% %old time constant was 0.42
% sq.find('RedPower CW').after(t,sq.expramp(t,sq.find('RedPower CW').values(end),DipolePtoV('redpower',final_dipole.RP),0.42));
% sq.find('Keopsys FA').after(t,sq.expramp(t,sq.find('Keopsys FA').values(end),DipolePtoV('keopsys',final_dipole.FA),0.42));
% sq.delay(Tevap);

% T = 100e-3;
% t = linspace(0,T,51);
% sq.find('Keopsys FA').after(t,sq.linramp(t,sq.find('Keopsys FA').values(end),DipolePtoV('keopsys',1)));
% sq.find('RedPower CW').after(t,sq.linramp(t,sq.find('RedPower CW').values(end),DipolePtoV('redpower',1.34)));
% sq.delay(T);

%% Non-destructive imaging
% sq.find('Keopsys FA').after(20*opt.nd.cycle_time,DipolePtoV('keopsys',final_dipole.FA + 0.2));

% num_mod_cycles = 20;
% fmod = sqrt(5/2)*21;
% % fmod = 2*52.6;
% Tmod = 1/fmod;
% dt = 0.1*Tmod;
% t = 0:dt:(num_mod_cycles*Tmod);
% sq.find('RedPower CW').after(t,DipolePtoV('redpower',final_dipole.RP + 0.2*sin(2*pi*fmod*t)));
% % sq.find('Keopsys FA').after(t,DipolePtoV('keopsys',final_dipole.FA + 0.0 + 0.2*sin(2*pi*fmod*t)));
% sq.delay(num_mod_cycles*Tmod - opt.nd.num_images*opt.nd.cycle_time/2*0);

% sq.delay(10e-3);
% sq.find('Keopsys FA').set(DipolePtoV('keopsys',final_dipole.FA + 0.0));
% sq.find('RedPower CW').after(50e-3,DipolePtoV('redpower',final_dipole.RP + 0.0));

% Tdrop = 0.7e-3;
% sq.find('Keopsys FA').set(0).after(Tdrop,DipolePtoV('keopsys',final_dipole.FA + 0.2));
% sq.find('RedPower CW').set(0).after(Tdrop,DipolePtoV('redpower',final_dipole.RP));
% sq.delay(Tdrop + 0.5e-3);

% makeNDImagingSequence(sq,'pulse time',opt.nd.pulse_time,'cam time',opt.nd.pulse_delay,'cycle time',opt.nd.cycle_time,...
%     'imaging freq',8.5,'imaging amplitude',opt.nd.pulse_amp,'species',85,'num_images',opt.nd.num_images,...
%     'pulse delay',opt.nd.pulse_delay);

%% Drop atoms
sq.delay(1);
timeAtDrop = sq.time;
sq.camDelay = sq.time - 2;
sq.find('2D MOT Coils').set(0);
sq.find('3DMOT').set(0);
sq.find('87 repump amp').set(0);
sq.find('CD0 Fast').set(0);
sq.find('CD2').set(0);
sq.find('CD Fine/Fast').set(0);
sq.find('CD bit 0').set(0);
sq.find('CD bit 1').set(0);
sq.find('Redpower CW').set(0);
sq.find('Redpower TTL').after(100e-6,0);
sq.find('Keopsys FA').set(0);
sq.find('Keopsys MO').after(100e-6,0);
sq.find('RF atten').set(0);
sq.find('RF Frequency').set(RFtoV(20));

%% Take Absorption Image
% sq.anchor(timeAtDrop);
% sq.delay(opt.tof - 5e-3);
% makeNDImagingSequence(sq,'pulse time',100e-6,'cam time',5e-6,'cycle time',2e-3,...
%     'imaging freq',8.5,'imaging amplitude',8,'species',85,'num_images',1);

% sq.anchor(timeAtDrop);
% sq.delay(4.9e-3);
% sq.find('87 repump freq').set(4.58);
% sq.find('87 repump amp').set(8);
% %Turn on the repump TTL and the fiber switch (inverted!)
% sq.find('87 repump').set(1).after(100e-6,0);
% sq.find('Repump Switch').before(20e-3,0);


% t = linspace(0,5e-3,50);
% sq.find('CD0 Fast').after(t,sq.minjerk(t,0,dBtoV('normal',50)));
% sq.delay(5e-3);
% sq.find('CD0 Fast').after(t,sq.minjerk(t,sq.find('CD0 Fast').values(end),0));

sq.anchor(timeAtDrop);
makeImagingSequence(sq,'tof',opt.tof,'pulse time',30e-6,'repump delay',100e-6,...
    'repump time',100e-6,'cam time',5e-6,'cycle time',40e-3,...
    'manifold',1,'imaging freq',ImageFreq,'imaging amplitude',ImageAmp,...
    'fibre switch delay',1e-3,'imaging_field',imaging_field,'image type','vertical');

% turn off the dipoles
sq.find('Redpower CW').set(0);
sq.find('Redpower TTL').after(100e-6,0);
sq.find('Keopsys FA').set(0);
sq.find('Keopsys MO').after(100e-6,0);
sq.find('RF atten').set(0);
sq.find('RF Frequency').set(RFtoV(20));
sq.find('3DMOT').set(0);
sq.find('87 repump amp').set(0);

% sq.waitFromLatest(60e-3);
% makeNDImagingSequence(sq,'pulse time',opt.nd.pulse_time,'cam time',5e-6,'cycle time',60e-3,...
%     'imaging freq',8.5,'imaging amplitude',opt.nd.pulse_amp,'species',85,'num_images',1,...
%     'pulse delay',10e-6);

sq.waitFromLatest(0.25);
setSafeValues(sq);
 
if nargout == 0
    r = RemoteControl;
    r.upload(sq.compile);
    r.run;
else
    varargout{1} = sq;
end

end