function Callback_MeasureBraggPower(r)

if r.isInit()
    r.data.power = const.randomize(0:0.05:0.8);
    
    r.c.setup('var',r.data.power);
elseif r.isSet()
    
%     r.make(25.5,730e-3,1.48,r.data.power(r.c(1)),0,130e-3);

    r.make(r.devices.opt.set('power',r.data.power(r.c(1))));
    r.upload;
    fprintf(1,'Run %d/%d, P = %.3f\n',r.c.now,r.c.total,...
        r.data.power(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);
    img = Abs_Analysis('last');
    if ~img(1).raw.status.ok()
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

%     [~,N] = FMI_Analysis;
%     r.data.N(i1,:) = [N.N1,N.N2];
%     r.data.R(i1,1) = N.R;
    
    figure(98);clf;
    h = plot(r.data.power(1:i1),r.data.R(1:i1,:),'o');
    for nn = 1:numel(h)
        set(h(nn),'MarkerFaceColor',h(nn).Color);
    end
%     hold off;
    plot_format('Power [arb units]','Population','Bragg power scan at pulse width of 60 us FWHM',12);
    grid on;
%     h = legend('Slow','Fast');
%     h = legend('-2k','0k','2k','4k');
%     set(h,'Location','West');
    ylim([0,1]);
    xlim([0,1]);
    
end