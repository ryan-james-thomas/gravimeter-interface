function Callback_MeasureRamanPower(r)

if r.isInit()
    r.data.power = 0:0.025:0.75;
    
    r.c.setup('var',r.data.power);
elseif r.isSet()
    
     r.make(0,216.65e-3,1.175,0.29,0,5e-3,r.data.power(r.c(1)));
    r.upload;
    fprintf(1,'Run %d/%d, P = %.3f\n',r.c.now,r.c.total,...
        r.data.power(r.c(1)));
    
elseif r.isAnalyze()
    i1 = r.c(1);
    pause(0.1);
    c = Abs_Analysis_NClouds('last');
    if ~c(1).raw.status.ok()
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
    r.data.files{i1,1} = {c(1).raw.files(1).name,c(1).raw.files(2).name};
    %
    % Get processed data
    %
    r.data.N(i1,:) = c.get('N');
    r.data.Nsum(i1,:) = c.get('Nsum');
    r.data.R(i1,:) = r.data.N(i1,:)./sum(r.data.N(i1,:));
    r.data.Rsum(i1,:) = r.data.Nsum(i1,:)./sum(r.data.Nsum(i1,:));
    
    figure(98);
%     plot(r.data.power(1:i1),r.data.R(1:i1,:),'o-');
%     hold on;
    plot(r.data.power(1:i1),r.data.Rsum(1:i1,:),'sq-');
%     hold off;
    plot_format('Power [arb]','Population','',12);
    grid on;
    h = legend('m = 1','m = 0','m = -1');
    set(h,'Location','West');
    
end