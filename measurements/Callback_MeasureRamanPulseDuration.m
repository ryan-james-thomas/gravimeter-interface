function Callback_MeasureRamanPulseDuration(r)

if r.isInit()
%     r.data.pulse = 1000e-6;
    r.data.pulse = 1250e-6:250e-6:2250e-6; %want to see 
%         r.data.pulse = 9e-3:1e-3:15e-3; %want to see 

    r.data.freq = 6834.6826 - 1e-3*270.81;
%      r.data.freq = 6834.6826 - 1e-3*[262:.25:272];
    %      r.data.freq = 6834.6826 - 612e-3 + 1e-3*[-100:1:50];
    %     r.data.freq = 6834.6826 - 0.275 + 1e-3*[-50:2:50];
    %     r.data.freq = 6834.4396 + 1e-3*[-10:0.5:10];
    
    r.c.setup('var',r.data.pulse);
elseif r.isSet()
    
    %     r.make('tof',217.25e-3,'dipole',1.56,'camera','drop 2','raman_power',0.3,...
    %         'raman_df',0,'raman_width',5000e-6);
    
    r.make(0,217.25e-3,1.3,0.13850,0,0,r.data.pulse(r.c(1)));
    r.upload;
    %     dev = visa('rs','TCPIP::192.168.1.11::INSTR');
    %     fopen(dev);
    fprintf(r.devices.dev,'source:freq %.6fMHz\n',r.data.freq/2);
    fprintf(r.devices.dev,'source:power:power %.6f\n',-6);
    fprintf(r.devices.dev,'output:state on\n');
    %     fclose(dev);delete(dev);
    fprintf(1,'Run %d/%d, F = %.6f MHz, Df = %.3fkHz , T= %.0f µs\n',r.c.now,r.c.total,...
        r.data.freq, (6834.6826- r.data.freq)*1e3,r.data.pulse(r.c(1))*1e6);
    
elseif r.isAnalyze()
%     i1=r.c(1);
%     i2=r.c(2);
%     pause(0.1);
%        pause(0.5);
%     c = Abs_Analysis('last');
%     r.data.N(i1,i2,:) = reshape(c.get('N'),[1,1,2]);
%     r.data.Nsum(i1,i2,:) = reshape(c.get('Nsum'),[1,1,2]);
%     r.data.Nsumtot(i1,:) = r.data.Nsum(i1,1)+r.data.Nsum(i1,2);
%     r.data.R(i1,i2) = r.data.N(i1,i2,1)./sum(r.data.N(i1,i2,:));
%     r.data.Rsum(i1,i2) = r.data.Nsum(i1,i2,1)./sum(r.data.Nsum(i1,i2,:));
%     fprintf(1,'N1 = %.3e, N2 = %.3e, R = %.3f %%\n',r.data.Nsum(i1,1),r.data.Nsum(i1,2),100*r.data.Rsum(i1));

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
     fprintf(1,'N1 = %.3e, N2 = %.3e, R = %.3f %%\n',r.data.Nsum(i1,1),r.data.Nsum(i1,2),100-100*r.data.Rsum(i1));

%    (6834.6826- r.data.freq(r.c(1)))*1e3
    
%     if (~c(1).raw.status.ok()) | (r.data.Nsumtot(i1) < 5e4) | (r.data.Nsumtot(i1) > 2.5e6)
%         if (~c(1).raw.status.ok())
%             warning('Imaging failed!')
%             r.c.decrement;
%             
%             
%         elseif (r.data.Nsumtot(i1) < 5e4) || (r.data.Nsumtot(i1) > 2.5e6)
%             r.data.limit=1+r.data.limit
%             warning('Number of atoms too low!')
%             r.c.decrement;
%             if r.data.limit == 3
%                 r.data.limit = 0;
%                 r.stop
%                 error('Run failed! lock your lasers.')
%             end
%         end
%         return;
%     end
    
    
    
    
    figure(98);clf;
    subplot(1,2,1)
    plot(r.data.pulse(1:i1)*1e6,r.data.R(1:i1,:),'o');
    plot_format('pulse duration (µs)','Population','',12);
    h = legend('m = -1','m = 0','m = 1');
    set(h,'Location','West');
    title(' Raman frequency using fit over OD')
    grid on
    hold on;
    
    subplot(1,2,2)
    plot(r.data.pulse(1:i1)*1e6,r.data.Rsum(1:i1,:),'sq');
    hold off;
    plot_format('pulse duration (µs)','Population','',12);
    h = legend('m = -1','m = 0','m = 1');
    set(h,'Location','West');
    title(' Raman frequency using ROI')
    grid on;
  
end