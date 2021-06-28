function TempMeasNew(r)
%note that you have to change the area of interest in Abs_Analysis


if r.isInit()
    r.data.tof = (1:3:25)*10^-3;
    r.numRuns = numel(r.data.tof);
    
    %Make Sequence you want to scan
    r.makerCallback = @RhysMOT2;
    
elseif r.isSet()
    r.make(r.data.tof(r.currentRun));
    r.upload;
    
    fprintf(1,'Run %d/%d TOF: %.3f ms\n',r.currentRun,r.numRuns,r.data.tof(r.currentRun)*1e3);
    
elseif r.isAnalyze()
    nn = r.currentRun;
    c = Abs_Analysis('last');   %Get current image
    
    %Get x and y position
    r.data.xpos(nn,1) = c.pos(1);
    r.data.ypos(nn,1) = c.pos(2);
    
    %Plot data
    figure(23);
    clf;
    plot(r.data.tof(1:nn),r.data.xpos(1:nn),'o-');
    hold on
    plot(r.data.tof(1:nn),r.data.ypos(1:nn),'sq-');
    hold off;
    legend('X pos','Y pos');
    title(char(datetime))
    
    %Fit at end of run
    if r.currentRun == r.numRuns
        %Create fit objects
        lfx = linfit(r.data.tof,r.data.xpos,2*r.data.xpos.*20e-6);
        lfy = linfit(r.data.tof,r.data.ypos,2*r.data.ypos.*20e-6);
        lfx.setFitFunc('poly',[0,2]);
        lfy.setFitFunc('poly',[0,2]);
        %Do fit
        px = lfx.fit;
        py = lfy.fit;
        
        %Plot fits
%         hold on;
%         plot(lfx.x,lfx.f(lfx.x),'-');
%         plot(lfy.x,lfy.f(lfy.x),'-');
%         hold off;
        figure(24);
        clf;
        lfx.plot;
        lfy.plot;
        legend('X pos','Y pos');
        title(char(datetime))

        
        %Get temperature
        ax = px(2)*2;
        ay = py(2)*2;
        
        annotation('textbox',[0.0305,0.9415,0.2,0.042],'string',sprintf('ax = %.3e, ay = %.3e',ax,ay));
               
    end
    
    
end
end