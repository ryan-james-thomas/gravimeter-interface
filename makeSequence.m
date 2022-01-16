function varargout = makeSequence(varargin)
    %% Parse input arguments
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
    %% Create a BEC
    P25 = opt.P25;
    P50 = opt.P50;
    %
    % Imaging detuning. Gives voltage for detuning in MHz
    %
    imageVoltage = -opt.detuning*0.472/6.065 + 8.533;
    %     imageVoltage = varargin{1};
    %
    % Voltage value that guarantees that the MOT coils are off
    %
    motCoilOff = -0.2;
    sq = makeBEC(opt);
    
    %% Trap manipulation to get smaller momentum width 
    T = 200e-3;
    t = linspace(0,T,100);
%     sq.find('50W amp').after(t,sq.minjerk(t,P50(opt.final_dipole_power),P50(0.08)));
%     sq.find('25W amp').after(t,sq.minjerk(t,P25(opt.final_dipole_power),P25(2.98-0.05)));
    sq.find('50W amp').after(t,sq.minjerk(t,P50(opt.final_dipole_power),P50(0.00)));
    sq.find('25W amp').after(t,sq.minjerk(t,P25(opt.final_dipole_power),P25(3.005)));
    sq.delay(T);  
    
    %% Drop atoms
%     sq.delay(200e-3);
    timeAtDrop = sq.time; %Store the time when the atoms are dropped for later
    sq.anchor(timeAtDrop);
    sq.find('3D mot amp ttl').set(0);
%     sq.find('bias e/w').before(200e-3,0);
    sq.find('bias n/s').before(200e-3,0);
    sq.find('bias u/d').before(200e-3,0);
    sq.find('mw amp ttl').set(0);
    sq.find('mot coil ttl').set(0);
    sq.find('3D Coils').set(motCoilOff);
    sq.find('25w ttl').set(0);
    sq.find('50w ttl').set(0);

    %% Interferometry
    enableDDS = 0;      %Enable DDS and DDS trigger
    enableBragg = 1;    %Enable Bragg diffraction
    enableRaman = 0;    %Enable Raman transition
    enableGrad = 0;     %Enable gradiometry
    enableMW = 0;       %Enable microwave state preparation
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
%         sq.find('liquid crystal bragg').at(sq.find('Liquid crystal Bragg').last,-2); %Use this to get a little more light on the phase lock PD
        braggOrder = 1;
        k = 2*pi*384229441689483/const.c;  %Frequency of Rb-85 F=3 -> F'=4 transition
        vrel = abs(2*const.hbar*k/const.mRb);
        dv = 700e-6/216.5e-3;
        chirp = opt.chirp;
        T = opt.Tint;
        Tasym = opt.Tasym;
        %
        % Calculate seperation time - this depends only on the asymmetry,
        % bragg order, and time of flight.
        %
        if Tasym == 0
            dsep = 2*dv*opt.tof;
            Tsep = dsep/vrel;
        else  
            Tsep = 1*abs(const.mRb*pi*opt.tof/(4*braggOrder*k^2*const.hbar*Tasym));
        end
        % Override the calculated separation time if specified by user
        if ~isempty(opt.Tsep)
            Tsep = opt.Tsep;
        end
        %
        % Calculate when the initial pulse should arrive
        %
        if enableGrad
            if isempty(opt.t0)
                t0 = 30e-3;
            else
                t0 = opt.t0;
            end
            
            if isempty(opt.ti)
                ti = opt.tof - t0 - Tasym - Tsep - 2*T;
            else
                ti = opt.ti;
            end
            
            
        else
            if isempty(opt.t0)
                t0 = opt.tof - 2*T - Tsep - Tasym;
            else
                t0 = opt.t0;
            end
        end
        
%         if numel(t0) > 1
%             error('Unable to determine t0!');
%         elseif t0 < 30e-3
%             warning('Initial Bragg pulse occurs at %.1f ms and will be clamped to 30 ms!',t0*1e3);
%         end
%         t0 = max(t0,30e-3);
        if enableGrad
            fprintf(1,'t0 = %0.3f ms, ti = %0.3f ms, Tsep = %0.3f ms\n',t0*1e3,ti*1e3,Tsep*1e3);
        else
            fprintf(1,'t0 = %0.3f ms, Tsep = %0.3f ms\n',t0*1e3,Tsep*1e3);
        end

        if enableGrad
            makeBraggSequence(sq.dds,'k',k,'dt',1e-6,'t0',t0,'T',T,...
                'width',30e-6,'Tasym',0,'phase',[0,0,0],'chirp',chirp,...
                'power',opt.bragg_power*[1,0,0],'order',braggOrder);
            
            sq.dds.anchor(timeAtDrop);
            makeBraggSequence(sq.dds,'k',k,'dt',1e-6,'t0',ti + t0,'T',T,...
                'width',30e-6,'Tasym',Tasym,'phase',[0,0,opt.final_phase],'chirp',chirp,...
                'power',opt.bragg_power*[1,2,1],'order',braggOrder);
        else
            makeBraggSequence(sq.dds,'k',k,'dt',1e-6,'t0',t0,'T',T,...
                'width',40e-6,'Tasym',Tasym,'phase',[0,0,opt.final_phase],'chirp',chirp,...
                'power',opt.bragg_power*[1,2,1],'order',braggOrder);
            
%             [amp,ph,freq,flags,t] = makeBraggSequence_pl('t0',t0,'T',T,'fwhm',40e-6,...
%                 'power',opt.bragg_power*[1,0,0],'phase',2*[0,0,opt.final_phase]*pi/180,...
%                 'usehold',0,'holdfreq',2,'holdamp',0.04);
%             pl = PhaseLock('192.168.1.38');
%             pl.setDefaults;
%             pl.amp(1).set(0);
%             pl.amp(2).set(0);
%             pl.useManual.set(0);
%             pl.disableExtTrig.set(0);
%             pl.shift.set(3);
%             pl.upload;
%             pl.uploadTiming(t,ph,amp,freq,flags);
            
        end
        
        
    end
    
    if enableDDS && enableRaman
        %
        % Start by re-anchoring the internal pointer for the DDS channels at the
        % drop time.  I do this to make referencing the time at which the Raman
        % pulse occurs easier to calculate
        %
        sq.dds.anchor(timeAtDrop);
        sq.find('Bias N/S').at(timeAtDrop - 5e-3,10);
        %
        % This makes a Gaussian pulse with the specified parameters: centered at
        % 't0' with FWHM of 'width', a maximum power of 'power', and the channel
        % 2 frequency 'df' higher than channel 1.
        %
        t0 = 0.1e-3;
%         makeGaussianPulse(sq.dds,'t0',t0,'width',opt.raman_width,'dt',5e-6,...
%             'power',opt.raman_power,'df',opt.raman_df,'power2',0);
        %
        % Turn on the amplifier for the Raman AOM. Keep in mind that the
        % internal pointer for Raman Amp is still at timeAtDrop
        %
        sq.find('raman amp').before(0.5e-3,10);    %This is an analog value, so set to 5 V to turn on
        T = opt.raman_width;
        t = linspace(0,T,10);
        sq.dds(1).after(t,DDSChannel.DEFAULT_FREQ,opt.raman_power,0);
        sq.dds(2).after(t,DDSChannel.DEFAULT_FREQ + opt.raman_df,opt.raman_power*0,0);
        sq.find('Bias N/S').after(t,10*ones(size(t)));
        sq.delay(T);
        sq.dds(1).set(DDSChannel.DEFAULT_FREQ,0.0,0);
        sq.dds(2).set(DDSChannel.DEFAULT_FREQ,0.0,0);
        sq.find('Raman amp').set(0);
        sq.find('Bias N/S').set(0);
    end
    
    if enableMW
        %
        % Apply a pair of microwave pulses to effect the transfers
        % |F=1,m=-1> -> |F=2,m=0> -> |F=1,m=0>.  The first pulse is applied
        % 10 ms after the atoms are dropped to minimize any possible
        % state-changing collisions.  The "R&S list step trig" skips to the
        % next frequency on the rising edge and resets the list on the
        % falling edge
        %
        sq.anchor(timeAtDrop);
        sq.find('bias e/w').set(10);
        sq.delay(20e-3);
        sq.find('state prep ttl').set(1);
        sq.delay(325e-6);
        sq.find('state prep ttl').set(0);
        
        sq.find('Repump Amp TTL').set(1).after(1e-3,0);
        sq.find('Liquid Crystal Repump').set(-2.22).after(1e-3,7);
        sq.find('repump freq').set(4.3);

        sq.find('R&S list step trig').set(1);
        sq.delay(5e-3);
        sq.find('state prep ttl').set(1);
        sq.delay(215e-6);
        sq.find('state prep ttl').set(0);
        
        sq.find('R&S list step trig').set(0);
        sq.find('bias e/w').set(0);
        %
        % Remove any remaining atoms in the F = 2 manifold
        %
        sq.find('3D MOT Amp TTL').set(1).after(10e-6,0);
    else
        sq.find('bias e/w').at(timeAtDrop,0);
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
        sq.find('3d coils').after(t,sq.linramp(t,motCoilOff,0.275));
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
    if strcmpi(opt.imaging_type,'drop 1') || strcmpi(opt.imaging_type,'drop 2')
        makeImagingSequence(sq,'type',opt.imaging_type,'tof',opt.tof,...
            'repump Time',100e-6,'pulse Delay',00e-6,...
            'imaging freq',imageVoltage,'repump delay',10e-6,'repump freq',4.3,...
            'manifold',1);
    elseif strcmpi(opt.imaging_type,'drop 3') || strcmpi(opt.imaging_type,'drop 4')
        makeFMISequence(sq,'tof',opt.tof,'offset',30e-3,'duration',100e-3,...
            'imaging freq',imageVoltage,'manifold',1);
    end

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
