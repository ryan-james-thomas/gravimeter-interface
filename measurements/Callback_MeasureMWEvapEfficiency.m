function Callback_MeasureMWEvapEfficiency(r)

if r.isInit()
    r.data.tof = 30e-3;
    r.data.rf_end = [15:-0.5:1,0.9:-0.1:0.5];
    r.c.setup('var',r.data.rf_end);
elseif r.isSet()
    r.make(r.data.tof,r.data.rf_end(r.c(1))).upload;
    fprintf(1,'Run %d/%d, Param1 = %.3f\n',r.c.now,r.c.total,r.data.rf_end(r.c(1)));
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.25);
    img = Abs_Analysis('last',1);
    if ~img(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end

    r.data.files{i1,1} = img.raw.files;
    r.data.N(i1,1) = img.get('N');
    r.data.T(i1,1) = sqrt(prod(squeeze(img.get('T'))));
    r.data.PSD(i1,1) = img.get('PSD');
    r.data.OD(i1,1) = img.get('peakOD');

    figure(123);
    if r.c.now() == 1
        clf;
    end
    subplot(1,2,1);
    errorbar(r.data.rf_end(1:i1),r.data.PSD(1:i1),0.05*r.data.PSD(1:i1),'o');
    plot_format('RF End [MHz]','PSD','',12);
    ylim([0,Inf]);
    grid on;
    subplot(1,2,2);
    if i1 > 1
        E = diff(log(r.data.T))./diff(log(r.data.N)); 
        plot(r.data.rf_end(2:i1),E,'o-');
        plot_format('RF End [MHz]','Efficiency','',12);
        grid on;
        ylim([0,2]);
    end
end


end