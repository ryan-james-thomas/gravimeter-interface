function sq = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;

    %% Set up the MOT loading values
    Tmot = 6;
    
    sq.find('MOT coil TTL').set(1);
    sq.anchor(sq.latest+Tmot);

    %% Compressed MOT stage
    sq.find('2D MOT Amp TTL').set(0);
    sq.find('push amp ttl').set(0);
    
    sq.find('3D MOT freq').set(5.6);
    sq.find('repump freq').set(2.5);
    sq.find('Repump amp').set(2);
    sq.find('3D coils').set(0.12);
    sq.find('bias e/w').set(0);
    sq.find('bias n/s').set(0.5);
    sq.find('bias u/d').set(0);
    
    Tcmot = 16e-3;
    sq.anchor(sq.latest+Tcmot);

    %% PGC stage
    Tpgc = 20e-3;
    t = linspace(0,Tpgc,100);
    f = @(vi,vf) sq.minjerk(t,vi,vf);

    sq.find('3D MOT amp').after(t,f(5,2.95));
    sq.find('3D MOT freq').after(t,f(5.6,5));
    
    sq.find('repump freq').after(t,f(2.5,2.3));
    sq.find('3D coils').after(t,f(0.12,0.06));

    sq.anchor(sq.latest);

    sq.find('3D MOT Amp TTL').set(0);
    sq.find('3D mot amp ttl').after(6e-3,0);
    
    sq.anchor(sq.latest);

    %% Imaging stage
    tof = 20e-3;
    pulseTime = 30e-6;
    cycleTime = 20e-3;
    sq.find('Imaging amp ttl').after(tof,1);
    sq.find('repump freq').after(tof,2.6);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find('Imaging amp ttl').after(cycleTime,1);
    sq.find('imaging amp ttl').after(pulseTime,0);





end