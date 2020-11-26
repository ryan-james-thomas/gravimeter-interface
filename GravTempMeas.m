function GravTempMeas(r)

if r.isInit()
    %Initialize run
    r.data.tof = 10e-3:4e-3:30e-3; 
%     r.data.param = 0;
    r.data.param = const.randomize(6:-0.2:2.2);
    %convers=(r.data.param*12.9967)-108.227;
    
    r.data.idx = [0,0];
    r.numRuns = numel(r.data.param)*numel(r.data.tof);
    r.data.matlabfiles.callback = fileread('GravTempMeas.m');
    r.data.matlabfiles.init = fileread('gravimeter-interface/initSequence.m');
    r.data.matlabfiles.sequence = fileread('gravimeter-interface/makeSequence.m');
    r.data.matlabfiles.analysis = fileread('Abs_Analysis.m');
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
    sq = makeSequence(r.data.param(r.data.idx(1)),r.data.tof(r.data.idx(2)));
%     figure(1);clf;sq.plot;
    sq.compile;
    r.data.sq(r.currentRun,1) = sq.data;
    r.upload(sq.data);
    %Print information about current run
    fprintf(1,'Run %d/%d, Parameter: %.3f V, TOF: %.1f ms\n',r.currentRun,r.numRuns,...
        r.data.param(r.data.idx(1)),r.data.tof(r.data.idx(2))*1e3);
    
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
    r.data.OD(nn,1) = c.peakOD;
    
    
    if r.data.idx(2) == numel(r.data.tof)
        %After recording the desired times-of-flight, analyze data
        %according to ballistic expansion model
        Ntof = numel(r.data.tof);
        lf = linfit(r.data.tof+1e-3,r.data.yw(nn-Ntof+1:nn).^2,2*20e-6*r.data.yw(nn-Ntof+1:nn),r.data.yw(nn-Ntof+1:nn)>4e-3 | r.data.yw(nn-Ntof+1:nn) < 1e-3);
        lf.setFitFunc(@(x) [ones(size(x(:))) x(:).^2]);
        lf.fit;figure(4);clf;lf.plot;
        r.data.Ty(r.data.idx(1),1) = lf.c(2,1)*const.mRb/const.kb;
        r.data.dTy(r.data.idx(1),1) = lf.c(2,2)*const.mRb/const.kb;
        
        lf.set(r.data.tof+1e-3,r.data.xw(nn-Ntof+1:nn).^2,2*20e-6*r.data.xw(nn-Ntof+1:nn),r.data.xw(nn-Ntof+1:nn)>4e-3 | r.data.xw(nn-Ntof+1:nn) < 1e-3);
        lf.fit;lf.plot;
        r.data.Tx(r.data.idx(1),1) = lf.c(2,1)*const.mRb/const.kb;
        r.data.dTx(r.data.idx(1),1) = lf.c(2,2)*const.mRb/const.kb;
        
       %%Plot data
        
        figure(10);clf;
        %just a common x-axis
        commonxlabel=('3D MOT detuning (MHz)');
        %adding used time of flight in the title
        tof=r.data.tof*1000;
        tofa= sprintf('%.f ms, ',tof(1:end-1));
        tofb=sprintf('%.fms',tof(end));
        arfwhysocomplicated='Time of flights: ';
        %adding time to the tile
        t=datetime('now');
        today=char(t);
        %adding values of Bias fields to suptitle
         sq = initSequence;
        sq.loadCompiledData(r.data.sq(nn));
        s = sprintf('E/W bias: %.3f V, N/S bias: %.3f V, U/D bias: %.3f V',...
            sq.find('bias e/w').values(end),sq.find('bias n/s').values(end),...
            sq.find('bias u/d').values(end));
         suptitle({today,s,[ arfwhysocomplicated tofa tofb]});
       
        subplot(3,2,1);
           errorbar(r.data.param(1:r.data.idx(1))*12.9967-108.227,r.data.Ty*1e6,r.data.dTy*1e6,'o');
        hold on;
        errorbar(r.data.param(1:r.data.idx(1))*12.9967-108.227,r.data.Tx*1e6,r.data.dTx*1e6,'sq');
        errorbar(r.data.param(1:r.data.idx(1))*12.9967-108.227,sqrt(r.data.Tx.*r.data.Ty)*1e6,r.data.dTx*1e6,'d');
        
%         errorbar(r.data.param(1:r.data.idx(1)),r.data.Ty*1e6,r.data.dTy*1e6,'o');
%         hold on;
%         errorbar(r.data.param(1:r.data.idx(1)),r.data.Tx*1e6,r.data.dTx*1e6,'sq');
%         errorbar(r.data.param(1:r.data.idx(1)),sqrt(r.data.Tx.*r.data.Ty)*1e6,r.data.dTx*1e6,'d');
%         plotxx(r.data.param(1:r.data.idx(1)),r.data.N(Ntof:Ntof:end)/1e9,r.data.param(1:r.data.idx(1)),r.data.N(Ntof:Ntof:end)/1e9)
        ylabel('Temperature [µK]');

%         errorbar(1:r.data.idx(1),r.data.Ty*1e6,r.data.dTy*1e6,'o-');
%         hold on;
%         errorbar(1:r.data.idx(1),r.data.Tx*1e6,r.data.dTx*1e6,'o-');
%         ylabel('Run');
        xlabel(commonxlabel);
        ylim([0,60]);
        
        
        
        legend('T_y','T_x','(T_yT_x)^{1/2}')
        grid on
        
        
        subplot(3,2,2);
        plot(r.data.param(1:r.data.idx(1))*12.9967-108.227,r.data.N(Ntof:Ntof:end)/1e9,'o');
        xlabel(commonxlabel)
        ylabel('Number of atoms \times 10^9');
        grid on
        
        
       subplot(3,2,[3,4,5,6])
        plot(r.data.param(1:r.data.idx(1))*12.9967-108.227, 1e6*r.data.xw(Ntof:Ntof:end),'o');
        hold on;
        plot(r.data.param(1:r.data.idx(1))*12.9967-108.227, 1e6*r.data.yw(Ntof:Ntof:end),'sq');
        xlabel(commonxlabel)
        ylabel('Width (µm)');
        legend('x','y')
        grid on
      
        fprintf(1,'Ty = %.3f µK, Tx = %.3f µK\n',r.data.Ty(end)*1e6,r.data.Tx(end)*1e6);
    end



end