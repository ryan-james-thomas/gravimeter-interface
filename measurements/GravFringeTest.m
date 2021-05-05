function GravFringeTest(r)

if r.isInit()
    r.data.param = 0e-3:0.5e-3:14.5e-3;
    r.c.setup('var',r.data.param);
    
    clf(10);clf(11);clf(12);
elseif r.isSet()
    
    r.make(0,216.5e-3,1,0.176,r.data.param(r.c(1)));
    r.upload;
%     pause(5);
    fprintf(1,'Run %d/%d, Param = %.3f\n',r.c.now,r.c.total,1e3*r.data.param(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
%     pause(0.1);
    c = Abs_Analysis('last');
    f = c.fitdata;
    
    r.data.files{i1,1} = {c.raw.files(1).name,c.raw.files(2).name};
    r.data.c{i1,1} = c;
    
    y = f.ydata(abs(f.y-c.pos(2))<0.25e-3);
    r.data.contrast(i1,1) = (max(y) - min(y))./(max(y) + min(y) - 2*f.params.offset(2));
    
    figure(10);
    subplot(5,6,i1);
    c.plotAbsData([0,0.5],true);
    title(sprintf('%.3f ms',r.data.param(i1)*1e3));
    
    figure(11);
    subplot(5,6,i1);
    plot(c.fitdata.y,c.fitdata.ydata,'.-');
    title(sprintf('%.3f ms',r.data.param(i1)*1e3));
    
    figure(12);clf;
    plot(r.data.param(1:i1),r.data.contrast,'o-');
    grid on;

end