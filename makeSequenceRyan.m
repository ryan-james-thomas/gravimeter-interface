function varargout = makeSequenceRyan(varargin)   
%% Preamble
ImageFreq = FtoV('image',6);
ImageAmp = 5.0;
tDrop = varargin{1};
%% Initialize sequence
sq = initSequence;  %load default values (OLD MOT values are default) 
%% MOT loading
%
% We use CD channel 0b10 = 2 for loading the MOT 
%
sq.find('2DMOT').set(1);
sq.find('3DMOT').set(1);
sq.find('87 push').set(1);
% 3D MOT beam settings
sq.find('3DMOT Freq').set(FtoV('trap',20));
sq.find('3DMOT amp').set(6);
% 3D repump beam settings
sq.find('87 repump').set(1);
sq.find('Repump Switch').set(0);
sq.find('87 repump freq').set(FtoV('repump',54));
sq.find('87 repump amp').set(5.5);
% 3D coil settings
sq.find('H-Bridge Quad').set(1);
sq.find('CD bit 0').set(0);
sq.find('CD bit 1').set(1);
sq.find('CD2').set(dBtoV('normal',11));
sq.find('CD Fine/Fast').set(dBtoV('fine',3.44));
%Delay for the load time
sq.delay(7.5);
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
Tcmot = 30e-3;
%3D Coils
sq.find('CD bit 0').set(0);
sq.find('CD bit 1').set(0);
% sq.find('CD Fine/Fast').set(dBtoV('fine',6.9)); 
sq.find('CD Fine/Fast').set(dBtoV('fine',8.8)); 
%Trapping light
sq.find('3DMOT freq').set(FtoV('trap',45)); 
sq.find('3DMOT amp').set(5);
%Repump
sq.find('87 repump freq').set(FtoV('repump',50)); 
sq.find('87 repump amp').set(2); 

sq.delay(Tcmot);

%% PGC sequence
%
% Apply polarization gradient cooling to reduce the temperature of the
% atoms.  We use CD channel 0b00 = 0 as it is the fast-switching channel
%
Tpgc = 1e-3;
t = linspace(0,Tpgc,100);
sq.find('CD fine/fast').set(dBtoV('fine',1.5));

% sq.find('3DMOT freq').after(t,sq.minjerk(t,sq.find('3DMOT freq').values(end),FtoV('trap',72)));
% sq.find('3DMOT amp').after(t,sq.minjerk(t,sq.find('3DMOT amp').values(end),5.2));
% sq.find('3DMOT freq').after(t,sq.minjerk(t,sq.find('3DMOT freq').values(end),FtoV('trap',54)));
% sq.find('3DMOT amp').after(t,sq.minjerk(t,sq.find('3DMOT amp').values(end),4.56));
sq.find('3DMOT freq').after(t,sq.minjerk(t,sq.find('3DMOT freq').values(end),FtoV('trap',70)));
sq.find('3DMOT amp').after(t,sq.minjerk(t,sq.find('3DMOT amp').values(end),5.5));

sq.find('87 repump freq').set(FtoV('repump',54));
sq.find('87 repump amp').set(6);

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
t = linspace(0,Tmagload,100);
dBLoad = 110;
sq.find('CD0 Fast').after(t,sq.linramp(t,dBtoV('normal',dBLoad/2),dBtoV('normal',dBLoad)));
% sq.find('CD0 Fast').set(dBtoV('normal',50));
sq.find('CD Fine/Fast').set(dBtoV('fine',0));
% sq.delay(250e-3);

Toptload = 400e-3;
t = linspace(0,Toptload,100);
sq.find('Keopsys MO').set(3.9);
sq.find('Keopsys FA').after(t,sq.minjerk(t,0,DipolePtoV('KeopsysFA',1)));
sq.find('Redpower TTL').set(1);
sq.find('Redpower CW').after(t,sq.minjerk(t,0,DipolePtoV('RedPower',1)));
sq.delay(Toptload);

%% RF evaporation
%
% Remove hot atoms from the sample using RF transitions between the trapped
% |F = 1, m_F = -1> state and the untrapped |F = 1, m_F = 0> state.  All
% frequencies are in MHz
%
rf_start = 15;
rf_end = 2;
rf_rate = 3;    %MHz/s
Tevap = (rf_start - rf_end)/rf_rate;
rf_ramp_type = 'lin';
rf_exp_time_constant = 2;
t = linspace(0,Tevap,200);

sq.find('RF atten').set(1);
if strcmpi(rf_ramp_type,'exp')
    sq.find('RF frequency').after(t,sq.expramp(t,RFtoV(rf_start),RFtoV(rf_end),rf_exp_time_constant)); %ramp rf frequency from 4 to -2.667
elseif strcmpi(rf_ramp_type,'lin')
    sq.find('RF frequency').after(t,sq.linramp(t,RFtoV(rf_start),RFtoV(rf_end)));
end
sq.delay(Tevap);

% % These are values obtained from the machine learning program M-LOOP
% N_evap_segments = 4;
% freqs = [15.78,14.17,9.95,4.35];
% times = [0.91,1.95,1.48,1.99];
% rf_end = 2;
% freqs(end + 1) = rf_end;
% sq.find('RF atten').set(1);
% for nn = 1:N_evap_segments
%     t = linspace(0,times(nn),50);
%     sq.find('RF frequency').after(t,sq.linramp(t,RFtoV(freqs(nn)),RFtoV(freqs(nn+1))));
% end
% sq.anchor(sq.latest);

%% Weaken magnetic trap, continue evaporation
Trampcoils = 250e-3;
dB_weak = 5;
FinalRFKnife = 1;
t = linspace(0,Trampcoils,100);
sq.find('CD0 Fast').after(t,sq.linramp(t,sq.find('CD0 Fast').values(end),dBtoV('normal',dB_weak)));
sq.find('RF Frequency').after(t,sq.linramp(t,sq.find('RF Frequency').values(end),RFtoV(FinalRFKnife)));
sq.delay(Trampcoils);
sq.find('RF atten').set(0);
sq.find('RF Frequency').set(RFtoV(20));

% Turn off magnetic trap
sq.find('CD0 Fast').set(0);
sq.find('CD Fine/Fast').set(0);
% sq.delay(30e-3 - tDrop);

%% Optical evaporation
Tevap = 2.5 + 1;
t = linspace(0,Tevap,200);
% final_dipole.RP = varargin{2};
% final_dipole.FA = varargin{3};
final_dipole.RP = 0.087;
final_dipole.FA = 0.0865;
sq.find('RedPower CW').after(t,sq.expramp(t,sq.find('RedPower CW').values(end),DipolePtoV('redpower',final_dipole.RP),0.4));
sq.find('Keopsys FA').after(t,sq.expramp(t,sq.find('Keopsys FA').values(end),DipolePtoV('keopsysfa',final_dipole.FA),0.4));
sq.delay(Tevap);

%% Drop atoms
% sq.delay(2);
timeAtDrop = sq.time;
sq.find('CD0 Fast').set(0);
sq.find('CD Fine/Fast').set(0);
sq.find('Redpower CW').set(0);
sq.find('Redpower TTL').after(100e-6,0);
sq.find('Keopsys FA').set(0);
sq.find('Keopsys MO').after(100e-6,0);
sq.find('RF atten').set(0);
sq.find('RF Frequency').set(RFtoV(20));

%% Take Absorption Image
sq.anchor(timeAtDrop);
makeImagingSequence(sq,'tof',tDrop,'pulse time',0.1e-3,'repump delay',100e-6,...
    'repump time',100e-6,'cam time',500e-6,'cycle time',40e-3,...
    'manifold',1,'imaging freq',ImageFreq,'imaging amplitude',ImageAmp,...
    'fibre switch delay',1e-3);

% turn off the dipoles
sq.find('Redpower CW').set(0);
sq.find('Redpower TTL').after(100e-6,0);
sq.find('Keopsys FA').set(0);
sq.find('Keopsys MO').after(100e-6,0);
sq.find('RF atten').set(0);
sq.find('RF Frequency').set(RFtoV(20));
 
if nargout == 0
    r = RemoteControl;
    r.upload(sq.compile);
    %to plot
    sq.plot;
    r.run;
else
    varargout{1} = sq;
end

end