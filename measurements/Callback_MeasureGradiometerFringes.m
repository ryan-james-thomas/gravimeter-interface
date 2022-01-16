function Callback_MeasureGradiometerFringes(r)

if r.isInit()
    r.data.run = 1:150;
    r.c.setup('var',r.data.run);
elseif r.isSet()
    
%     r.make(0,216.6e-3,1.5,0.215,r.data.phase(r.c(1)),r.data.T(r.c(2)));
    r.make(r.devices.opt);
    r.upload;
    fprintf(1,'Run %d/%d\n',r.c.now,r.c.total);
    
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);

    [nlf,N,phi,dout] = Gradiometer_Analysis_FMI;
    r.data.N(i1,:) = [N.N1,N.N2];
    r.data.phi(i1,:) = phi;
    r.data.d{i1,1} = dout;
    r.data.chi2(i1,1) = nlf.gof.chi2;
    tmp = nlf.get('T');
    r.data.T(i1,1) = tmp(1);
    
    figure(97);clf;
    subplot(1,2,1);
%     plot(r.data.run(1:i1),r.data.phi(1:i1,:),'o-');
    plot(r.data.phi(1:i1,1),r.data.phi(1:i1,2),'o');
    grid on;
    plot_format('Phase 1 [rad]','Phase 2 [rad]','',12);
    subplot(1,2,2);
    plot(r.data.run(1:i1),diff(r.data.phi(1:i1,:),1,2),'o-');
    grid on;
    plot_format('Run','Differential phase [rad]','',12);

    
end