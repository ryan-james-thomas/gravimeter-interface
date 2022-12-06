function Callback_MeasureFeedbackTemperature(r)

if r.isInit()
    r.data.runs = 1:1500;
    r.data.enable = logical(mod(r.data.runs,2));
    r.data.delay = 150e-3*rand(numel(r.data.runs),1);
    r.data.jumps = zeros(4,numel(r.data.runs));
    r.data.jumps(1,:) = round(-0.5 + 1*rand(1,numel(r.data.runs)),3);
    r.data.jumps(3,:) = round(0.3*rand(1,numel(r.data.runs)),3);
    r.data.jump_index = round(2 + (45 - 2)*rand(1,numel(r.data.runs)));
    r.c.setup('var',r.data.runs);

    r.devices.fb = FeedbackControl;
    r.devices.fb.gains = [-1.5,0,0,0;0,0,-0.5,0;0,-0.7,0,0;0,0.3,0,0];
    r.devices.fb.start = 50;
    r.devices.fb.jump_enable = 1;
elseif r.isSet()
    r.devices.fb.enable = r.data.enable(r.c(1));
    r.devices.fb.jumps = r.data.jumps(:,r.c(1));
    r.devices.fb.jump_index = r.data.jump_index(r.c(1));
    r.devices.fb.upload;
    r.make(r.devices.opt,'detuning',0,'keopsys',0.71,'nd',{'pulse_amp',0.4},'params',r.data.delay(r.c(1))).upload;
    fprintf(1,'Run %d/%d\n',r.c.now,r.c.total);
    fprintf('Enable = %d\n',r.data.enable(r.c(1)));
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.5 + 0.25*rand);
    img = Abs_Analysis_FB('last',1);
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    elseif i1 > 1 && strcmpi(img.raw.files.name,r.data.files{i1 - 1}.name)
        r.c.decrement;
        pause(15);
        return;
    end
    
    r.data.files{i1,1} = img.raw.files;
    r.data.N(i1,1) = img.get('N');
    r.data.becFrac(i1,1) = img.get('becFrac');
    r.data.OD(i1,1) = img.get('peakOD');
    r.data.T(i1,1) = prod(squeeze(img.get('T')))^0.5;
    r.data.x(i1,1) = img.clouds.pos(1);
    r.data.y(i1,1) = img.clouds.pos(2);

%     data = r.data;save('D:\data\22-11-17\collected-data-17-11-2022','data');

    if i1 > 5 && all(r.data.N((i1-5):i1) < 1.25e5)
        r.c.final = i1;
    end

    xx = r.data.runs(1:i1);
    x = xx(r.data.enable(1:i1));
    y = xx(~r.data.enable(1:i1));
    figure(98);clf;
    subplot(1,3,1);
    h = plot(x,r.data.N(r.data.enable(1:i1)),'o');
    set(h,'MarkerFaceColor',h.Color);
    hold on
    h = plot(y,r.data.N(~r.data.enable(1:i1)),'sq');
    set(h,'MarkerFaceColor',h.Color);
    ylim([0,Inf]);
    grid on
    plot_format('Run','Number','',10);

    subplot(1,3,2);
    h = plot(x,r.data.T(r.data.enable(1:i1))*1e9,'o');
    set(h,'MarkerFaceColor',h.Color);
    hold on
    h = plot(y,r.data.T(~r.data.enable(1:i1))*1e9,'sq');
    set(h,'MarkerFaceColor',h.Color);
    ylim([0,200]);
    grid on
    plot_format('Run','Temperature [nK]','',10);


    subplot(1,3,3);
    h = plot(x,r.data.becFrac(r.data.enable(1:i1)),'o');
    set(h,'MarkerFaceColor',h.Color);
    hold on
    h = plot(y,r.data.becFrac(~r.data.enable(1:i1)),'sq');
    set(h,'MarkerFaceColor',h.Color);
    ylim([0,0.5]);
    grid on
    plot_format('Run','BEC fraction','',10);
end


end