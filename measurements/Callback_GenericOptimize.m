function Callback_GenericOptimize(r)

if r.isInit()
    %Initialize run
    r.data.param = const.randomize(1.25:0.25:4);
    r.data.param2 = 0.2:0.1:1;
    r.c.setup('var',r.data.param,r.data.param2);
    
    r.makerCallback = @makeSequence;
elseif r.isSet()
    %Build/upload/run sequence
    r.make(0,216.5e-3,1.5,r.data.param(r.c(1)),r.data.param2(r.c(2)));
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, Param = %.3f, Param2 = %.3f\n',r.c.now,r.c.total,...
        r.data.param(r.c(1)),r.data.param2(r.c(2)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    img = Abs_Analysis('last');
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    r.data.files{i1,i2} = {img.raw.files(1).name,img.raw.files(2).name};
    r.data.N(i1,i2) = img.get('N');
    r.data.T(i1,i2) = sqrt(prod(img.clouds.T));
    r.data.OD(i1,i2) = img.clouds.peakOD;
    
    figure(10);clf;
    subplot(1,2,1);
    errorbar(r.data.param(1:i1),r.data.N(1:i1,i2),0.025*r.data.N(1:i1,i2),'o');
    plot_format('Param [V]','Number of atoms','',12);
%     ylim([0,2.5]);
    grid on;
%     subplot(1,3,2);
%     errorbar(r.data.param(1:i1),r.data.T(1:i1,i2),0.025*r.data.T(1:i1,i2),'o');
%     plot_format('Param [V]','Temperature [K]','',12);
%     grid on;
    subplot(1,2,2);
%     PSD = r.data.N(:,i2)./r.data.T(:,i2).^3;
%     plot(r.data.param(1:i1),PSD,'o');
%     grid on;
%     plot_format('Param [V]','PSD','',12);
    plot(r.data.param(1:i1),r.data.OD(1:i1,i2),'o');
    grid on;
    plot_format('Param [V]','OD','',12);
    
    
    if r.c.done(1)
        figure(11);clf;
        subplot(1,2,1);
        cla;
        for nn = 1:i2
            errorbar(r.data.param,r.data.N(:,nn),0.025*r.data.N(:,nn),'o');
            plot_format('Param [V]','Number of atoms','',12);
            hold on;
            r.data.str{nn} = sprintf('TC = %.2f',r.data.param2(nn));
        end
        hold off;
        legend(r.data.str);
%         ylim([0,1e8]);
        grid on;
        
        subplot(1,2,2);
        cla;
        for nn = 1:i2
            plot(r.data.param(1:i1),r.data.OD(1:i1,nn),'o');
            hold on
        end
        hold off;
        grid on;
    end
end