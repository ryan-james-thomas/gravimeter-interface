function varargout = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    %
    % Define useful conversion functions
    %
    % Dipole trap powers for 25 W (P25) and 50 W (P50) lasers. Gives
    % voltage for powers in W
%     P25 = @(x) (x+2.6412)/2.8305;
%     P50 = @(x) (x+3.7580)/5.5445;
    P25 = @(x) x/2.56;
    P50 = @(x) (x + 0.1414)/6.4484;
    %
    % Imaging detuning. Gives voltage for detuning in MHz
    %
%     imageVoltage = -varargin{1}*0.4231/6.065 + 8.6214;    %At second drop?
    imageVoltage = -varargin{1}*0.472/6.065 + 8.533;
%     imageVoltage = varargin{1};
    %
    % Voltage value that guarantees that the MOT coils are off
    %
    motCoilOff = -0.2;

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
    sq.find('bias n/s').set(10);
    
    Tmot = 5;                           %6 s MOT loading time
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
    t = linspace(0,Tpgc,100);
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
%     sq.delay(3.2);

    %% Microwave evaporation
    sq.delay(20e-3);
    evapRate = 0.2;
    evapStart = 7.25;
    evapEnd = 7.9;
    Tevap = (evapEnd-evapStart)/evapRate;
%     Tevap = 3.2;
    t = linspace(0,Tevap,100);
    sq.find('mw freq').after(t,sq.linramp(t,evapStart,evapEnd));
    sq.delay(Tevap);
    
    %% Weaken trap while MW frequency fixed
    Trampcoils = 180e-3;
    t = linspace(0,Trampcoils,100);
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
    Tevap = 1.97;
    t = linspace(0,Tevap,300);
    sq.find('50W amp').after(t,sq.expramp(t,sq.find('50w amp').values(end),P50(varargin{3}),0.8));
    sq.find('25W amp').after(t,sq.expramp(t,sq.find('25w amp').values(end),P25(varargin{3}),0.8));
    sq.delay(Tevap);
    T = 200e-3;
    t = linspace(0,T,100);
%     sq.find('50W amp').after(t,sq.minjerk(t,P50(varargin{3}),P50(varargin{3} + 0.05)));
%     sq.find('25W amp').after(t,sq.minjerk(t,P25(varargin{3}),P25(varargin{3} + 0.05)));

    sq.find('50W amp').after(t,sq.minjerk(t,P50(varargin{3}),P50(varargin{3} - 1.44)));
    sq.find('25W amp').after(t,sq.minjerk(t,P25(varargin{3}),P25(varargin{3} + 1.50)));
    sq.delay(T);

    %% Drop atoms
%     sq.delay(3.2);
    timeAtDrop = sq.time; %Store the time when the atoms are dropped for later
    sq.anchor(timeAtDrop);
    sq.find('3D mot amp ttl').set(0);
    sq.find('bias e/w').before(200e-3,0);
    sq.find('bias n/s').before(200e-3,0);
    sq.find('bias u/d').before(200e-3,0);
    sq.find('mw amp ttl').set(0);
    sq.find('mot coil ttl').set(0);
    sq.find('3D Coils').set(motCoilOff);
    sq.find('25w ttl').set(0);
    sq.find('50w ttl').set(0);

    %% Interferometry
    enableDDS = 1;      %Enable DDS and DDS trigger
    enableBragg = 1;    %Enable Bragg diffraction
    enableRaman = 0;    %Enable Raman transition
    enableSG = 0;       %Enable Stern-Gerlach separation
    if enableDDS
        % 
        % Issue falling-edge trigger for MOGLabs DDS box when DDS is
        % enabled
        %
        sq.find('dds trig').before(10e-3,1);
        sq.find('dds trig').after(10e-3,0); %MOGLabs DDS triggers on falling edge
        sq.find('dds trig').after(10e-3,1);
        sq.ddsTrigDelay = timeAtDrop; 
    end
    
    if enableDDS && enableBragg
        %
        % Create a sequence of Bragg pulses. The property ddsTrigDelay is used
        % in compiling the DDS instructions and making sure that they start at
        % the correct time.
        %
        braggOrder = 1;
        k = 2*pi*384.229241689e12/const.c;  %Frequency of Rb-85 F=3 -> F'=4 transition
        vrel = abs(2*const.hbar*k/const.mRb);
        g = 9.795;
        chirp = 25.1075e6;
%         chirp = varargin{6};
        T = varargin{6};
        Tasym = 000e-6;
        if Tasym == 0
            dsep = 5e-3;
            Tsep = dsep/vrel;
            tmp = roots([1,2*(2*T+Tsep),(2*T+Tsep)^2-varargin{2}^2+2/g*vrel*T]);
%             t0 = tmp(tmp > 0);
        else  
            Tsep = 1*abs(const.mRb*pi*varargin{2}/(4*braggOrder*k^2*const.hbar*Tasym));
            t0 = varargin{2} - 2*T - Tsep;
        end
        t0 = varargin{2} - 2*T - Tsep;
%         t0 = 300e-3;
        
        if numel(t0) > 1
            error('Unable to determine t0!');
        elseif t0 < 30e-3
            warning('Initial Bragg pulse occurs at %.1f ms and will be clamped to 30 ms!',t0*1e3);
        end
        t0 = max(t0,30e-3);

%         T = 1e-3;
%         sq.find('Raman Amp').at(timeAtDrop,5).after(t0-0.15e-3,0).after(0.15e-3*2,5);
%         sq.find('Liquid crystal Bragg').after(t0+0.1e-3,3);
%         sq.find('3d trap shutter').after(t0-5e-3,0).after(5e-3,1);
        
        fprintf(1,'t0 = %0.6f ms\n',t0*1e3);
        makeBraggSequence(sq.dds,'k',k,'dt',1e-6,'t0',t0,'T',T,...
            'width',30e-6,'Tasym',Tasym,'phase',[0,0,varargin{5}],'chirp',chirp,...
            'power',varargin{4}*[1,2,1],'order',braggOrder);
    end
    
    if enableDDS && enableRaman
        %
        % Start by re-anchoring the internal pointer for the DDS channels at the
        % drop time.  I do this to make referencing the time at which the Raman
        % pulse occurs easier to calculate
        %
        sq.dds.anchor(timeAtDrop);
        sq.find('Bias E/W').at(timeAtDrop-200e-3,10);
        %
        % This makes a Gaussian pulse with the specified parameters: centered at
        % 't0' with FWHM of 'width', a maximum power of 'power', and the channel
        % 2 frequency 'df' higher than channel 1.
        %
        t0 = 5e-3;
        makeGaussianPulse(sq.dds,'t0',t0,'width',100e-6,'dt',5e-6,'power',0.3,...
            'df',151e-3);
        %
        % Turn on the amplifier for the Raman AOM. Keep in mind that the
        % internal pointer for Raman Amp is still at timeAtDrop
        %
        sq.delay(t0 - 1e-3);
        sq.find('raman amp').set(5);    %This is an analog value, so set to 5 V to turn on
        sq.delay(2e-3);
        sq.find('Raman amp').set(0);
        sq.find('Bias E/W').set(0);
    end
    
    if enableSG
        %
        % Apply a Stern-Gerlach pulse to separate states based on magnetic
        % moment.  A ramp is used to ensure that the magnetic states
        % adiabatically follow the magnetic field
        %     
        sq.delay(15e-3);
        Tsg = 5e-3;
        sq.find('mot coil ttl').set(1);
        t = linspace(0,Tsg,20);
        sq.find('3d coils').after(t,sq.linramp(t,motCoilOff,0.175));
        sq.find('3d coils').after(t,sq.linramp(t,sq.find('3d coils').values(end),motCoilOff));
        sq.delay(2*Tsg);
        sq.find('mot coil ttl').set(0);
        sq.find('3d coils').set(motCoilOff);
    end

    %% Imaging stage
    %
    % Image the atoms.  Reset the pointer for the whole sequence to when
    % the atoms are dropped from the trap.  This means that the
    % time-of-flight (tof) used in makeImagingSequence is now the delay
    % from the time at which the atoms are dropped to when the first
    % imaging pulse occurs
    %
    sq.anchor(timeAtDrop);
%     makeImagingSequence(sq,'type','drop 2','tof',varargin{2},...
%         'repump Time',100e-6,'pulse Delay',00e-6,...
%         'imaging freq',imageVoltage,'repump delay',10e-6,'repump freq',4.3,...
%         'manifold',1);

    makeFMISequence(sq,'tof',varargin{2},'offset',30e-3,'duration',100e-3,...
        'imaging freq',imageVoltage,'manifold',1);

    %% Automatic save of run
    %
    % This automatically creates a record of this file when the sequence is
    % created
    %
    fpathfull = [mfilename('fullpath'),'.m'];
    saveSequenceCopy(fpathfull,sq.directory,varargin);
    %% Automatic start
    %If no output argument is requested, then compile and run the above
    %sequence
    if nargout == 0
        r = RemoteControl;
        r.upload(sq.compile);
        r.run;
    else
        varargout{1} = sq;
    end

end
