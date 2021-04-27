function GravPhaseScanTest(r)

if r.isInit()
    r.data.param = 0:2:180;
    r.c.setup('var',r.data.param);
elseif r.isSet()
    r.make(8.5,35e-3,1.05,0.108,r.data.param(r.c(1)));
    r.upload;
    fprintf(1,'Run %d/%d, Phase: %.2f\n',r.c(1),r.c.total,r.data.param(r.c(1)));
    
elseif r.isAnalyze()
    nn = r.c.now;
    pause(0.5);
    c = Abs_Analysis_NClouds('last');
%     r.data.files{nn,1} = c.raw.files(1).name;r.data.files{nn,2} = c.raw.files(2).name;
    r.data.c(nn,:) = c;
    r.data.N(nn,:) = [c.N];
    r.data.R(nn,1) = r.data.N(nn,1)./sum(r.data.N(nn,:));
%     r.data.v(nn,:) = v;
    
    figure(10);clf;
    subplot(1,2,1);
    for mm = 1:size(r.data.N,2)
        errorbar(r.data.param(1:nn),r.data.N(1:nn,mm)/1e5,0.05*r.data.N(1:nn,mm)/1e5+0.05,'o');
        hold on;
    end
    plot(r.data.param(1:nn),sum(r.data.N(1:nn,:),2)/1e5,'sq');
    subplot(1,2,2);
    errorbar(r.data.param(1:nn),r.data.R,0.02*ones(size(r.data.R)),'o');
    pause(0.01);
%     figure(11);clf;
%     for j=1:nn
%         subplot(8,10,j)
%         r.data.v(j).plotAbsData([0,.1],1);
% %         title(sprintf('chirp: %.3f',r.data.param(j)*1e6));
%     end
%     pause(0.01);
    
end