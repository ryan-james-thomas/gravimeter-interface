function varargout = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    %
    % Define useful conversion functions
    %
    % Dipole trap powers for 25 W (P25) and 50 W (P50) lasers. Gives
    % voltage for powers in W
    P25 = @(x) (x+2.6412)/2.8305;
    P50 = @(x) (x+3.7580)/5.5445;
    %
    % Imaging detuning. Gives voltage for detuning in MHz
    %
    imageVoltage = -varargin{1}*0.4231/6.065 + 8.6214;
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
    sq.find('25w amp').set(P25(7.5));    
    %% Set up the MOT loading values                
    sq.find('MOT coil TTL').set(1);     %Turn on the MOT coils
    sq.find('3d coils').set(0.42);
    sq.find('bias u/d').set(0);
    sq.find('bias e/w').set(0);
    sq.find('bias n/s').set(0);
    
    Tmot = 5;                           %6 s MOT loading time
    sq.delay(Tmot);                     %Wait for Tmot
    %% Compressed MOT stage
    %Turn off the 2D MOT and push beam 10 ms before the CMOT stage
    sq.find('2D MOT Amp TTL').before(10e-3,0);
    sq.find('push amp ttl').before(10e-3,0);
    
    %Increase the cooling and repump detunings to reduce re-radiation
    %pressure, and weaken the trap
    sq.find('3D MOT freq').set(5.5);
    sq.find('repump freq').set(2.6);
    sq.find('3D coils').set(0.15);
    sq.find('bias e/w').set(4);
    sq.find('bias n/s').set(6);
    sq.find('bias u/d').set(2);
    
    Tcmot = 16e-3;                      %16 ms CMOT stage
    sq.delay(Tcmot);                    %Wait for time Tcmot
    %% PGC stage
    Tpgc = 20e-3;
    %Define a function giving a 100 point smoothly varying curve
    t = linspace(0,Tpgc,100);
    f = @(vi,vf) sq.minjerk(t,vi,vf);

    %Smooth ramps for these parameters
    sq.find('3D MOT Amp').after(t,f(5,3.25));
    sq.find('3D MOT Freq').after(t,f(sq.find('3D MOT Freq').values(end),5.25)); 
    sq.find('3D coils').after(t,f(0.15,0.02));

    sq.delay(Tpgc);
    %Turn off the repump field for optical pumping - 2 ms
    T = 2e-3;
    sq.find('repump amp ttl').set(0);
    sq.find('liquid crystal repump').set(7);
    sq.find('bias u/d').set(.9);
    sq.find('bias e/w').set(0);
    sq.find('bias n/s').set(7.5);
    sq.delay(T);
    
    %% Load into magnetic trap
    sq.find('liquid crystal bragg').set(-3);
    sq.find('3D mot amp ttl').set(0);
    sq.find('MOT coil ttl').set(1);
    sq.find('3D coils').set(2);
    sq.find('mw amp ttl').set(1);   %Turn on MW once bias fields have reached their final values
    sq.find('3d trap shutter').set(1);

    %% Microwave evaporation
    sq.delay(20e-3);
    evapRate = 0.2;
    evapStart = 7.3;
    evapEnd = 7.95;
    Tevap = (evapEnd-evapStart)/evapRate;
%     Tevap = 3.2;
    t = linspace(0,Tevap,100);
    sq.find('mw freq').after(t,sq.linramp(t,evapStart,evapEnd));
    sq.delay(Tevap);
    
    %% Weaken trap while MW frequency fixed
    Trampcoils = 180e-3;
    t = linspace(0,Trampcoils,100);
    sq.find('3d coils').after(t,sq.minjerk(t,sq.find('3d coils').values(end),0.708));
    sq.find('bias e/w').after(t,sq.minjerk(t,sq.find('bias e/w').values(end),0));
    sq.find('bias n/s').after(t,sq.minjerk(t,sq.find('bias n/s').values(end),0));
    sq.find('bias u/d').after(t,sq.minjerk(t,sq.find('bias u/d').values(end),0));
    sq.delay(Trampcoils);
    
    %% Optical evaporation
    %Ramp down magnetic trap in 1.01 s
    Trampcoils = 1.01;
    t = linspace(0,Trampcoils,100);
    sq.find('3d coils').after(t,sq.linramp(t,sq.find('3d coils').values(end),motCoilOff));
    sq.find('mw amp ttl').anchor(sq.find('3d coils').last).before(100e-3,0);
    sq.find('mot coil ttl').at(sq.find('3d coils').last,0);
    
    %At the same time, start optical evaporation
    sq.delay(30e-3);
    Tevap = 1.97;
    t = linspace(0,Tevap,300);
    sq.find('50W amp').after(t,sq.expramp(t,sq.find('50w amp').values(end),P50(varargin{3}),0.5));
    sq.find('25W amp').after(t,sq.expramp(t,sq.find('25w amp').values(end),P25(varargin{3}),0.5));
    sq.delay(Tevap);
%     Tramp = 0.1;
%     t = linspace(0,Tramp,100);
%     sq.find('50W amp').after(t,sq.minjerk(t,sq.find('50w amp').values(end),P50(varargin{3}+0.05)));
%     sq.find('25W amp').after(t,sq.minjerk(t,sq.find('25w amp').values(end),P25(varargin{3}+0.05)));
%     sq.delay(Tramp);

    %% Drop atoms
%     sq.delay(3.2);
    timeAtDrop = sq.time; %Store the time when the atoms are dropped for later
    sq.anchor(timeAtDrop);
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
        k = 2*pi*384.229e12/const.c;
        vrel = abs(2*const.hbar*k/const.mRb);
        g = 9.795;
        chirp = 25.1e6;
%         chirp = varargin{6};
        T = 10e-3;
        Tasym = 000e-6;
        if Tasym == 0
            dsep = 1.5e-3;
            Tsep = dsep/vrel;
        else  
            Tsep = 1*abs(const.mRb*pi*varargin{2}/(4*braggOrder*k^2*const.hbar*Tasym));
        end
        t0 = varargin{2} - 2*T - Tsep;
        if t0 < 30e-3
            warning('Initial Bragg pulse occurs at %.1f ms and will be clamped to 30 ms!',t0*1e3);
        end
        t0 = max(t0,30e-3);

        t0 = 50e-3;
%         T = 1e-3;
%         sq.find('Raman Amp').at(timeAtDrop,5).after(t0-0.15e-3,0).after(0.15e-3*2,5);
%         sq.find('Liquid crystal Bragg').after(t0+0.1e-3,3);
%         sq.find('3d trap shutter').after(t0-5e-3,0).after(5e-3,1);
        
        fprintf(1,'t0 = %0.6f ms\n',t0*1e3);
        makeBraggSequence(sq.dds,'k',k,'dt',1e-6,'t0',t0,'T',T,...
            'width',30e-6,'Tasym',Tasym,'phase',[0,0,varargin{5}],'chirp',chirp,...
            'power',varargin{4}*[1,0,0],'order',braggOrder);
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
    makeImagingSequence(sq,'type','drop 2','tof',varargin{2},...
        'repump Time',100e-6,'pulse Delay',00e-6,...
        'imaging freq',imageVoltage,'repump delay',10e-6,'repump freq',4.3,...
        'manifold',1);

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

function makeImagingSequence(sq,varargin)
    imgType = 'in-trap';
    pulseTime = [];
    repumpTime = 100e-6;
    repumpDelay = 00e-6;
    fibreSwitchDelay = 20e-3;
    camTime = 100e-6;
    pulseDelay = 0;
    cycleTime = 40e-3;
    repumpFreq = 4.3;
    imgFreq = 8.5;
    manifold = 1;
    includeDarkImage = false;
    if mod(numel(varargin),2) ~= 0
        error('Input arguments must be in name/value pairs');
    else
        for nn = 1:2:numel(varargin)
            p = lower(varargin{nn});
            v = varargin{nn+1};
            switch p
                case 'tof'
                    tof = v;
                case 'type'
                    imgType = v;
                case 'pulse time'
                    pulseTime = v;
                case 'repump time'
                    repumpTime = v;
                case 'repump delay'
                    repumpDelay = v;
                case 'pulse delay'
                    pulseDelay = v;
                case 'cycle time'
                    cycleTime = v;
                case 'cam time'
                    camTime = v;
                case 'repump freq'
                    repumpFreq = v;
                case 'imaging freq'
                    imgFreq = v;
                case 'fibre switch delay'
                    fibreSwitchDelay = v;
                case 'manifold'
                    manifold = v;
                case 'includedarkimage'
                    includeDarkImage = v;
                otherwise
                    error('Unsupported option %s',p);
            end
        end
    end
    
    switch lower(imgType)
        case {'in trap','in-trap','trap','drop 1'}
            camChannel = 'cam trig';
            imgType = 0;
            if isempty(pulseTime)
                pulseTime = 30e-6;
            end
        case {'drop 2'}
            camChannel = 'drop 1 camera trig';
            imgType = 1;
            if isempty(pulseTime)
                pulseTime = 14e-6;
            end
        otherwise
            error('Unsupported imaging type %s',imgType);
    end
    
    %Preamble
    sq.find('imaging freq').set(imgFreq);

    %Repump settings - repump occurs just before imaging
    %If manifold is set to image F = 1 state, enable repump. Otherwise,
    %disable repumping
    if imgType == 0 && manifold == 1
        sq.find('liquid crystal repump').set(-2.22);
        sq.find('repump amp ttl').after(tof-repumpTime-repumpDelay,1);
        sq.find('repump amp ttl').after(repumpTime,0);
        if ~isempty(repumpFreq)
            sq.find('repump freq').after(tof-repumpTime-repumpDelay,repumpFreq);
        end
    elseif imgType == 1 && manifold == 1
        sq.find('liquid crystal repump').set(7);
        sq.find('drop repump').after(tof-repumpTime-repumpDelay,1);
        sq.find('drop repump').after(repumpTime,0);
        sq.find('fiber switch repump').after(tof-fibreSwitchDelay,1);   
        if ~isempty(repumpFreq)
            sq.find('drop repump freq').after(tof-repumpTime-repumpDelay,4.3);
        end
    end
     
    %Imaging beam and camera trigger for image with atoms
    sq.find('Imaging amp ttl').after(tof+pulseDelay,1);
    sq.find(camChannel).after(tof,1);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find(camChannel).after(camTime,0);
    sq.anchor(sq.latest);
    sq.delay(cycleTime);
    
    %Take image without atoms
    sq.find('Imaging amp ttl').after(pulseDelay,1);
    sq.find(camChannel).set(1);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find(camChannel).after(camTime,0);
    sq.anchor(sq.latest);
    sq.find('fiber switch repump').set(0);
    
    if includeDarkImage
        %Take dark image
        sq.delay(cycleTime);
        sq.find('Imaging amp ttl').after(pulseDelay,0);
        sq.find(camChannel).set(1);
        sq.find('imaging amp ttl').after(pulseTime,0);
        sq.find(camChannel).after(camTime,0);
        sq.anchor(sq.latest);
        sq.find('fiber switch repump').set(0);
    end
    
end