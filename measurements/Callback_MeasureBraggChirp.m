function Callback_MeasureBraggChirp(r)

if r.isInit()
    r.data.chirp = const.randomize(25.1e6 + (-0.2:0.02:0.2)*1e6);
    
    r.c.setup('var',r.data.chirp);
elseif r.isSet()
    
    r.make(0,216.5e-3,1.1,0.25,r.data.chirp(r.c(1)));
    r.upload;
    fprintf(1,'Run %d/%d, P = %.3f\n',r.c.now,r.c.total,...
        r.data.chirp(r.c(1))/1e6);
    
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);
    c = Abs_Analysis_NClouds('last');
    if ~c(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        pause(1);
        c(1).raw.load('files','last','index',1);
        if ~c(1).raw.status.ok()
            r.c.decrement;
            return;
        else
            c = Abs_Analysis_NClouds('last');
        end
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
%     plot(r.data.chirp(1:i1),r.data.R(1:i1,:),'o-');
%     hold on;
    h = plot(r.data.chirp(1:i1)/1e6,r.data.Rsum(1:i1,:),'sq');
    for nn = 1:numel(h)
        set(h(nn),'MarkerFaceColor',h(nn).Color);
    end
%     hold off;
    plot_format('Chirp [MHz/s]','Population','',12);
    grid on;
    h = legend('Slow','Fast');
%     set(h,'Location','North');
    
end