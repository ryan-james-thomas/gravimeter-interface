function GravTest(r)

if r.isInit()
    r.numRuns = 50;
elseif r.isSet()
    
    r.make(8.5,35e-3,2);
    r.upload;
%     pause(5);
    fprintf(1,'Run %d/%d\n',r.currentRun,r.numRuns);
    
elseif r.isAnalyze()
    nn = r.currentRun;
    pause(1);
    c = Abs_Analysis('last');
    r.data.N(nn,1) = c.N;
    r.data.T(nn,:) = c.T;
    r.data.OD(nn,1) = c.peakOD;
    r.data.pos(nn,:) = c.pos;

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
    errorbar((1:nn),r.data.N/1e6,r.data.N/1e6*0.05+0.05,'o');
    subplot(2,1,2);
    errorbar((1:nn),r.data.T(:,1)*1e6,r.data.T(:,1)*1e6*0.05,'o');

end