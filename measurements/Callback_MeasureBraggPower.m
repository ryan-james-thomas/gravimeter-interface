function Callback_MeasureBraggPower(r)

if r.isInit()
    r.data.power = const.randomize(0:0.02:0.8);
    
    r.c.setup('var',r.data.power);
elseif r.isSet()
    
    r.make(0,216.6e-3,1.5,r.data.power(r.c(1)),0);
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
    r.data.files{i1,1} = {img.raw.files(1).name,img.raw.files(2).name};
    %
    % Get processed data
    %
    r.data.N(i1,:) = img.get('N');
    r.data.Nsum(i1,:) = img.get('Nsum');
    r.data.R(i1,:) = r.data.N(i1,:)./sum(r.data.N(i1,:));
    r.data.Rsum(i1,:) = r.data.Nsum(i1,:)./sum(r.data.Nsum(i1,:));
    
    figure(98);
    h = plot(r.data.power(1:i1),r.data.Rsum(1:i1,:),'o');
    for nn = 1:numel(h)
        set(h(nn),'MarkerFaceColor',h(nn).Color);
    end
%     hold off;
    plot_format('Power [arb units]','Population','Bragg power scan at pulse width of 30 us FWHM',12);
    grid on;
    h = legend('Slow','Fast');
%     h = legend('-2k','0k','2k','4k');
    set(h,'Location','West');
    ylim([0,1]);
    xlim([0,Inf]);
    
    %
    % Get device data
    %
    if isfield(r.devices,'dv')
        r.devices.dv.getData(r.devices.dv.numSamples.value);
        r.data.meas.t(:,i1) = r.devices.dv.t;
        r.data.meas.v(:,i1) = r.devices.dv.data(:,1);
        figure(99);
        plot(r.data.meas.t(:,i1),r.data.meas.v(:,i1),'.-');
        hold on
        grid on;
        plot_format('Time [s]','Measured power','',12);
    end
    
end