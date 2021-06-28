function GravNParameterScan(r)

if r.isInit()
    %Initialize run
    r.data.tof = (20:5:35)*1e-3;
    r.data.verticalBias = (0:0.2:2);
    
    r.data.count = RolloverCounter([numel(r.data.tof),numel(r.data.verticalBias)]);
    r.numRuns = r.data.count.total;
    
    r.makerCallback = @makeSequence;
    
elseif r.isSet()
    %Increment counter
    if r.currentRun ~= 1
        r.data.count.increment;
    end
    
    %Build/upload/run sequence
    r.make(r.data.tof(r.data.count.idx(1)),r.data.verticalBias(r.data.count.idx(2)));
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, MOT, TOF: %.3f ms\n',r.currentRun,r.numRuns,r.data.tof(r.data.count.idx(1)));

elseif r.isAnalyze()
    % Make shorthand variables for indexing
    nn = r.currentRun;
    i1 = r.data.count.idx(1);
    i2 = r.data.count.idx(2);
    pause(1.0); %Wait for other image analysis program to finish with files
%     i2=1;
    %Analyze image data from last image
    c = Abs_Analysis('last');
    r.data.files{i1,i2} = c.raw.files(1).name;r.data.files{i1,i2} = c.raw.files(2).name;
    r.data.N(i1,i2) = c.N;
    r.data.Nth(i1,i2) = c.N.*(1-c.becFrac);
    r.data.Nbec(i1,i2) = c.N.*c.becFrac;
    r.data.F(i1,i2) = c.becFrac;
    r.data.xw(i1,i2) = c.gaussWidth(1);
    r.data.x0(i1,i2) = c.pos(1);
    r.data.yw(i1,i2) = c.gaussWidth(2);
    r.data.y0(i1,i2) = c.pos(2);
    r.data.OD(i1,i2) = c.fitdata.params.gaussAmp(1);
%     r.data.Tx(i1,i2) = c.T(1);
%     r.data.Ty(i1,i2) = c.T(2);
    
    figure(10);%clf;
    subplot(1,2,1);
    cla;
    plot(r.data.tof(1:i1),r.data.yw(1:i1,i2),'o-');
    hold on;
    plot(r.data.tof(1:i1),r.data.xw(1:i1,i2),'o-');
    hold off;
    subplot(1,2,2)
    
    if r.data.count.idx(1) == r.data.count.maxRuns(1)
        %cla;
        lf = linfit(r.data.tof,r.data.yw(:,i2).^2,2*r.data.yw(:,i2).*10e-6);
        lf.setFitFunc(@(x) [ones(size(x(:))) x(:).^2]);
        lf.fit;
        figure(11);clf;
        lf.plot;
        r.data.Ty(i2,1) = lf.c(2,1)*const.mRb/const.kb;
        
        lf.set(r.data.tof,r.data.xw(:,i2).^2,2*r.data.xw(:,i2).*10e-6);
        lf.fit;
        lf.plot;
        r.data.Tx(i2,1) = lf.c(2,1)*const.mRb/const.kb;
        figure(10);
        subplot(1,2,2);
        plot(r.data.verticalBias(1:i2),r.data.Ty(1:i2),'o-');
        hold on
        plot(r.data.verticalBias(1:i2),r.data.Tx(1:i2),'o-');
        hold off;
        ylim([0,100e-6]);
    end


end