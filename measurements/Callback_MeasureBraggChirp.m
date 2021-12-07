function Callback_MeasureBraggChirp(r)

if r.isInit()
    r.data.chirp = const.randomize(25.1e6 + (-0.15:0.01:0.15)*1e6);
%     r.data.t0 = [30e-3,50e-3,100e-3,150e-3,200e-3];
    r.data.t0 = const.randomize(50e-3:10e-3:230e-3);
    r.c.setup('var',r.data.chirp,r.data.t0);
elseif r.isSet()
    
%     r.make(25.5,730e-3,1.48,0.15,0,130e-3,r.data.chirp(r.c(1)));
    r.make(r.devices.opt.set('chirp',r.data.chirp(r.c(1)),'t0',r.data.t0(r.c(2))));
    r.upload;
    fprintf(1,'Run %d/%d, Chirp = %.3f MHz/s, t0 = %.3f ms\n',r.c.now,r.c.total,...
        r.data.chirp(r.c(1))/1e6,r.data.t0(r.c(2))*1e3);
    
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
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

    [~,N,dout] = FMI_Analysis;
    r.data.N(i1,i2,:) = [N.N1,N.N2];
    r.data.R(i1,i2) = N.R;
    r.data.d{i1,i2} = dout;
    
    figure(98);
    subplot(1,2,1);
    h = plot(r.data.chirp(1:i1)/1e6,r.data.R(1:i1,i2),'o');
    for nn = 1:numel(h)
        set(h(nn),'MarkerFaceColor',h(nn).Color);
    end
    plot_format('Chirp [MHz/s]','Population','',12);
    grid on;
    ylim([0,1]);

    if r.c.done(1)
        subplot(1,2,2);
        nlf = nonlinfit(r.data.chirp/1e6,r.data.R(:,i2));
        nlf.setFitFunc(@(A,w,x0,x) A*exp(-(x - x0).^2/w^2));
        nlf.bounds2('A',[0.4,0.7,0.5],'w',[0,1,0.05],'x0',[25.05,25.15,25.1]);
        r.data.c{i2} = nlf.fit;
        r.data.optimal_chirp(i2,1) = nlf.c(3,1);
        
        h = plot(r.data.chirp/1e6,r.data.R(:,i2),'o');
        set(h,'MarkerFaceColor',h.Color);
        hold on
        x = sort(r.data.chirp)/1e6;
        plot(x,nlf.f(x),'-','color',h.Color);
        grid on;
    end
    
end