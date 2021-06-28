function GravImagingFreq(r)

if r.isInit()
    r.data.tof = 217e-3;
    r.data.freq = const.randomize(4:0.1:4.6);
    r.numRuns = numel(r.data.freq);
    r.makerCallback = @makeSequenceFull;
    
    r.data.matlabfiles.callback = fileread('GravImagingFreq.m');
    r.data.matlabfiles.init = fileread('gravimeter-interface/initSequence.m');
    r.data.matlabfiles.sequence = fileread('gravimeter-interface/makeSequenceFull.m');
    r.data.matlabfiles.analysis = fileread('Abs_Analysis.m');
elseif r.isSet()
    
    r.make(8.45,r.data.freq(r.currentRun),r.data.tof);
    r.upload;
    fprintf(1,'Run %d/%d, Repump: %.3f V\n',r.currentRun,r.numRuns,r.data.freq(r.currentRun));
    
elseif r.isAnalyze()
    nn = r.currentRun;
    pause(1);
    c = Abs_Analysis('last');
    pause(0.1);
    r.data.N(nn,1) = c.N;
    r.data.images(:,:,nn) = c.image;
    
    nlf = nonlinfit(r.data.freq(1:nn),r.data.N(1:nn)/1e6,0.05*r.data.N(1:nn)/1e6+0.05);
    nlf.setFitFunc(@(A,x0,G,y0,x) A./(1+4*((x-x0)/G).^2)+y0);
    nlf.bounds([0,7.5,0,-0.01],[10,9.5,1,0.1],[1,8.5,0.5,0]);
    figure(10);clf;
%     if nn < 4
        errorbar(nlf.x,nlf.y,nlf.dy,'o');
        plot_format('Voltage [V]','Number of atoms \times 10^6','',12);
%     else
%         nlf.fit;
%         nlf.plot;
%         r.data.nlf = nlf;
%         fprintf(1,'Resonance: %.3f +/- %.3f, Width: %.3f +/- %.3f\n',nlf.c(2,:),nlf.c(3,:));
%     end
    
    
    
end