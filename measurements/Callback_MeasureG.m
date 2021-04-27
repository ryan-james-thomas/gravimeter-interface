function Callback_MeasureG(r)

if r.isInit()
    r.data.phase = 0:10:180;
    r.data.T = (1:4)*1e-3;
    r.c.setup('var',r.data.phase,r.data.T);
    r.numRuns = r.c.total;
elseif r.isSet()
    if r.currentRun ~= 1
        r.c.increment;
    end
    r.devices.p.makePulses('finalphase',r.data.phase(r.c(1)),'T',r.data.T(r.c(2)));
    r.devices.p.upload;
    r.make(8.5,216.125e-3,1.35);
    r.upload;
    fprintf(1,'Run %d/%d, T = %.2f ms, Phase: %.2f\n',r.currentRun,r.numRuns,...
        r.data.T(r.c(2))*1e3,r.data.phase(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    pause(0.5);
    c = Abs_Analysis_NClouds('last');
    r.data.c{i1,i2} = c;
    r.data.N(i1,i2,:) = reshape([c.N],[1,1,2]);
    r.data.R(i1,i2) = r.data.N(i1,i2,1)./sum(r.data.N(i1,i2,:));
    
    figure(98);%clf;
%     subplot(1,2,1);
%     for mm = 1:size(r.data.N,2)
%         errorbar(r.data.phase(1:i1),squeeze(r.data.N(1:i1,i2,:))/1e6,0.05*squeeze(r.data.N(1:i1,i2,:))/1e6+0.05,'o');
%         hold on;
%     end
%     plot(r.data.phase(1:i1),sum(r.data.N(i1,i2,:),3)/1e6,'sq');
    subplot(1,2,1);
    errorbar(r.data.phase(1:i1),r.data.R(1:i1,i2),0.02*ones(size(r.data.R(1:i1,i2))),'o');
    subplot(1,2,2);
    if r.c(1) == r.c.imax(1)
        cla;
        for mm = 1:i2
            errorbar(r.data.phase,r.data.R(:,mm),0.02*ones(size(r.data.R(:,mm))),'o');
            hold on;
        end
    end
    pause(0.01);
%     figure(11);clf;
%     for j=1:nn
%         subplot(8,10,j)
%         r.data.v(j).plotAbsData([0,.1],1);
% %         title(sprintf('chirp: %.3f',r.data.param(j)*1e6));
%     end
%     pause(0.01);
    
end