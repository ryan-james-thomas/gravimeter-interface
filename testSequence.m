function varargout = testSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    sq.delay(500e-3);
    sq.find('mw amp ttl').set(1);
    sq.find('state prep ttl').set(1);
    sq.delay(1e-3);
    sq.find('mw amp ttl').set(0);
    sq.delay(1e-3);
    sq.delay(5e-3);
    sq.find('mw amp ttl').set(1);
    sq.delay(0.5e-3);
    sq.find('mw amp ttl').set(0);
    sq.delay(1e-3);
    sq.find('state prep ttl').set(0);
    sq.delay(500e-3);
    sq.find('mw amp ttl').set(0);
    sq.find('state prep ttl').set(0);
    
    
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

