function sq = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;

    %% Set up the MOT loading values
    Tmot = 6;                           %6 s MOT loading time
    sq.find('MOT coil TTL').set(1);     %Turn on the MOT coils
    sq.find('bias u/d').set(varargin{1});
    sq.anchor(sq.latest+Tmot);

    %% Compressed MOT stage
    %Turn off the 2D MOT and push beam just before the CMOT stage
    sq.find('2D MOT Amp TTL').before(10e-3,0);
    sq.find('push amp ttl').before(10e-3,0);
    
    %Increase the cooling and repump detunings to reduce re-radiation
    %pressure, and weaken the trap
    sq.find('3D MOT freq').set(5.6);
    sq.find('repump freq').set(2.5);
    sq.find('3D coils').set(0.12);
    sq.find('bias e/w').set(0);
    sq.find('bias n/s').set(0.5);
%     sq.find('bias u/d').set(0);
    
    Tcmot = 16e-3;
    sq.anchor(sq.latest+Tcmot);

    %% PGC stage
    Tpgc = 20e-3;
    t = linspace(0,Tpgc,100);
    f = @(vi,vf) sq.minjerk(t,vi,vf);

    sq.find('3D MOT amp').after(t,f(5,2.95));
    sq.find('3D MOT freq').after(t,f(5.6,5));
    
    sq.find('repump freq').after(t,2.5+(2.3-2.5)*t/Tpgc);
    sq.find('3D coils').after(t,f(0.12,0.06));

    sq.anchor(sq.latest);
    sq.find('repump amp ttl').after(5e-3,0);
    sq.find('liquid crystal repump').after(5e-3,7);
    sq.find('3D mot amp ttl').after(6e-3,0);
    sq.find('50W TTL').after(6e-3,0);
    sq.find('25W TTL').after(6e-3,0);
    sq.find('MOT coil ttl').after(6e-3,0);
    sq.find('liquid crystal bragg').after(6e-3,-3.64);
    
    sq.anchor(sq.latest);
    
    sq.find('50W Amp').at(6.05,0.92);
    sq.find('25W Amp').at(6.05,1.974);
    sq.find('MW Freq').at(6.05,0);
    sq.find('liquid crystal repump').at(6.05,-2.22);

    %% Imaging stage
    tof = 26e-3;
%     tof = varargin{1};
    pulseTime = 100e-6;
    cycleTime = 100e-3;
    %Repump settings - repump occurs just before imaging
    sq.find('repump freq').after(tof-pulseTime,4.3);
    sq.find('repump amp ttl').after(tof-pulseTime,1);
    sq.find('repump amp ttl').after(pulseTime,0);
    
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





end