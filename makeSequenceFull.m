function varargout = makeSequenceFull(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    %Enable optical dipole traps
    sq.find('50w ttl').set(1);
    sq.find('25w ttl').set(1);
    sq.find('50w amp').set(5);
    sq.find('25w amp').set(5);
    
    %% Set up the MOT loading values                
    sq.find('MOT coil TTL').set(1);     %Turn on the MOT coils
    sq.find('3d coils').set(0.42);
    sq.find('bias u/d').set(0);
    sq.find('bias e/w').set(0);
    sq.find('bias n/s').set(0);
    
    Tmot = 6;                           %6 s MOT loading time
    sq.delay(Tmot);                     %Wait for Tmot
    %% Compressed MOT stage
    %Turn off the 2D MOT and push beam 10 ms before the CMOT stage
    sq.find('2D MOT Amp TTL').before(10e-3,0);
    sq.find('push amp ttl').before(10e-3,0);
    
    %Increase the cooling and repump detunings to reduce re-radiation
    %pressure, and weaken the trap
    sq.find('3D MOT freq').set(6);
    sq.find('repump freq').set(2.4);
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
    sq.find('3D MOT Amp').after(t,f(5,2.88));
    sq.find('3D MOT Freq').after(t,f(6,3.2));
    sq.find('3D coils').after(t,f(0.15,0.02));
    sq.delay(Tpgc);
    
    %Turn off the repump field for optical pumping - 2 ms
    sq.find('repump amp ttl').set(0);
    sq.find('liquid crystal repump').set(7);
    sq.delay(2e-3);
    
    %% Load into magnetic trap
    sq.find('liquid crystal bragg').set(-3.64);
    sq.find('3D mot amp ttl').set(0);
    sq.find('MOT coil ttl').set(1);
    sq.find('3D coils').set(2);
    %Ramp the bias fields to improve loading
    T = 1e-3;
    t = linspace(0,T,10);
    sq.find('bias e/w').after(t,sq.linramp(t,sq.find('bias e/w').values(end),0));
    sq.find('bias n/s').after(t,sq.linramp(t,sq.find('bias n/s').values(end),6.5));
    sq.find('bias u/d').after(t,sq.linramp(t,sq.find('bias u/d').values(end),1));
    sq.delay(T);
    sq.find('mw amp ttl').set(1);   %Turn on MW once bias fields have reached their final values
    
    
    %% Microwave evaporation
    sq.delay(20e-3);
    Tevap = 3.25;
    t = linspace(0,Tevap,200);
    sq.find('mw freq').after(t,sq.linramp(t,6.8,7.85));
    sq.delay(Tevap);
    
    %% Weaken trap while MW frequency fixed
    Trampcoils = 180e-3;
    t = linspace(0,Trampcoils,100);
    sq.find('3d coils').after(t,sq.minjerk(t,sq.find('3d coils').values(end),0.708));
    sq.delay(Trampcoils);
    
    %% Optical evaporation
    %Ramp down magnetic trap in 1.01 s
    Trampcoils = 1.01;
    t = linspace(0,Trampcoils,100);
    sq.find('3d coils').after(t,sq.linramp(t,sq.find('3d coils').values(end),0));
    sq.find('mw amp ttl').anchor(sq.find('3d coils').last).before(100e-3,0);
    sq.find('mot coil ttl').at(sq.find('3d coils').last,0);
    
    %At the same time, start optical evaporation
    Tevap = 1.99;
    t = 30e-3 + linspace(0,Tevap,200);
    sq.find('50W amp').after(t,sq.expramp(t,5,0.9275,0.5));
    sq.find('25W amp').after(t,sq.expramp(t,5,1.7,0.5));
%     sq.find('25W amp').after(linspace(0,250e-3,100),@(t) sq.minjerk(t,sq.find('25w amp').values(end),1.75));
    sq.anchor(sq.latest);
    
    %% Drop atoms
    sq.anchor(sq.latest);
%     sq.delay(0.5);
    sq.find('mot coil ttl').set(0);
    sq.find('mw freq').set(0);
    sq.find('50w ttl').set(0);
    sq.find('25w ttl').set(0);
%     sq.find('liquid crystal repump').set(-2.22);
%     sq.find('imaging freq').set(varargin{1});
%     sq.find('repump amp').set(5);
%     sq.find('repump freq').set(8.3);
%     sq.find('repump amp ttl').after(15e-3,1);
%     sq.find('repump amp ttl').after(100e-6,0);
%     sq.find('liquid crystal repump').at(sq.find('repump amp ttl').last,7);

    %% Imaging stage
    makeImagingSequence(sq,'type','in trap','tof',varargin{end},...
        'repumpTime',100e-6,'pulseTime',30e-6,'pulseDelay',30e-6,...
        'imaging freq',varargin{1},'repumpdelay',20e-3);

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
    pulseTime = 30e-6;
    repumpTime = 100e-6;
    repumpDelay = 00e-6;
    camTime = 100e-6;
    pulseDelay = 0;
    cycleTime = 100e-3;
    repumpFreq = 4.3;
    imgFreq = 8.5;
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
                case 'pulsetime'
                    pulseTime = v;
                case 'repumptime'
                    repumpTime = v;
                case 'repumpdelay'
                    repumpDelay = v;
                case 'pulsedelay'
                    pulseDelay = v;
                case 'cycletime'
                    cycleTime = v;
                case 'camtime'
                    camTime = v;
                case 'repump freq'
                    repumpFreq = v;
                case 'imaging freq'
                    imgFreq = v;
                otherwise
                    error('Unsupported option %s',p);
            end
        end
    end
    
    switch lower(imgType)
        case {'in trap','in-trap','trap'}
            camChannel = 'cam trig';
            imgType = 0;
        case {'drop 1'}
            camChannel = 'drop 1 camera trig';
            imgType = 1;
        otherwise
            error('Unsupported imaging type %s',imgType);
    end
    
    %Preamble
    sq.find('imaging freq').set(imgFreq);

    %Repump settings - repump occurs just before imaging
    if imgType == 0
        sq.find('liquid crystal repump').set(-2.22);
        sq.find('repump amp ttl').after(tof-repumpTime-repumpDelay,1);
        sq.find('repump amp ttl').after(repumpTime,0);
        if ~isempty(repumpFreq)
            sq.find('repump freq').after(tof-repumpTime-repumpDelay,repumpFreq);
        end
    elseif imgType == 1
        sq.find('liquid crystal repump').set(7);
        sq.find('drop repump').after(tof-repumpTime-repumpDelay,1);
        sq.find('drop repump').after(repumpTime,0);
        sq.find('fiber switch repump').after(tof-repumpTime-repumpDelay,1);
        sq.find('fiber switch repump').after(repumpTime,0);     
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
    
end