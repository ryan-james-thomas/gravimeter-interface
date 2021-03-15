function GravNParameterScan(r)

if r.isInit()
    %Initialize run
    r.data.coolingfreq = (-40:4:0);
    r.data.magcoil = (0:0.02:0.2);
    
    r.data.count = RolloverCounter([numel(r.data.coolingfreq),numel(r.data.magcoil)]);
    r.numRuns = r.data.count.total;
    
    r.makerCallback = @makeSequence;
    
elseif r.isSet()
    %Increment counter
    if r.currentRun ~= 1
        r.data.count.increment;
    end
    
    %Build/upload/run sequence
    r.make(r.data.coolingfreq(r.data.count.idx(1)),r.data.magcoil(r.data.count.idx(2)));
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, MOT, TOF: %.3f ms\n',r.currentRun,r.numRuns,r.data.coolingfreq(r.data.count.idx(1)));

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
    r.data.Tx(i1,i2) = c.T(1);
    r.data.Ty(i1,i2) = c.T(2);
    
    figure(10);%clf;
    subplot(1,2,1);
    cla;
    plot(r.data.coolingfreq(1:i1),r.data.N(1:i1,i2),'o-');
    subplot(1,2,2)
    
    if r.data.count.idx(1) == r.data.count.maxRuns(1)
        %cla;
        for mm = 1:i2
            plot(r.data.coolingfreq,r.data.N(:,mm),'o-');
            
            hold on;
        end
    end


end