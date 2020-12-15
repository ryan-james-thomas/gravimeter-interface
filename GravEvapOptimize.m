function GravEvapOptimize(r)

if r.isInit()
    %Initialize run
    r.data.param = const.randomize(0.1:0.1:1);
    r.numRuns = numel(r.data.param);
    r.makerCallback = @makeSequenceFull;
    r.data.matlabfiles.callback = fileread('GravEvapOptimize.m');
    r.data.matlabfiles.init = fileread('gravimeter-interface/initSequence.m');
    r.data.matlabfiles.sequence = fileread('gravimeter-interface/makeSequenceFull.m');
    r.data.matlabfiles.analysis = fileread('Abs_Analysis.m');
elseif r.isSet()
    %Build/upload/run sequence
    r.make(8.45,r.data.param(r.currentRun),217e-3);
    r.upload;
    r.data.sq(r.currentRun,1) = r.sq.data;
    %Print information about current run
    fprintf(1,'Run %d/%d, Parameter: %.3f\n',r.currentRun,r.numRuns,...
        r.data.param(r.currentRun));
    
elseif r.isAnalyze()
    nn = r.currentRun;
    pause(1.0); %Wait for other image analysis program to finish with files
    
    %Analyze image data from last image
    c = Abs_Analysis('last');
    r.data.files{nn,1} = c.raw.files(1).name;r.data.files{nn,2} = c.raw.files(2).name;
%     if c.N > 100e6
%         c.N = 0;
%     end
    r.data.N(nn,1) = c.N;
    r.data.Nth(nn,1) = c.N.*(1-c.becFrac);
    r.data.Nbec(nn,1) = c.N.*c.becFrac;
    r.data.F(nn,1) = c.becFrac;
    r.data.xw(nn,1) = c.gaussWidth(1);
    r.data.x0(nn,1) = c.pos(1);
    r.data.yw(nn,1) = c.gaussWidth(2);
    r.data.y0(nn,1) = c.pos(2);
    r.data.OD(nn,1) = c.fitdata.params.gaussAmp(1);
    r.data.T(nn,:) = c.T;
    r.data.becWidth(nn,:) = c.becWidth;
    
    figure(10);clf;
%     subplot(1,2,1);
%     errorbar(r.data.param(1:nn),r.data.Nth/1e6,0.05*r.data.Nth/1e6,'o');
%     hold on;
%     errorbar(r.data.param(1:nn),r.data.Nbec/1e6,0.05*r.data.Nbec/1e6,'sq');
    errorbar(r.data.param(1:nn),r.data.N/1e6,0.05*r.data.N/1e6,'o');
    plot_format('Parameter','Number of atoms \times 10^6','',12);
%     ylim([0,50]);
    grid on;
%     subplot(1,2,2);
%     plot(r.data.param(1:nn),[r.data.T,sqrt(prod(r.data.T,2))]*1e6,'o');
%     plot_format('Parameter','Temperature [uK]','',12);
%     ylim([0,Inf]);
%     grid on;
end