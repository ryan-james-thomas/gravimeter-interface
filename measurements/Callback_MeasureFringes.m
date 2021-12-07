function Callback_MeasureFringes(r)

if r.isInit()
%     r.data.T = [1,2,5,10,20]*1e-3;
    r.data.T = 5e-3;
    r.data.phase = 0:10:180;
    r.c.setup('var',r.data.phase,r.data.T);
elseif r.isSet()
    
%     r.make(0,216.6e-3,1.5,0.215,r.data.phase(r.c(1)),r.data.T(r.c(2)));
    r.make(r.devices.opt.set('Tint',r.data.T(r.c(2)),'phase',r.data.phase(r.c(1))));
    r.upload;
    fprintf(1,'Run %d/%d, Phase = %.2f, T = %.2f ms\n',r.c.now,r.c.total,...
        r.data.phase(r.c(1)),r.data.T(r.c(2))*1e3);
    
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    pause(0.1);
    
%     img = Abs_Analysis('last',1);
%     if ~img.raw.status.ok()
%         %
%         % Checks for an error in loading the files (caused by a missed
%         % image) and reruns the last sequence
%         %
%         r.c.decrement;
%         return
%     end
%     %
%     % Store raw data
%     %
%     r.data.files{i1,i2} = img.raw.files;
%     %
%     % Get processed data
%     %
%     r.data.N(i1,i2,:) = reshape(img.get('N'),[1,1,2]);
%     r.data.Nsum(i1,:) = reshape(img.get('Nsum'),[1,1,2]);
%     r.data.R(i1,i2) = r.data.N(i1,1)./sum(r.data.N(i1,:));
%     r.data.Rsum(i1,i2) = r.data.Nsum(i1,1)./sum(r.data.Nsum(i1,:));

    [~,N,dout] = FMI_Analysis;
    r.data.N(i1,i2,:) = [N.N1,N.N2];
    r.data.R(i1,i2) = N.R;
    r.data.d{i1,i2} = dout;
    
    figure(97);
    subplot(1,2,1);
    plot(r.data.phase(1:i1),r.data.R(1:i1,i2),'o-');
%     hold on;
%     plot(r.data.phase(1:i1),r.data.Rsum(1:i1,i2),'sq-');
%     hold off;
    grid on;
    ylim([0,1]);
    xlim([0,180]);
    plot_format('Phase [deg]','N_{rel}','',12);
    subplot(1,2,2);
    if r.c.done(1)
        nlf = nonlinfit(r.data.phase,r.data.R(:,i2),0.02);
        nlf.setFitFunc(@(y0,C,phi,x) y0 + C/2*cosd(2*x+2*phi));
        nlf.bounds2('y0',[0.4,0.6,0.5],'C',[0.6,1,0.8],'phi',[-180,180,0]);
        r.data.p{i2} = nlf.fit;
        
        h = errorbar(nlf.x,nlf.y,nlf.dy,'o');
        hold on
        xplot = linspace(0,180,1e2);
        h2 = plot(xplot,nlf.f(xplot),'-','Color',h.Color,'linewidth',1.5);
        set(h2,'HandleVisibility','Off');
        for jj = 1:i2
            str{jj} = sprintf('Time = %d ms',round(1e3*r.data.T(jj)));
        end
        plot_format('Phase [deg]','N_{rel}','',12);
        legend(str);
        grid on;
%         data = r.data;
%         save('E:\data\21-07-15\fringe-measurements-5GHz','data');
    end
    pause(0.01);
    
%     if r.c.done()
%         data = r.data;
%         save('E:\data\21-07-15\fringe-measurements-5GHz','data');
%     end
    
end