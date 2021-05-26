function varargout = testBraggPulses(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    
    sq.delay(50e-3);
    timeAtDrop = sq.time;

    %% Interferometry
    % Issue falling-edge trigger for MOGLabs DDS box
    sq.find('dds trig').before(10e-3,1);
    sq.find('dds trig').after(10e-3,0); %MOGLabs DDS triggers on falling edge
    sq.find('dds trig').after(10e-3,1);
    
    % Create a sequence of Bragg pulses. The property ddsTrigDelay is used
    % in compiling the DDS instructions and making sure that they start at
    % the correct time.
    sq.ddsTrigDelay = timeAtDrop;   
    k = 2*pi*384.224e12/const.c;
    T = 1e-3;
    t0 = 2e-3;

    makeBraggSequence(sq.dds,'k',k,'dt',1e-6,'t0',t0,'T',T,...
        'width',30e-6,'Tasym',0,'phase',[180,90,90],'chirp',0,...
        'power',0.1*[1,1,1],'order',1);
    
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

