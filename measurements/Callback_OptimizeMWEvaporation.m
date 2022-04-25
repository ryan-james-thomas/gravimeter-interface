function Callback_OptimizeMWEvaporation(r)

if r.isInit()
    r.data.tof = 30e-3;
    r.data.freq = const.randomize(10:1:15);  %MHz
    r.data.rate = 2:1:5;  %MHz/s
    r.c.setup('var',r.data.freq,r.data.rate);
elseif r.isSet()
    r.make(r.data.tof,r.data.freq(r.c(1)),r.data.rate(r.c(2))).upload;
    fprintf('Run %d/%d, RF Freq. = %.3f MHz, Rate = %.3f MHz/s\n',r.c.now,r.c.total,r.data.freq(r.c(1)),r.data.rate(r.c(2)));
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    pause(0.1);
    img = Abs_Analysis('last',1);
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    
    r.data.files{i1,i2} = img.raw.files;
    r.data.N(i1,i2) = img.get('N');
    r.data.T(i1,i2) = sqrt(prod(squeeze(img.get('T'))));
    r.data.PSD(i1,i2) = img.get('PSD');
    
    if r.c.now() == 1
        figure(123);clf;
        r.data.ax = subplot(1,2,1);
        r.data.ax(2) = subplot(1,2,2);
    end
    
    plot(r.data.ax(1),r.data.freq(1:i1),r.data.PSD(1:i1,i2),'o');
    plot_format('RF Frequency [MHz]','PSD','',12);

    if r.c.done(1)
        plot(r.data.ax(2),r.data.freq,r.data.PSD(:,i2),'o');
        hold(r.data.ax(2),'on');
        for nn = 1:i2
            s{nn} = sprintf('Rate = %.3f',r.data.rate(nn));
        end
        legend(r.data.ax(2),s);
    end
end


end