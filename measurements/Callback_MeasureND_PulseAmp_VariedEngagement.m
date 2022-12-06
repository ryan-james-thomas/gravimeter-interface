function Callback_MeasureND_PulseAmp_VariedEngagement(r)

if r.isInit()
    r.data.amp = const.randomize(0.15:0.05:0.4);
    r.data.enable = [0,1];
    r.c.setup('var',r.data.enable,r.data.amp,1:4);
elseif r.isSet()
    r.devices.fb.enable = r.data.enable(r.c(1));
    r.devices.fb.upload('enable');
    r.make(r.devices.opt,'keopsys',0.73,'detuning',0,'load_time',15,'nd',{'pulse_amp',r.data.amp(r.c(2))}).upload;
    fprintf(1,'Run %d/%d\n',r.c.now,r.c.total);
    fprintf('Amp = %.2f\n',r.data.amp(r.c(2)));
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    i3 = r.c(3);
    pause(0.5 + 0.25*rand);
    img = Abs_Analysis_FB('last',1);
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    elseif r.c.now > 1 && strcmpi(img.raw.files.name,r.data.files{r.c.now - 1}.name)
        r.c.decrement;
        pause(10);
        return;
    end
    
    r.data.files{i1,i2,i3} = img.raw.files;
    r.data.N(i1,i2,i3) = img.get('N');
    r.data.becFrac(i1,i2,i3) = img.get('becFrac');
    r.data.OD(i1,i2,i3) = img.get('peakOD');
    r.data.T(i1,i2,i3) = prod(squeeze(img.get('T')))^0.5;
    r.data.x(i1,i2,i3) = img.clouds.pos(1);
    r.data.y(i1,i2,i3) = img.clouds.pos(2);

    if r.c.done(1)
        figure(98);clf;
        plot(r.data.amp(1:i2),r.data.T(1,1:i2,i3)*1e9,'o');
        hold on
        plot(r.data.amp(1:i2),r.data.T(2,1:i2,i3)*1e9,'sq');
        if r.c.done(2) && i3 > 1
            errorbar(r.data.amp,mean(r.data.T(1,:,1:i3)*1e9,3),std(r.data.T(1,:,1:i3),0,3),'o');
            errorbar(r.data.amp,mean(r.data.T(2,:,1:i3)*1e9,3),std(r.data.T(2,:,1:i3),0,3),'sq');
        end
    end
    
end


end