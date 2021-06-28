function TempMeasNew(r)
%note that you have to change the area of interest in Abs_Analysis


if r.isInit()
    r.data.tof = (2:3:9)*10^-3;
    r.numRuns = numel(r.data.tof);
    tRaman = 5.9e-3;
    %Make Sequence you want to scan
    r.makerCallback = @RadiCOOLMagRamanImageAll;
    
elseif r.isSet()
    r.make(r.data.tof(r.currentRun));
    r.upload;
    
    fprintf(1,'Run %d/%d TOF: %.3f ms\n',r.currentRun,r.numRuns,r.data.tof(r.currentRun)*1e3);
    
elseif r.isAnalyze()
    nn = r.currentRun;
    c = Abs_Analysis('last');   %Get current image
    tRaman = 5.9e-3;
    %Get x and y widths
    r.data.xwidth(nn,1) = c.gaussWidth(1);
    r.data.ywidth(nn,1) = c.gaussWidth(2);
    
    %Plot data
    figure(13);
    clf;
    plot(r.data.tof(1:nn)+tRaman,r.data.xwidth(1:nn),'o-');
    hold on
    plot(r.data.tof(1:nn)+tRaman,r.data.ywidth(1:nn),'sq-');
    hold off;
    legend('X width','Y width');
    title(char(datetime))
    
    %Fit at end of run
    if r.currentRun == r.numRuns
        tRaman = 5.9e-3;
        %Create fit objects
        lfx = linfit(r.data.tof+tRaman,r.data.xwidth.^2,2*r.data.xwidth.*20e-6);
        lfy = linfit(r.data.tof+tRaman,r.data.ywidth.^2,2*r.data.ywidth.*20e-6);
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
        legend('X width','Y width');
        title(char(datetime))
        
        %Get temperature
        Tx = px(2)*const.mRb/const.kb;
        Ty = py(2)*const.mRb/const.kb;
        
        annotation('textbox',[0.197,0.84,0.2,0.042],'string',sprintf('Tx = %.3e, Ty = %.3e',Tx,Ty));
        
        
    end
    
    
end
end