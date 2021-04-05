function GravTest(r)

if r.isInit()
    r.data.param = const.randomize(2:12);
    r.numRuns = numel(r.data.param);
elseif r.isSet()
    
    r.make(8.5,35e-3,1.8,r.data.param(r.currentRun));
    r.upload;
%     pause(5);
    fprintf(1,'Run %d/%d, Param = %.3f\n',r.currentRun,r.numRuns,r.data.param(r.currentRun));
    
elseif r.isAnalyze()
    nn = r.currentRun;
    pause(1);
    c = Abs_Analysis('last');
    r.data.N(nn,1) = c.N;
    r.data.T(nn,:) = c.T;
    r.data.OD(nn,1) = c.peakOD;
    r.data.pos(nn,:) = c.pos;
    r.data.PSD(nn,1) = c.PSD;

%     pause(0.1);
%     figure(10);clf;
%     lf = linfit(r.data.param(1:nn),r.data.pos(:,1),50e-6);
%     lf.setFitFunc(@(x) [ones(size(x(:))) x(:) x(:).^2]);
%     if nn < 4
%         errorbar(lf.x,lf.y,lf.dy,'o');
%     else
%         lf.fit;
%         lf.plot;
%         r.data.lf = lf;
%     end
    
    figure(10);clf;
    subplot(2,1,1);
    errorbar(r.data.param(1:nn),r.data.N/1e6,r.data.N/1e6*0.05+0.05,'o');
    subplot(2,1,2);
    errorbar(r.data.param(1:nn),r.data.T(:,1)*1e6,r.data.T(:,1)*1e6*0.05,'o');
%     subplot(2,1,3);
%     plot(r.data.param(1:nn),r.data.PSD(:,1),'o');

end