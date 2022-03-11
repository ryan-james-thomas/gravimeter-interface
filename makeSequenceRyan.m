function varargout = makeSequenceRyan(varargin)   
%% Preamble
ImageFreq = FtoV('image',0);
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
sq.find('87 repump freq').set(FtoV('repump',58));
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
% sq.find('3DMOT freq').set(FtoV('trap',50)); 
% sq.find('3DMOT amp').set(5.5);
sq.find('3DMOT freq').set(FtoV('trap',42)); 
sq.find('3DMOT amp').set(5.1);
%Repump
% sq.find('87 repump freq').set(FtoV('repump',55)); 
% sq.find('87 repump amp').set(5); 
sq.find('87 repump freq').set(FtoV('repump',62.7)); 
sq.find('87 repump amp').set(2.8); 

sq.delay(Tcmot);

%% PGC sequence
%
% Apply polarization gradient cooling to reduce the temperature of the
% atoms.  We use CD channel 0b00 = 0 as it is the fast-switching channel
%
% Tpgc = 2e-3;
Tpgc = 5.5e-3;
t = linspace(0,Tpgc,100);
sq.find('CD fine/fast').set(dBtoV('fine',6.2));

% sq.find('3DMOT freq').after(t,sq.minjerk(t,sq.find('3DMOT freq').values(end),FtoV('trap',72)));
% sq.find('3DMOT amp').after(t,sq.minjerk(t,sq.find('3DMOT amp').values(end),5.2));
sq.find('3DMOT freq').after(t,sq.minjerk(t,sq.find('3DMOT freq').values(end),FtoV('trap',54)));
sq.find('3DMOT amp').after(t,sq.minjerk(t,sq.find('3DMOT amp').values(end),5.56));

% sq.find('87 repump freq').set(FtoV('repump',55));
% sq.find('87 repump amp').set(6);

sq.find('87 repump freq').set(FtoV('repump',57));
sq.find('87 repump amp').set(4.7);

sq.delay(Tpgc);

%% Optical pump atoms into the F = 1 manifold
%
% Turn off repump field so that atoms are optically pumped into the F = 1
% manifold.
%
Tdepump = 2e-3;
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
sq.find('CD Fine/Fast').set(dBtoV('fine',0));
sq.delay(Tmagload);

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
% rf_start = 15;
% rf_end = 2;
% rf_rate = 2;    %MHz/s
% Tevap = (rf_start - rf_end)/rf_rate;
% rf_ramp_type = 'lin';
% rf_exp_time_constant = 2;
% t = linspace(0,Tevap,200);
% 
% sq.find('RF atten').set(1);
% if strcmpi(rf_ramp_type,'exp')
%     sq.find('RF frequency').after(t,sq.expramp(t,RFtoV(rf_start),RFtoV(rf_end),rf_exp_time_constant)); %ramp rf frequency from 4 to -2.667
% elseif strcmpi(rf_ramp_type,'lin')
%     sq.find('RF frequency').after(t,sq.linramp(t,RFtoV(rf_start),RFtoV(rf_end)));
% end
% 
% sq.delay(Tevap);

%
% These are values obtained from the machine learning program M-LOOP
%
N_evap_segments = 4;
% freqs = cumsum([varargin{2 + (0:(N_evap_segments-1))}]);
% freqs(end + 1) = 2;
% freqs(freqs < 0) = 0;
% times = [varargin{2 + N_evap_segments + (0:(N_evap_segments-1))}];
freqs = [15.78,14.17,9.95,4.35];
times = [0.91,1.95,1.48,1.99];
rf_end = 2;
freqs(end + 1) = rf_end;
sq.find('RF atten').set(1);
for nn = 1:N_evap_segments
    t = linspace(0,times(nn),50);
    sq.find('RF frequency').after(t,sq.linramp(t,RFtoV(freqs(nn)),RFtoV(freqs(nn+1))));
end
sq.anchor(sq.latest);

%% Weaken magnetic trap, continue evaporation

Trampcoils = 2000e-3;
dB_weak = 0;
FinalRFKnife = 0;
t = linspace(0,Trampcoils,100);
sq.find('CD0 Fast').after(t,sq.linramp(t,sq.find('CD0 Fast').values(end),dBtoV('normal',dB_weak)));
sq.find('RF Frequency').after(t,sq.linramp(t,sq.find('RF Frequency').values(end),RFtoV(FinalRFKnife)));
sq.delay(Trampcoils);
sq.find('RF atten').set(0);
sq.find('RF Frequency').set(RFtoV(20));

% Turn off magnetic trap
sq.find('CD0 Fast').set(0);
sq.find('CD Fine/Fast').set(0);
% % sq.delay(30e-3 - tDrop);

%% Optical evaporation
Tevap = 2;
t = linspace(0,Tevap,200);
% sq.find('RedPower CW').after(t,sq.expramp(t,sq.find('RedPower CW').values(end),DipolePtoV('redpower',0.1),1/2.5));
% sq.find('Keopsys FA').after(t,sq.expramp(t,sq.find('Keopsys FA').values(end),DipolePtoV('keopsysfa',0.35),1/2.5));
sq.find('RedPower CW').after(t,sq.expramp(t,sq.find('RedPower CW').values(end),DipolePtoV('redpower',0.6/2),1));
sq.find('Keopsys FA').after(t,sq.expramp(t,sq.find('Keopsys FA').values(end),DipolePtoV('keopsysfa',0.35/2),1));
sq.delay(Tevap);

%% Drop atoms
timeAtDrop = sq.time;
sq.find('CD0 Fast').set(0);
sq.find('CD Fine/Fast').set(0);
sq.find('Redpower CW').set(0);
sq.find('Redpower TTL').after(100e-6,0);
sq.find('Keopsys FA').set(0);
sq.find('Keopsys MO').after(100e-6,0);

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



% sq.find('2D MOT Coils').set(0);
% sq.find("3DMOT amp").set(0);
% sq.delay(10e-3);
%% Mag Evap
% tMagEvap = 4; %length of first evaporation sequence
% sq.find('RF atten').set(1); %turn off the rf attenuation
% t = linspace(0,tMagEvap,tMagEvap/50e-3+1); %create timeseries for rf frequnecy ramp
% % sq.find('RF frequency').after(t,sq.linramp(t,4,-2.667)); %ramp rf frequency from 4 to -2.667
% sq.find('RF frequency').after(t,sq.linramp(t,5,1)); %ramp rf frequency from 4 to -2.667
% sq.delay(tMagEvap); % delay global pointer to end of first mag evap ramp
% 
% %Mag Ramp down
% % tMagRampDown = 1.5;  % time to ramp quad field down
% % t = linspace(0,tMagRampDown,tMagRampDown/10e-3+1);
% % sq.find('CD0 Fast').after(t,sq.linramp(t,sq.find('CD0 Fast').values(end),2.04)); % ramp down teh quad coils current to 2.04V (just enough to hold against gravity)
% % sq.find('RF frequency').after(t,sq.linramp(t,sq.find('RF frequency').values(end),-4.49)); % do a bit of force rf evap during
% % 
% % sq.delay(tMagRampDown); % move to end of mag field ramp down
% sq.find('RF atten').set(0); %turn off rf
% sq.find('RF frequency').set(5); %move rf freq back to 20MHz




    
%     %Do swtich from Quad to Helm  
%     OpticalEvapField = 0.2;  %what Bfield is set at during optical evap and drop 
%     %dont need this for 87, but maybe leave a small field on the stop mf
%     %degeneracy
%     sq.find('CD0 Fast').set(0);  %set current to 0V
%     %wait 50us for current to dissapate then switch to helm holz
%     %NEVER HAVE BOTH CHANNELS ON!!!!
%     sq.find('H-bridge Quad').after(50e-6,0);  
%     sq.find('H-bridge Helm').after(50e-6,1);  
%     
%     %ramp up the helmholtz field to be good for 85 evap (165Gaus)
%     %there are two ramps because it works (this was just tuned)
%     tMagRampUp1 = 0.5e-3; %first ramp
%     tMagRampUp2 = 0.5e-3; %second ramp
%     t = linspace(0,tMagRampUp1,tMagRampUp1/20e-6+1);
%     sq.find('CD0 Fast').after(t,sq.minjerk(t,sq.find('CD0 Fast').values(end),0.2));
%     t = linspace(0,tMagRampUp2,tMagRampUp2/20e-6+1);
%     sq.find('CD0 Fast').after(t,sq.minjerk(t,sq.find('CD0 Fast').values(end), OpticalEvapField));
    
%     %OPTICAL EVAP
%     tOptical = 2.5; %time for optical evaporation (was 2.5)
%     t = linspace(0,tOptical,tOptical/10e-3+1); %time array
%     %ramp redpower down exponentially over 2.5s with a time constant of
%     %1/2.5
%     sq.find('Redpower CW').after(t,sq.expramp(t,sq.find('Redpower CW').values(end),0.75,1/2.5)); %0.75  %max is 5V 
%     %ramp redpower down exponentially over 2.5s with a time constant of
%     %1/2.5
%     sq.find('Keopsys FA').after(t,sq.expramp(t,sq.find('Keopsys FA').values(end),1.07,1/2.5)); %1.07or1.09 % max is 3.2V  %raise or lower final point to get hotter or colder
%     %ramp redpower down exponentially over 2.5s with a time constant of
%     %1/2.5
%     % ((((good bec at repower 0.75V, kepsoys 1.07V)
%     sq.delay(tOptical); %move to end of optical evap
%     
%     %Compress again
%     tOptical = 400e-3;
%     t = linspace(0,tOptical,tOptical/20e-3+1);
%     sq.find('Redpower CW').after(t,sq.minjerk(t,0.65,1.2));
%     sq.find('Keopsys FA').after(t,sq.minjerk(t,1.15,1.3));
%     sq.delay(tOptical);
% 
%      tOpticalHold= 100e-3; %%100e-3
%      sq.find('Redpower CW').set(0);
%      sq.delay(tOpticalHold);
%  
%     %turn off the dipoles
%     sq.find('Redpower CW').set(0);
%     sq.find('Redpower TTL').set(0);
%     sq.find('Keopsys FA').set(0);
%     sq.find('Keopsys MO').after(100e-6,0);
    
    
    
    %% drop cloud
    % Ryan: tDrop = how long the atoms fall before the imaging sequence is
    % carreid out. This is the variable you'll scan to calibrate the
    % magnification of the system. To do an automated scan, read Ryan's
    % git (he messaged us the link) and or ask Yos. The script needed to
    % do a scan (is open) called Callback_GenericOptmize. Will be good to
    % figure out how this work because you will be using it lots.
    %
% % %     % Set imaging parameters BEFORE you take the image
% % %     sq.find('87 imag freq').set(ImageFreq); %7.61 is 12Mhz, 8.354 is 0mhz
% % %     sq.find('87 imag amp').set(ImageAmp);
% % %     sq.find('87 repump freq').set(4.565); %perpate repump VCO at correct frequency
% % %     sq.find('85 repump freq').set(4.64); 
% % %     sq.find('repump switch').set(0); %turn on fibre switch for repump (theres a delay (pat cant remember how long it is))
% % %     sq.find('87 repump amp').set(8); %turn on repump amplitude
% % %     sq.find('CD0 Fast').set(0); %zero mag field
% % %     sq.find('MOT bias coil').set(2.95); %turn on the imaging coil (to align the axis of atoms)
% % %     sq.find('MOT bias').set(1); %ttl on imaging coil
    %
    % Fiber switch delay may be important for detecting BEC
    %
% % % % %     sq.anchor(timeAtDrop);
% % % % %     makeImagingSequence(sq,'tof',tDrop,'pulse time',0.1e-3,'repump delay',100e-6,...
% % % % %         'repump time',100e-6,'cam time',500e-6,'cycle time',100e-3,...
% % % % %         'manifold',1,'imaging freq',ImageFreq,'imaging amplitude',ImageAmp,...
% % % % %         'fibre switch delay',1e-3);
    
    %image
    
%     sq.find('CD0 Fast').set(0); %zero mag field
%     sq.find('MOT bias coil').set(2.95); %turn on the imaging coil (to align the axis of atoms)
%     sq.find('MOT bias').set(1); %ttl on imaging coil
%     sq.find('87 imag freq').set(ImageFreq); %7.61 is 12Mhz, 8.354 is 0mhz
%     sq.find('87 imag amp').set(ImageAmp);
%     Ryan: sq.find('name') looks up a channel that we control. ".set(NUM)"
%     sets that channel to a given value. For absorption imaging, you can
%     see we look up the "87 imag freq" channel and then set it to a
%     value of 8.354 V (which is resonance). This is the variable you'll
%     scan over to determine if this is resonance (or not).
%     sq.find('87 repump freq').set(4.565); %perpate repump VCO at correct frequency
%     sq.find('85 repump freq').set(4.64); 
%     sq.find('repump switch').set(0); %turn on fibre switch for repump (theres a delay (pat cant remember how long it is))
%     sq.find('87 repump amp').set(8); %turn on repump amplitude
%     sq.find('Scope').set(1); %Thorcam trigger
%     sq.find('Probe').set(1);
%     sq.delay(0.5e-3); %wait for 0.5ms
    
    %% anthony's stuff
    %repump cloud from f=1 to f=2
%     sq.find('Probe').set(1);
%     sq.find('Scope').set(1);
% %     sq.find('Stark').set(1);
%     sq.delay(10e-6);
%     sq.find('87 repump').set(1); 
%     sq.find('Probe').set(0);
%     sq.find('Scope').set(0);
% %     sq.find('Stark').set(0);

%%
% % %  I think repump should be on here
%     sq.delay(85e-6); %100us pulse to repump (longer might be needed for large clouds (eg MOT or mag trap)) was 85us
%     sq.find('87 repump').set(0);
% %     sq.find('Probe').set(1);
% %     sq.find('Scope').set(1);
%     %take iamge 
%     sq.find('87 cam trig').set(1); %trigger camera (first image seems to be delayed)
%     sq.delay(5e-3);
%     sq.find('87 imag').set(1); %turn on imaging light
%     sq.delay(0.15e-3); %wait for extra time %0.15e-3
%     sq.find('87 cam trig').set(0); %turn off
%     sq.find('87 imag').set(0);

    
    %background image
%     sq.delay(500e-3); %wait 100ms to take background subtraction image
%     sq.find('Probe').set(0);
%     sq.find('Scope').set(0);
    %repump cloud from f=1 to f=2
%     sq.find('87 repump').set(1);
%     sq.find('Probe').set(1);
%     sq.find('Scope').set(1);
% % % % I think repump should be on here?
%     sq.delay(0.1e-3); %100us pulse to repump (longer might be needed for large clouds (eg MOT or mag trap))
% %     sq.find('87 repump').set(0);
% %     sq.find('Probe').set(0);
% %     sq.find('Scope').set(0);
%     %take iamge
%     sq.find('87 cam trig').set(1); %trigger camera (first image seems to be delayed)
%     sq.delay(5e-3);
%     sq.find('87 imag').set(1); %turn on imaging light
%     sq.delay(0.15e-3); %wait for extra time %0.15e-3
%     sq.find('87 cam trig').set(0); %turn off
%     sq.find('87 imag').set(0);
%     sq.delay(500e-3);
%     sq.find('87 imag').set(0);
    
 %do run building stuff  and compile ???
 
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
    
    %%%HERE BE GRAVY STUFF
    
%     %% Set up the MOT loading values                
%     sq.find('MOT coil TTL').set(1);     %Turn on the MOT coils
% %     sq.find('3d coils').set(0.42);
%     sq.find('bias u/d').set(0);
%     sq.find('bias e/w').set(0);
%     sq.find('bias n/s').set(0);
%     
%     Tmot = 6;                           %6 s MOT loading time
%     sq.delay(Tmot);                     %Wait for Tmot
%     %% Compressed MOT stage
%     %Turn off the 2D MOT and push beam 10 ms before the CMOT stage
%     sq.find('2D MOT Amp TTL').before(10e-3,0);
%     sq.find('push amp ttl').before(10e-3,0);
%     t = linspace(-10e-3,0,100);
%     f = @(vi,vf) sq.minjerk(t,vi,vf);
% %     sq.find('bias e/w').after(t,f(0,4));
% %     sq.find('bias n/s').after(t,f(0,5));
% %     sq.find('bias u/d').after(t,f(0,varain{1}));
%     
%     %Increase the cooling and repump detunings to reduce re-radiation
%     %pressure, and weaken the trap
%     sq.find('3D MOT freq').set(6);
%     sq.find('repump freq').set(2.4);
%     sq.find('3D coils').set(0.15);
%     sq.find('bias e/w').set(4);
%     sq.find('bias n/s').set(6);
%     sq.find('bias u/d').set(2);
%     
%     Tcmot = 16e-3;                      %16 ms CMOT stage
%     sq.delay(Tcmot);                    %Wait for time Tcmot
%     %% PGC stage
%     Tpgc = 20e-3;
%     %Define a function giving a 100 point smoothly varying curve
%     t = linspace(0,Tpgc,100);
%     f = @(vi,vf) sq.minjerk(t,vi,vf);
% 
%     %Smooth ramps for these parameters
%     sq.find('3D MOT Amp').after(t,f(5,2.88));
%     sq.find('3D MOT Freq').after(t,f(6,2.9));
%     sq.find('3D coils').after(t,f(0.15,0));
%     %Linear ramp for these
% %     sq.find('repump freq').after(t,2.5+(2.3-2.5)*t/Tpgc);
% 
%     %Wait 5 ms and then turn off the repump light
%     sq.delay(Tpgc);
%     sq.find('MOT coil ttl').set(0);
%     
%     sq.delay(varain{1}/1000);
%     sq.find('repump amp ttl').set(0);
%     sq.find('liquid crystal repump').set(7);
% %     sq.delay(Tpgc);
% 
%     %Wait 1 ms and then turn off the MOT light - optical pumping?
%     sq.delay(2e-3);
%     sq.find('3D mot amp ttl').set(0);
%     sq.find('50W TTL').set(0);
%     sq.find('25W TTL').set(0);
%     
%     sq.find('liquid crystal bragg').set(-3.64);
%     
%     %This command sets the internal sequence pointer for the last time to
%     %the time of the last update
%     sq.anchor(sq.latest);
% 
%     %I've added these commands because they seemed to be in the original
%     %runs at 6.05 s for some reason
%     sq.find('50W Amp').at(6.05,0.92);
%     sq.find('25W Amp').at(6.05,1.974);
%     sq.find('MW Freq').at(6.05,0);
%     sq.find('liquid crystal repump').at(6.05,-2.22);
% 
%     %% Imaging stage
% %     tof = 25e-3;
%     tof = varain{2};
%     pulseTime = 100e-6;
%     cycleTime = 100e-3;
%     %Repump settings - repump occurs just before imaging
%     sq.find('repump freq').after(tof-pulseTime,4.3);
%     sq.find('repump amp ttl').after(tof-pulseTime,1);
%     sq.find('repump amp ttl').after(pulseTime,0);
% %     
%     %Imaging beam and camera trigger for image with atoms
%     sq.find('Imaging amp ttl').after(tof,1);
%     sq.find('cam trig').after(tof,1);
%     sq.find('imaging amp ttl').after(pulseTime,0);
%     sq.find('cam trig').after(pulseTime,0);
%     
%     %Take image without atoms
%     sq.find('Imaging amp ttl').after(cycleTime,1);
%     sq.find('cam trig').after(cycleTime,1);
%     sq.find('imaging amp ttl').after(pulseTime,0);
%     sq.find('cam trig').after(pulseTime,0);
% %     sq.find('repump amp ttl').after(t,1);
% %     sq.find('repump amp ttl').after(pulseTime,0);
