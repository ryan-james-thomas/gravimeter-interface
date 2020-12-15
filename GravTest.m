function GravTest(r)

if r.isInit()
%     r.data.tof = 217e-3; 
    r.data.param = const.randomize([0:0.25:1,1.5:0.5:5]);
    r.numRuns = numel(r.data.param);
elseif r.isSet()
    
    r.make(8.0,r.data.param(r.currentRun),35e-3);
    r.upload;
%     pause(5);
    fprintf(1,'Run %d/%d, Param: %.2f\n',r.currentRun,r.numRuns,r.data.param(r.currentRun));
    
elseif r.isAnalyze()
    nn = r.currentRun;
    pause(1);
    c = Abs_Analysis('last');
    r.data.N(nn,1) = c.N;
    r.data.OD(nn,1) = c.peakOD;
%     r.data.pos(nn,:) = c.pos;

    

%     pause(0.1);
%     figure(10);clf;
%     lf = linfit(r.data.param(1:nn),r.data.pos(:,2),50e-6,1);
%     lf.setFitFunc(@(x) [ones(size(x(:))) x(:) x(:).^2]);
%     if nn < 4
%         errorbar(lf.x,lf.y,lf.dy,'o');
%     else
%         lf.fit;
%         lf.plot;
%         r.data.lf = lf;
%     end
    
    figure(10);clf;
%     subplot(2,1,1);
    errorbar(r.data.param(1:nn),r.data.N/1e6,r.data.N/1e6*0.05+0.05,'o');
%     subplot(2,1,2);
%     errorbar(r.data.param(1:nn),r.data.OD,r.data.OD*0.05+0.01,'o');
end