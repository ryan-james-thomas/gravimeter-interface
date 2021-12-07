function Callback_MeasureRamanPower(r)

if r.isInit()
%     r.data.power = 0:0.025:0.95;
    r.data.width = 50e-6:50e-6:500e-6;
    
    r.c.setup('var',r.data.width);
elseif r.isSet()
    
    r.make('tof',216.75e-3,'dipole',1.56,'camera','drop 2',...
        'raman_power',0.5,'raman_width',r.data.width(r.c(1)));
    r.upload;
    fprintf(1,'Run %d/%d, P = %.3f\n',r.c.now,r.c.total,...
        r.data.width(r.c(1))*1e6);
    
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
%     r.data.c{i1,1} = c;
    r.data.files{i1,1} = img.raw.files;
    %
    % Get processed data
    %
    r.data.N(i1,:) = img.get('N');
    r.data.Nsum(i1,:) = img.get('Nsum');
    r.data.R(i1,:) = r.data.N(i1,:)./sum(r.data.N(i1,:));
    r.data.Rsum(i1,:) = r.data.Nsum(i1,:)./sum(r.data.Nsum(i1,:));
    
    figure(98);clf
    plot(r.data.width(1:i1),r.data.R(1:i1,:),'o');
    hold on;
    plot(r.data.width(1:i1),r.data.Rsum(1:i1,:),'sq');
%     hold off;
    plot_format('Width [us]','Population','',12);
    grid on;
    h = legend('m = -1','m = 0','m = 1');
    set(h,'Location','West');
    
end