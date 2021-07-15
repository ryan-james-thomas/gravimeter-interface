function Callback_MeasureRamanFreq(r)

if r.isInit()
    r.data.freq = 152:.1:154;
    
    r.c.setup('var',r.data.freq);
elseif r.isSet()
    
    r.make(0,217e-3,1.18,0.09,0,0e-3,1e-3*r.data.freq(r.c(1)));
    r.upload;
    fprintf(1,'Run %d/%d, P = %.3f kHz\n',r.c.now,r.c.total,...
        r.data.freq(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
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
    r.data.c{i1,1} = c;
    r.data.files{i1,1} = {c(1).raw.files(1).name,c(1).raw.files(2).name};
    %
    % Get processed data
    %
    r.data.N(i1,:) = c.get('N');
    r.data.Nsum(i1,:) = c.get('Nsum');
    r.data.R(i1,:) = r.data.N(i1,:)./sum(r.data.N(i1,:));
    r.data.Rsum(i1,:) = r.data.Nsum(i1,:)./sum(r.data.Nsum(i1,:));
    
    figure(98);
    subplot(1,2,1)
    plot(r.data.freq(1:i1),r.data.R(1:i1,:),'o-');
    plot_format('Freq [kHz]','Population','',12);
    h = legend('m = -1','m = 0','m = 1');
    set(h,'Location','West');
    title(' Raman frequency using fit over OD')
    grid on
    hold on;
    
    subplot(1,2,2)
    plot(r.data.freq(1:i1),r.data.Rsum(1:i1,:),'sq-');
    hold off;
    plot_format('Freq [kHz]','Population','',12);
    h = legend('m = -1','m = 0','m = 1');
    set(h,'Location','West');
    title(' Raman frequency using ROI')
    grid on;
    if r.c(1) == r.c.imax(1)
    tNow = datestr(now);
        caption = sprintf('Determination of Raman frequency %s', tNow);
        sgtitle(caption)
    end
end