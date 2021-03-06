function varargout = testBraggPulses(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    sq.dds(1).set(110,0,0);
    sq.delay(1);
    timeAtDrop = sq.time;

    %% Interferometry
    % Issue falling-edge trigger for MOGLabs DDS box
    sq.find('dds trig').before(10e-3,1);
    sq.find('dds trig').after(10e-3,0); %MOGLabs DDS triggers on falling edge
    sq.find('dds trig').after(1e-3,1);
    
    % Create a sequence of Bragg pulses. The property ddsTrigDelay is used
    % in compiling the DDS instructions and making sure that they start at
    % the correct time.
    sq.ddsTrigDelay = timeAtDrop;   
    sq.dds(1).set(110,0.2,0);
    sq.delay(5e-3);
    sq.dds(1).set(110,0,0);
    sq.delay(5e-3);
    
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

