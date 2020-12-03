function varargout = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;

    %% Set up the MOT loading values                
    sq.find('MOT coil TTL').set(1);     %Turn on the MOT coils
%     sq.find('3d coils').set(0.42);
    sq.find('bias u/d').set(0);
    sq.find('bias e/w').set(0);
    sq.find('bias n/s').set(0);
    
    Tmot = 6;                           %6 s MOT loading time
    sq.delay(Tmot);                     %Wait for Tmot
    %% Compressed MOT stage
    %Turn off the 2D MOT and push beam 10 ms before the CMOT stage
    sq.find('2D MOT Amp TTL').before(10e-3,0);
    sq.find('push amp ttl').before(10e-3,0);
    t = linspace(-10e-3,0,100);
    f = @(vi,vf) sq.minjerk(t,vi,vf);
%     sq.find('bias e/w').after(t,f(0,4));
%     sq.find('bias n/s').after(t,f(0,5));
%     sq.find('bias u/d').after(t,f(0,varargin{1}));
    
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
    sq.find('3D MOT Freq').after(t,f(6,2.9));
    sq.find('3D coils').after(t,f(0.15,0));
    %Linear ramp for these
%     sq.find('repump freq').after(t,2.5+(2.3-2.5)*t/Tpgc);

    %Wait 5 ms and then turn off the repump light
    sq.delay(Tpgc);
    sq.find('MOT coil ttl').set(0);
    
    sq.delay(varargin{1}/1000);
    sq.find('repump amp ttl').set(0);
    sq.find('liquid crystal repump').set(7);
%     sq.delay(Tpgc);

    %Wait 1 ms and then turn off the MOT light - optical pumping?
    sq.delay(2e-3);
    sq.find('3D mot amp ttl').set(0);
    sq.find('50W TTL').set(0);
    sq.find('25W TTL').set(0);
    
    sq.find('liquid crystal bragg').set(-3.64);
    
    %This command sets the internal sequence pointer for the last time to
    %the time of the last update
    sq.anchor(sq.latest);

    %I've added these commands because they seemed to be in the original
    %runs at 6.05 s for some reason
    sq.find('50W Amp').at(6.05,0.92);
    sq.find('25W Amp').at(6.05,1.974);
    sq.find('MW Freq').at(6.05,0);
    sq.find('liquid crystal repump').at(6.05,-2.22);

    %% Imaging stage
%     tof = 25e-3;
    tof = varargin{2};
    pulseTime = 100e-6;
    cycleTime = 100e-3;
    %Repump settings - repump occurs just before imaging
    sq.find('repump freq').after(tof-pulseTime,4.3);
    sq.find('repump amp ttl').after(tof-pulseTime,1);
    sq.find('repump amp ttl').after(pulseTime,0);
%     
    %Imaging beam and camera trigger for image with atoms
    sq.find('Imaging amp ttl').after(tof,1);
    sq.find('cam trig').after(tof,1);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find('cam trig').after(pulseTime,0);
    
    %Take image without atoms
    sq.find('Imaging amp ttl').after(cycleTime,1);
    sq.find('cam trig').after(cycleTime,1);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find('cam trig').after(pulseTime,0);
%     sq.find('repump amp ttl').after(t,1);
%     sq.find('repump amp ttl').after(pulseTime,0);


    if nargout == 0
        r = RemoteControl;
        r.upload(sq.compile);
        r.run;
    else
        varargout{1} = sq;
    end

end