function GravEvapOptimize(r)

if r.isInit()
    %Initialize run
    r.data.evapStart = const.randomize(7:0.05:7.5);
    r.data.evapRate = 0.1:0.05:0.5;
    r.c.setup('var',r.data.evapStart,r.data.evapRate);
    
    r.makerCallback = @makeSequence;
elseif r.isSet()
    %Build/upload/run sequence
    r.make(8.5,25e-3,2,r.data.evapStart(r.c(1)),r.data.evapRate(r.c(2)));
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, Evap Start = %.2f V, Evap Rate = %.2f V/s\n',r.c.now,r.c.total,...
        r.data.evapStart(r.c(1)),r.data.evapRate(r.c(2)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    pause(0.5); %Wait for other image analysis program to finish with files
    %Analyze image data from last image
    c = Abs_Analysis('last');
    r.data.files{i1,i2} = {c.raw.files(1).name,c.raw.files(2).name};
    r.data.N(i1,i2) = c.N;
    r.data.Nsum(i1,i2) = c.Nsum;
    r.data.T(i1,i2) = sqrt(prod(c.T));
    r.data.OD(i1,i2) = c.peakOD;
    
    figure(10);
    subplot(1,2,1);
    errorbar(r.data.evapStart(1:i1),r.data.N(1:i1,i2)/1e8,0.025*r.data.N(1:i1,i2)/1e8,'o');
    plot_format('Start voltage','Number of atoms \times 10^8','',12);
    ylim([0,2.5]);
    grid on;
    if i1 == r.c.imax(1)
        subplot(1,2,2);
        errorbar(r.data.evapStart,r.data.N(:,i2)/1e8,0.025*r.data.N(:,i2)/1e8,'o');
        plot_format('Start voltage','Number of atoms \times 10^8','',12);
        hold on;
        r.data.str{i2} = sprintf('Rate = %.2f',r.data.evapRate(i2));
        legend(r.data.str);
        ylim([0,2.5]);
        grid on;
    end
end