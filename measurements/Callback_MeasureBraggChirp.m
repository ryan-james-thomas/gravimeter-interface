function Callback_MeasureBraggChirp(r)

if r.isInit()
    r.data.chirp = const.randomize(25.1e6 + (-0.05:0.005:0.05)*1e6);
    
    r.c.setup('var',r.data.chirp);
elseif r.isSet()
    
    r.make(25.5,730e-3,1.48,0.15,0,130e-3,r.data.chirp(r.c(1)));
    r.upload;
    fprintf(1,'Run %d/%d, Chirp = %.3f\n',r.c.now,r.c.total,...
        r.data.chirp(r.c(1))/1e6);
    
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);
%     img = Abs_Analysis('last');
%     if ~img.raw.status.ok()
%         %
%         % Checks for an error in loading the files (caused by a missed
%         % image) and reruns the last sequence
%         %
%         r.c.decrement;
%         return;
%     end
%     %
%     % Store raw data
%     %
%     r.data.img{i1,1} = img;
%     r.data.files{i1,1} = img.raw.files;
%     %
%     % Get processed data
%     %
%     r.data.N(i1,:) = img.get('N');
%     r.data.Nsum(i1,:) = img.get('Nsum');
%     r.data.R(i1,:) = r.data.N(i1,:)./sum(r.data.N(i1,:));
%     r.data.Rsum(i1,:) = r.data.Nsum(i1,:)./sum(r.data.Nsum(i1,:));

    [~,N] = FMI_Analysis;
    r.data.N(i1,:) = [N.N1,N.N2];
    r.data.R(i1,1) = N.R;
    
    figure(98);
    h = plot(r.data.chirp(1:i1)/1e6,r.data.R(1:i1,:),'o');
    for nn = 1:numel(h)
        set(h(nn),'MarkerFaceColor',h(nn).Color);
    end
%     hold off;
    plot_format('Chirp [MHz/s]','Population','',12);
    grid on;
%     h = legend('Slow','Fast');
%     set(h,'Location','North');
    
end