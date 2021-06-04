function Callback_MeasurePhaseNoise(r)

if r.isInit()
    r.data.run = 1:50;
    r.data.T = [6 8 10 12 14 16 18 20 30]*1e-3;
    r.data.phase = [4,14.2,19.5,24.4,29.2,37.5,55,73.2,73.5];
    r.c.setup('var',r.data.run,r.data.T);
elseif r.isSet()
    
    r.make(0,216.5e-3,1.17,0.2,r.data.phase(r.c(2)),0,r.data.T(r.c(2)));
    r.upload;
    fprintf(1,'Run %d/%d, T = %.2f ms\n',r.c.now,r.c.total,...
        r.data.T(r.c(2))*1e3);
    
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    pause(0.1);
    c = Abs_Analysis_NClouds('last');
    if ~c(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    %
    % Store raw data
    %
    r.data.c{i1,i2} = c;
    r.data.files{i1,i2} = {c(1).raw.files(1).name,c(1).raw.files(2).name};
    %
    % Get processed data
    %
    r.data.N(i1,i2,:) = reshape([c.N],[1,1,2]);
    r.data.Nsum(i1,i2,:) = reshape([c.Nsum],[1,1,2]);
    r.data.R(i1,i2) = r.data.N(i1,i2,1)./sum(r.data.N(i1,i2,:));
    r.data.Rsum(i1,i2) = r.data.Nsum(i1,i2,1)./sum(r.data.Nsum(i1,i2,:));
    
    figure(98);
    subplot(1,2,1);
    plot(r.data.run(1:i1),r.data.R(1:i1,i2),'o-');
    hold on;
    plot(r.data.run(1:i1),r.data.Rsum(1:i1,i2),'sq-');
    hold off;
    plot_format('Run number','N_{rel}','',12);
    subplot(1,2,2);
    if r.c.done(1)
        cla;
        for mm = 1:i2
            plot(r.data.run,r.data.Rsum(:,mm),'o-');
            hold on;
            str{mm} = sprintf('Time = %d ms',round(1e3*r.data.T(mm)));
        end
        plot_format('Run number','N_{rel}','',12);
        legend(str);
    end
    pause(0.01);
    
end

