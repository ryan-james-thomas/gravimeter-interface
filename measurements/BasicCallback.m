function BasicCallback(r)

if r.isInit()
    r.c.setup(Inf);
elseif r.isSet()
    r.make(8.5,5e-3,2).upload;
    fprintf(1,'Run %d/%d\n',r.c.now,r.c.total);
elseif r.isAnalyze()
    pause(0.5);
    c = Abs_Analysis('last',1);
%     r.data.w(nn,:) = c.gaussWidth;
%     figure(10);clf;
%     plot(1:nn,r.data.w*1e6,'o-');
%     ylim([40,80]);
end


end