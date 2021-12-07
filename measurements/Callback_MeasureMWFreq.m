function Callback_MeasureMWFreq(r)

if r.isInit()
    
    r.data.freq1 = const.f_Rb_groundHFS/1e6 - 311.882e-3;
    r.data.freq2 = const.f_Rb_groundHFS/1e6 + 0;
    
    r.c.setup('var',r.data.freq1);
elseif r.isSet()
    
    r.make(r.devices.opt.set('params',[320e-6,232e-6]));
    
%     r.make(0,217.25e-3,1.3,0.13850,0,0e-3,1250e-6);
    r.upload;
    %
    % These commands are for list-mode operation
    %
    r.devices.rs.writeList([r.data.freq1(r.c(1))/2,r.data.freq2/2],[6,6]);
    r.devices.rs.writeState('on');
    fprintf(1,'Run %d/%d, F = %.6f MHz\n',r.c.now,r.c.total,...
        r.data.freq1(r.c(1)));
    
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
    subplot(1,3,1)
    plot(r.data.freq1(1:i1) - const.f_Rb_groundHFS/1e6,r.data.R(1:i1,:),'o');
    plot_format('Freq [MHz]','Population','',12);
    h = legend('m = -1','m = 0');
    set(h,'Location','West');
    title(' Raman frequency using fit over OD')
    grid on
    hold on;
    
    subplot(1,3,2)
    plot(r.data.freq1(1:i1) - const.f_Rb_groundHFS/1e6,r.data.Rsum(1:i1,:),'sq');
    hold off;
    plot_format('Freq [MHz]','Population','',12);
    h = legend('m = -1','m = 0');
    set(h,'Location','West');
    title(' Raman frequency using ROI')
    grid on;
    if r.c.done
    tNow = datestr(now);
        caption = sprintf('Determination of Raman frequency %s', tNow);
        sgtitle(caption)
    end
    
    subplot(1,3,3)
    plot(r.data.freq1(1:i1) - const.f_Rb_groundHFS/1e6,r.data.Nsum(1:i1,:),'o');
    plot_format('Freq [MHz]','Population','',12);
    h = legend('m = -1','m = 0');
    set(h,'Location','West');
    title(' Raman frequency using fit over OD')
    grid on
    hold on;
    
%     Ndim = ceil(sqrt(r.c.total));
%     figure(29);
%     subplot(Ndim,Ndim,i1);

%     title(sprintf('Chirp srate = %.3f MHz',r.data.chirp(i1)/1e6));
end