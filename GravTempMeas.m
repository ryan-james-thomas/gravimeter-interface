function GravTempMeas(r)

if r.isInit()
    %Initialize run
    r.data.tof = 20e-3:2.5e-3:27.5e-3; 
    r.data.biasEW = 0:0.5:10;
    r.data.idx = [0,0];
    r.numRuns = numel(r.data.biasEW)*numel(r.data.tof);
elseif r.isSet()
    %Increment dual counter
    if r.data.idx(1) == 0 && r.data.idx(2) == 0
        r.data.idx = [1,1];
    elseif r.data.idx(2) == numel(r.data.tof)
        r.data.idx(1) = r.data.idx(1) + 1;
        r.data.idx(2) = 1;
    else
        r.data.idx(2) = r.data.idx(2) + 1;
    end
    %Build/upload/run sequence
    sq = makeSequence(r.data.biasEW(r.data.idx(1)),r.data.tof(r.data.idx(2)));
    sq.compile;
    r.data.sq(r.currentRun,1) = sq.data;
    r.upload(sq.data);
    %Print information about current run
    fprintf(1,'Run %d/%d, biasEW: %.3f V, TOF: %.1f ms\n',r.currentRun,r.numRuns,...
        r.data.biasEW(r.data.idx(1)),r.data.tof(r.data.idx(2))*1e3);
    
elseif r.isAnalyze()
    nn = r.currentRun;
    pause(2.0); %Wait for other image analysis program to finish with files
    
    %Analyze image data from last image
    c = Abs_Analysis('last');
    r.data.files{nn,1} = c.filenames{1};r.data.files{nn,2} = c.filenames{2};
    r.data.N(nn,1) = c.numAtoms;
    r.data.xw(nn,1) = c.zWidth;
    r.data.x0(nn,1) = c.zPos;
    r.data.yw(nn,1) = c.yWidth;
    r.data.y0(nn,1) = c.yPos;
    
    
    if r.data.idx(2) == numel(r.data.tof)
        %After recording the desired times-of-flight, analyze data
        %according to ballistic expansion model
        Ntof = numel(r.data.tof);
        lf = linfit(r.data.tof,r.data.yw(nn-Ntof+1:nn).^2,2*20e-6*r.data.yw(nn-Ntof+1:nn));
        lf.setFitFunc(@(x) [ones(size(x(:))) x(:).^2]);
        lf.fit;figure(4);clf;lf.plot;
        
        %Plot data
        r.data.T(r.data.idx(1),1) = lf.c(2,1)*const.mRb/const.kb;
        figure(10);clf;
        subplot(1,2,1);
        plot(r.data.biasEW(1:r.data.idx(1)),r.data.T*1e6,'o-');
        ylabel('Temperature [uK]');
        subplot(1,2,2);
        plot(r.data.biasEW(1:r.data.idx(1)),r.data.N(Ntof:Ntof:end)/1e6,'o-');
        ylabel('Number of atoms \times 10^6');
    end



end