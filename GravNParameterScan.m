function GravNParameterScan(r)

if r.isInit()
    %Initialize run
    r.data.motfreq = 5:0.1:6;
    r.data.tof = (20:2.5:30)*1e-3;
    
    r.data.count = RolloverCounter([numel(r.data.tof),numel(r.data.motfreq)]);
    r.numRuns = r.data.count.total;
    
    r.makerCallback = @makeSequence;
elseif r.isSet()
    %Increment counter
    if r.currentRun ~= 1
        r.data.count.increment;
    end
    
    %Build/upload/run sequence
    r.make(r.data.motfreq(r.data.count.idx(2)),...
        r.data.tof(r.data.count.idx(1)));
    r.upload;
%     r.data.sq(r.currentRun,1) = r.sq.data;
    %Print information about current run
    fprintf(1,'Run %d/%d, MOT freq: %.2f V, TOF: %.3f ms\n',r.currentRun,r.numRuns,...
        r.data.motfreq(r.data.count.idx(2)),r.data.tof(r.data.count.idx(1))*1e3);

elseif r.isAnalyze()
    nn = r.currentRun;
    i1 = r.data.count.idx(1);
    i2 = r.data.count.idx(2);
    pause(1.0); %Wait for other image analysis program to finish with files
    
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
    r.data.Tx(i1,i2) = c.T(1);
    r.data.Ty(i1,i2) = c.T(2);
    
    figure(10);clf;
    plot(r.data.tof(1:i1),r.data.xw(1:i1,i2),'o-');
    hold on
    plot(r.data.tof(1:i1),r.data.yw(1:i1,i2),'o-');
    
    if r.data.count.idx(1) == r.data.count.maxRuns(1)
        %Get temperature here
    end


end