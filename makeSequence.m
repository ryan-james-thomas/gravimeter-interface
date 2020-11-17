function sq = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;

    %% Set up the MOT loading values
    sq.find('2D MOT Freq').at(0,4);
    sq.find('push freq').at(0,3);

    sq.find('3D MOT Freq').at(0,3);
    sq.find('repump freq').at(0,3);
    sq.find('3D MOT amp').at(0,3);
    sq.find('repump amp').at(0,3);

    sq.find('3D coils').at(0,2);
    sq.find('bias e/w').at(0,0);
    sq.find('bias N/S').at(0,0);
    sq.find('bias u/d').at(0,0);

    %% Compressed MOT stage
    Tmot = 6;
    sq.find('2D MOT Amp TTL').after(Tmot,0);
    sq.find('3D MOT freq').after(Tmot,4);
    sq.find('repump freq').after(Tmot,4);
    sq.find('Repump amp').after(Tmot,2);
    sq.find('3D coils').after(Tmot,1);

    %% PGC stage
    Tcmot = 20e-3;
    Tpgc = 20e-3;
    t = Tcmot + linspace(0,Tpgc,50);
    f = @(vi,vf) sq.minjerk(t,vi,vf);

    sq.find('3D MOT amp').after(t,f(3,1));
    sq.find('3D MOT freq').after(t,f(4,5));
    sq.find('repump freq').after(t,f(4,5);
    sq.find('3D coils').after(t,f(1,0));

    sq.channels.anchor(sq.latest);

    sq.find('3D MOT Amp TTL').after(0,0);

    %% Imaging stage
    tof = 20e-3;
    pulseTime = 30e-6;
    cycleTime = 20e-3;
    sq.find('Imaging amp ttl').after(tof,1);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find('Imaging amp ttl').after(cycleTime,1);
    sq.find('imaging amp ttl').after(pulseTime,0);





end