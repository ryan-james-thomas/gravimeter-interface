function Callback_OptimizeFMIFrequency(r)

if r.isInit()
    %Initialize run
    r.data.param = const.randomize(20:0.25:35);
    r.c.setup('var',r.data.param);
    
    r.makerCallback = @makeSequence;
elseif r.isSet()
    %Build/upload/run sequence
    r.make(r.data.param(r.c(1)),730e-3,1.55,0.135,0,1e-3);
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, Param = %.3f\n',r.c.now,r.c.total,...
        r.data.param(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    
    [nlf,N] = FMI_Analysis;
    r.data.Nsum(i1,1) = N.sum;
    r.data.Ntotal(i1,1) = N.total;
    r.data.amp(i1,1) = nlf.c(1,1) + nlf.c(2,1);
    
    figure(10);clf;
    subplot(1,2,1);
    errorbar(r.data.param(1:i1),r.data.Nsum(1:i1,1),0.025*r.data.Nsum(1:i1,1),'o');
    hold on
    errorbar(r.data.param(1:i1),r.data.Ntotal(1:i1,1),0.025*r.data.Ntotal(1:i1,1),'sq');
    plot_format('Detuning [MHz]','Integrated signal','',12);
    grid on;
    legend('Sum','Fit');
    subplot(1,2,2);
    errorbar(r.data.param(1:i1),r.data.amp(1:i1,1),0.025*r.data.amp(1:i1,1),'d');
    plot_format('Detuning [MHz]','Amplitude','',12);
    grid on;

end