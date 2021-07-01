function varargout = testCamera(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    
    sq.find('3D MOT Amp TTL').set(1);
    sq.find('cam trig').set(0);
    sq.delay(1);
    sq.find('cam trig').set(1);
    sq.delay(50e-3);
    sq.find('cam trig').set(0);
    sq.find('3D MOT Amp TTL').set(0);
    
    %% Automatic start
    %If no output argument is requested, then compile and run the above
    %sequence
    if nargout == 0
        r = RemoteControl;
        r.upload(sq.compile);
%         r.run;
    else
        varargout{1} = sq;
    end

end

