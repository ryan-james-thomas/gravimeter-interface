function GravNParameterScan(r)

if r.isInit()
    %Initialize run
    r.data.evapRate = (0.1:0.1:0.8);
    r.data.evapStart = const.randomize(6.5:0.1:7.5);
    
    r.data.count = RolloverCounter([numel(r.data.evapStart),numel(r.data.evapRate)]);
    r.numRuns = r.data.count.total;
    
    r.makerCallback = @makeSequenceFull;
    r.data.matlabfiles.callback = fileread('GravTwoParameterScan.m');
    r.data.matlabfiles.init = fileread('gravimeter-interface/initSequence.m');
    r.data.matlabfiles.sequence = fileread('gravimeter-interface/makeSequenceFull.m');
    r.data.matlabfiles.analysis = fileread('Abs_Analysis.m');
elseif r.isSet()
    %Increment counter
    if r.currentRun ~= 1
        r.data.count.increment;
    end
    
    %Build/upload/run sequence
    r.make(8.25,35e-3,2.5,r.data.evapStart(r.data.count.idx(1)), r.data.evapRate(r.data.count.idx(2)));
    r.upload;
    r.data.sq(r.currentRun,1) = r.sq.data;
    %Print information about current run
    fprintf(1,'Run %d/%d, Evap Start: %.2f V, Evap Rate: %.3f V/s\n',r.currentRun,r.numRuns,...
        r.data.evapStart(r.data.count.idx(1)),r.data.evapRate(r.data.count.idx(2)));

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
    r.data.T(i1,i2) = sqrt(prod(c.T));
    
    figure(10);clf;
    subplot(1,2,1);
    errorbar(r.data.evapStart(1:i1),r.data.N(1:i1,i2)/1e6,0.05*r.data.N(1:i1,i2)/1e6,'o');
    plot_format('Evap Start [V]','Number of atoms \times 10^6','',12);
    grid on;
    subplot(1,2,2);
    plot(r.data.evapStart(1:i1),r.data.T(1:i1,i2)*1e6,'o');
    plot_format('Parameter','Temperature [uK]','',12);
    grid on;
    
    if r.data.count.idx(1) == r.data.count.maxRuns(1)
        figure(11);clf;
        subplot(1,3,1);
        for jj = 1:r.data.count.idx(2)
            errorbar(r.data.evapStart(1:i1),r.data.N(1:i1,jj)/1e6,0.05*r.data.N(1:i1,jj)/1e6,'o');
            hold on;
            s{jj} = sprintf('Rate: %.3f',r.data.evapRate(jj));
        end
        plot_format('Evap Start [V]','Number of atoms \times 10^6','',12);
        grid on;
        legend(s);
        subplot(1,3,2);
        for jj = 1:r.data.count.idx(2)
            plot(r.data.evapStart(1:i1),r.data.T(1:i1,1:i2)*1e6,'o');
            hold on;
        end
        plot_format('Parameter','Temperature [uK]','',12);
        grid on;
        subplot(1,3,3);
        for jj = 1:r.data.count.idx(2)
            plot(r.data.evapStart(1:i1),r.data.N(1:i1,1:i2)./r.data.T(1:i1,1:i2),'o');
            hold on;
        end
        plot_format('Parameter','Temperature [uK]','',12);
        grid on;
    end
        
    
%     if r.data.idx(2) == numel(r.data.tof)
%         %After recording the desired times-of-flight, analyze data
%         %according to ballistic expansion model
%         Ntof = numel(r.data.tof);
%         lf = linfit(r.data.tof+1e-3,r.data.yw(nn-Ntof+1:nn).^2,2*20e-6*r.data.yw(nn-Ntof+1:nn),r.data.yw(nn-Ntof+1:nn)>4e-3 | r.data.yw(nn-Ntof+1:nn) < 1e-3);
%         lf.setFitFunc(@(x) [ones(size(x(:))) x(:).^2]);
%         lf.fit;figure(4);clf;lf.plot;
%         r.data.Ty(r.data.idx(1),1) = lf.c(2,1)*const.mRb/const.kb;
%         r.data.dTy(r.data.idx(1),1) = lf.c(2,2)*const.mRb/const.kb;
%         
%         lf.set(r.data.tof+1e-3,r.data.xw(nn-Ntof+1:nn).^2,2*20e-6*r.data.xw(nn-Ntof+1:nn),r.data.xw(nn-Ntof+1:nn)>4e-3 | r.data.xw(nn-Ntof+1:nn) < 1e-3);
%         lf.fit;lf.plot;
%         r.data.Tx(r.data.idx(1),1) = lf.c(2,1)*const.mRb/const.kb;
%         r.data.dTx(r.data.idx(1),1) = lf.c(2,2)*const.mRb/const.kb;
%       
%     end


end