function Callback_MeasureRamanRFpower(r)

if r.isInit()
    r.data.power =  const.randomize(-15:1:-5);
    
    r.c.setup('var',r.data.power);
elseif r.isSet()
    
%     r.make('tof',217.25e-3,'dipole',1.56,'camera','drop 2','raman_power',0.3,...
%         'raman_df',0,'raman_width',5000e-6);
    
    r.make(0,217.25e-3,1.3,0.13850,0,0e-3,0);
    r.upload;
%     dev = visa('rs','TCPIP::192.168.1.11::INSTR');
%     fopen(dev);
fprintf(r.devices.dev,'source:freq %.6fMHz\n',(6834.6826 - 269e-3)/2)
    fprintf(r.devices.dev,'source:power:power %.6f\n',r.data.power(r.c(1)));
    fprintf(r.devices.dev,'output:state on\n');
%     fclose(dev);delete(dev);
    fprintf(1,'Run %d/%d, P = %.6f dBm\n',r.c.now,r.c.total,...
        r.data.power(r.c(1)));
    
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
    plot(r.data.power(1:i1),r.data.R(1:i1,:),'o');
    plot_format('Power [dBm]','Population','',12);
    h = legend('m = -1','m = 0','m = 1');
    set(h,'Location','West');
    title('Raman power using fit over OD')
    grid on
    hold on;
    
    subplot(1,2,2)
    plot(r.data.power(1:i1),r.data.Rsum(1:i1,:),'sq');
    hold off;
    plot_format('Power [dBm]','Population','',12);
    h = legend('m = -1','m = 0','m = 1');
    set(h,'Location','West');
    title('Raman power using ROI')
    grid on;
    if r.c.done
    tNow = datestr(now);
        caption = sprintf('Determination of Raman power %s', tNow);
        sgtitle(caption)
    end
    
%     Ndim = ceil(sqrt(r.c.total));
%     figure(29);
%     subplot(Ndim,Ndim,i1);

%     title(sprintf('Chirp srate = %.3f MHz',r.data.chirp(i1)/1e6));
end