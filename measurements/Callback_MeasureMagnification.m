function Callback_MeasureMagnification(r)

if r.isInit()
    r.data.tof = 1e-3:1e-3:15e-3;
    r.c.setup('var',r.data.tof);
elseif r.isSet()
    r.make(r.data.tof(r.c(1)),0.1).upload;
    fprintf(1,'Run %d/%d, TOF = %.3f\n',r.c.now,r.c.total,r.data.tof(r.c(1)));
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.25);
    img = Abs_Analysis('last',1);
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    
    r.data.N(i1,1) = img.get('N');
    r.data.pos(i1,:) = squeeze(img.get('pos'));
    figure(123);clf;
    plot(r.data.tof(1:i1)*1e3,r.data.pos,'o-');
    plot_format('Time of flight [ms]','Position [m]','',12);

    if r.c.done(1)
        lf = linfit(r.data.tof,r.data.pos(:,2),20e-6);
        lf.setFitFunc('poly',[0,2]);
        lf.fit
        hold on;
        plot(lf.x*1e3,lf.f(lf.x),'--','linewidth',2);
    end
end


end