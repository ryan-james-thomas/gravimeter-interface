function GravTest(r)

if r.isInit()
    r.data.param = 5:0.1:6;
    r.numRuns = numel(r.data.param);
elseif r.isSet()
    
    r.make(r.data.param(r.currentRun));
    r.upload;
%     pause(5);
    fprintf(1,'Run %d/%d, Param: %.2f\n',r.currentRun,r.numRuns,r.data.param(r.currentRun));
    
elseif r.isAnalyze()
    
end