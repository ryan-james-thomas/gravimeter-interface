function Callback_MeasureTrapFrequency(r)

if r.isInit()
    %Initialize run
%     r.data.param = [2.5e-3:2.5e-3:50e-3];
    r.data.param = 1e-3:1e-3:30e-3;
    r.c.setup('var',r.data.param);
    
    r.makerCallback = @makeSequence;
elseif r.isSet()
    %Build/upload/run sequence
    r.make(0,216.5e-3,1.48,r.data.param(r.c(1)));
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, Delay = %.3f ms\n',r.c.now,r.c.total,...
        r.data.param(r.c(1))*1e3);
    
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);
    img = Abs_Analysis('last');
    if ~img.raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    
    r.data.w(i1,:) = img.clouds(1).becWidth;
    r.data.files{i1,1} = img.raw.files;
    
    figure(11);clf;
    plot(r.data.param(1:i1)*1e3,1e6*r.data.w(1:i1,:),'o-');
    grid on;
    plot_format('Delay [ms]','Width [um]','',12);
    legend('x','y');

end