function Callback_MeasureImagingFrequency(r)

if r.isInit()
    r.data.tof = 20e-3;
    r.data.voltage = const.randomize([7:0.2:10,8.1:0.2:8.9]);
    r.c.setup('var',r.data.voltage);
elseif r.isSet()
    r.make(r.data.tof,r.data.voltage(r.c(1))).upload;
    fprintf(1,'Run %d/%d, Voltage = %.3f V\n',r.c.now,r.c.total,r.data.voltage(r.c(1)));
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);
    img = Abs_Analysis('last',1);
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    
    r.data.files{i1,1} = img.raw.files;
    r.data.N(i1,1) = img.get('N');
    r.data.pos(i1,:) = squeeze(img.get('pos'));
    figure(123);clf;
    plot(r.data.voltage(1:i1),r.data.N,'o');
    plot_format('Time of flight [ms]','Number [arb units]','',12);

    if r.c.done(1)
        nlf = nonlinfit(r.data.voltage,r.data.N/1e6,0.05*r.data.N/1e6 + 0.01);
        nlf.setFitFunc(@(A,w,x0,x) A./(1 + 4*(x-x0).^2/w^2));
        nlf.bounds2('A',[0,1e3,max(nlf.y)],'w',[0.1,2,0.5],'x0',[8,9,8.5]);
        nlf.fit
        hold on;
        xplot = linspace(min(lf.x),max(lf.x),1e2);
        plot(xplot,nlf.f(xplot)*1e6,'--','linewidth',2);
    end
end


end