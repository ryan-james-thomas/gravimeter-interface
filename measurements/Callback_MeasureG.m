function Callback_MeasureG(r)

if r.isInit()
    r.data.phase = 0:10:180;
    r.data.T = [1,2,5]*1e-3;
    r.c.setup('var',r.data.phase,r.data.T);
elseif r.isSet()
    
    r.make(0,216.5e-3,1.17,0.2,r.data.phase(r.c(1)),r.data.T(r.c(2)));
    r.upload;
    fprintf(1,'Run %d/%d, T = %.2f ms, Phase: %.2f\n',r.c.now,r.c.total,...
        r.data.T(r.c(2))*1e3,r.data.phase(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    i2 = r.c(2);
    pause(0.5);
    c = Abs_Analysis_NClouds('last');
    if ~c(1).raw.status.ok()
        %
        % Checks for an error in loading the files (caused by a missed
        % image) and reruns the last sequence
        %
        r.c.decrement;
        return;
    end
    r.data.c{i1,i2} = c;
    r.data.files{i1,i2} = c(1).raw.files;
    r.data.N(i1,i2,:) = reshape([c.N],[1,1,2]);
    r.data.Nsum(i1,i2,:) = reshape([c.Nsum],[1,1,2]);
    r.data.R(i1,i2) = r.data.N(i1,i2,1)./sum(r.data.N(i1,i2,:));
    r.data.Rsum(i1,i2) = r.data.Nsum(i1,i2,1)./sum(r.data.Nsum(i1,i2,:));
    nlf = nonlinfit;
    nlf.setFitFunc(@(y0,A,phi,x) y0+A*cos(pi/2*x+phi));
    nlf.bounds([0.4,0.25,-pi],[0.6,0.5,pi],[0.5,0.4,0]);
    
    figure(98);
    subplot(1,2,1);
    errorbar(r.data.phase(1:i1),r.data.R(1:i1,i2),0.02*ones(size(r.data.R(1:i1,i2))),'o');
    hold on;
    errorbar(r.data.phase(1:i1),r.data.Rsum(1:i1,i2),0.02*ones(size(r.data.Rsum(1:i1,i2))),'sq');
    hold off;
    plot_format('Phase [deg]','N_{rel}','',12);
    subplot(1,2,2);
    if r.c.done(1)
        cla;
        for mm = 1:i2
            errorbar(r.data.phase,r.data.Rsum(:,mm),0.02*ones(size(r.data.Rsum(:,mm))),'o');
            hold on;
            nlf.set(r.data.phase*pi/180,r.data.Rsum(:,mm),0.02*ones(size(r.data.Rsum(:,mm))));
            r.data.coeffs{mm} = nlf.fit;
            plot(r.data.phase,nlf.f(r.data.phase*pi/180),'-');
            str{mm} = sprintf('Time = %d ms',round(1e3*r.data.T(mm)));
        end
        plot_format('Phase [deg]','N_{rel}','',12);
        legend(str);
    end
    pause(0.01);
    
end