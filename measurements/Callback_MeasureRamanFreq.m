function Callback_MeasureRamanFreq(r)

if r.isInit()
    r.data.freq = 135:145;
%     r.data.freq = 153;
    
    r.c.setup('var',r.data.freq);
elseif r.isSet()
    
    r.make('tof',217.25e-3,'dipole',1.56,'camera','drop 2','raman_power',0.25,...
        'raman_df',r.data.freq(r.c(1))*1e-3,'raman_width',100e-6);
    r.upload;
    fprintf(1,'Run %d/%d, P = %.3f kHz\n',r.c.now,r.c.total,...
        r.data.freq(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);
    img = Abs_Analysis('last');
    if ~img.raw.status.ok()
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
    r.data.files{i1,1} = img.raw.files;
    %
    % Get processed data
    %
    r.data.N(i1,:) = img.get('N');
    r.data.Nsum(i1,:) = img.get('Nsum');
    r.data.R(i1,:) = r.data.N(i1,:)./sum(r.data.N(i1,:));
    r.data.Rsum(i1,:) = r.data.Nsum(i1,:)./sum(r.data.Nsum(i1,:));
    
    figure(98);clf;
    subplot(1,2,1)
    plot(r.data.freq(1:i1),r.data.R(1:i1,:),'o');
    plot_format('Freq [kHz]','Population','',12);
%     h = legend('m = -1','m = 0','m = 1');
%     set(h,'Location','West');
    title(' Raman frequency using fit over OD')
    grid on
    hold on;
    
    subplot(1,2,2)
    plot(r.data.freq(1:i1),r.data.Rsum(1:i1,:),'sq');
    hold off;
    plot_format('Freq [kHz]','Population','',12);
%     h = legend('m = -1','m = 0','m = 1');
%     set(h,'Location','West');
    title(' Raman frequency using ROI')
    grid on;
    if r.c.done
        tNow = datestr(now);
        caption = sprintf('Determination of Raman frequency %s', tNow);
        sgtitle(caption)
    end
end