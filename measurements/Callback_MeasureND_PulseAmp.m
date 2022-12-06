function Callback_MeasureND_PulseAmp(r)

if r.isInit()
    r.data.amp = const.randomize(0.1:0.1:1);
    r.c.setup('var',r.data.amp,1:4);
elseif r.isSet()
    r.make(r.devices.opt,'keopsys',0.73,'detuning',0,'load_time',15,'nd',{'pulse_amp',r.data.amp(r.c(1))}).upload;
    fprintf(1,'Run %d/%d\n',r.c.now,r.c.total);
    fprintf('Amp = %.2f\n',r.data.amp(r.c(1)));
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
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
    
    r.data.files{i1,i2} = img.raw.files;
    r.data.N(i1,i2) = img.get('N');
    r.data.becFrac(i1,i2) = img.get('becFrac');
    r.data.OD(i1,i2) = img.get('peakOD');
    r.data.T(i1,i2) = prod(squeeze(img.get('T')))^0.5;
    r.data.x(i1,i2) = img.clouds.pos(1);
    r.data.y(i1,i2) = img.clouds.pos(2);

    figure(98);clf;
    subplot(1,3,1);
    plot(r.data.amp(1:i1),r.data.N(1:i1,i2),'o');
    ylim([0,Inf]);
    grid on
    plot_format('Amp','Number','',10);
    subplot(1,3,2);
    plot(r.data.amp(1:i1),r.data.T(1:i1,i2)*1e9,'o');
    ylim([0,Inf]);
    grid on
    plot_format('Amp','Temperature [nK]','',10);
    subplot(1,3,3);
    plot(r.data.amp(1:i1),r.data.becFrac(1:i1,i2),'o');
    ylim([0,Inf]);
    grid on
    plot_format('Amp','BEC fraction','',10);
end


end