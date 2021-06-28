function ScanSinglePlotNumber(r)

if r.isInit()
    %Initialize run
    %% Detuning used in the run (enter this)
    
        
    %% Simple Scan
     r.data.param = (0:0.1:5);
     r.data.param2 =1;

     %% expectged peaks Scan
%     RS_offset=-160e3;
%     peak1 = -0.7e5;
%     peak2 = -1.8e5;
%     peak3 = 0.5e5;
%     widths = 50e3;
    
    
	%r.data.param2 =(-27e5:0.1e5:0e5);
%     [s,d,f] = guassian_linespace(200,-250e3,150e3,[peak1 widths 1],[peak2 widths 1],[peak3 widths 1]);
%     figure(99);
%     subplot(1,2,1);
%     plot(f,d);
%     subplot(1,2,2);
%     plot(s);
%     r.data.param2 = ones(1,50)*49653.6;
     
    
    %% shuffel!
%     r.data.param2 =r.data.param2(randperm(length(r.data.param2)));
    
    %% Counter and Callback
    r.data.count = RolloverCounter([numel(r.data.param),numel(r.data.param2)]);
    r.numRuns = r.data.count.total;
    
    r.makerCallback = @RhysMOT2;
    
elseif r.isSet()
    %Increment counter
    if r.currentRun ~= 1
        r.data.count.increment;
    end
    
    %Build/upload/run sequence
    r.make(r.data.param(r.data.count.idx(1)),r.data.param2(r.data.count.idx(2)));
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, MOT, param2 : %.3f \n',r.currentRun,r.numRuns,r.data.param2(r.data.count.idx(2)));

elseif r.isAnalyze()
    % Make shorthand variables for indexing
    nn = r.currentRun;
    i1 = r.data.count.idx(1);
    i2 = r.data.count.idx(2);
    pause(1.0); %Wait for other image analysis program to finish with files
%     i2=1;
    %Analyze image data from last image
    c = Abs_Analysis('last');
    r.data.files{i1,i2} = {c.raw.files(1).name,c.raw.files(2).name};

    %% Plottable Data
    r.data.N(i1,i2) = c.N;
%     r.data.Nth(i1,i2) = c.N.*(1-c.becFrac);
%     r.data.Nbec(i1,i2) = c.N.*c.becFrac;
%     r.data.F(i1,i2) = c.becFrac;
%     r.data.xw(i1,i2) = c.gaussWidth(1);
%     r.data.x0(i1,i2) = c.pos(1);
%     r.data.yw(i1,i2) = c.gaussWidth(2);
%     r.data.y0(i1,i2) = c.pos(2);
%     r.data.OD(i1,i2) = c.fitdata.params.gaussAmp(1);
    r.data.OD(i1,i2) = c.peakOD;
%     r.data.Tx(i1,i2) = c.T(1);
%     r.data.Ty(i1,i2) = c.T(2);
    
    %% Catch bad fits
    if c.N > 1e10
       r.data.N(i1,i2) = NaN;
    end
    
    %% Plot single variable 
%     [data_x, sortIdx] = sort(r.data.param2(1:i2));
%     data_y = r.data.N;
%     
%     figure(24);
%     plot(data_x,data_y,'o-')
    
    %% Plot variable against run number (eg hold variables constant and measure fluctuation)
    data_y = r.data.N;
    data_x = (1:1:length(r.data.N));
    figure(23)
    plot(data_x,data_y,'o-')
    
    %% Plot (y1,x) on subplot 1 and (y2,x) on subplot 2
    
%    [data_x, sortIdx] = sort(r.data.param2(1:i2));
%    data_y = r.data.N;
%    data_y = data_y(sortIdx);
%    data_y_2 = r.data.OD;
%    data_y_2 = data_y_2(sortIdx);
%    
%    figure(24);%clf;
%    subplot(1,2,1);
%    cla;
%    plot(data_y,'X-');
%    subplot(1,2,2);
%    plot(data_y_2,'X-');
%   
    %% Plot (y,param2) for a given param1( on subplot 1 and (y,param2) on subplot 2 where each line is a different param1
    
%    [data_x, sortIdx] = sort(r.data.param(1:i1));
%    data_y = r.data.N(:,i2);
%    data_y = data_y(sortIdx);
% 
%     figure(24);
%     subplot(1,2,1);
%     cla;
%     plot(data_x,data_y,'o-');
%     subplot(1,2,2);
%     if length(data_x) == length(r.data.param)
%         if i2 == 1
%             cla;
%         end
%         s = {};
%         for jj = 1:i2
%             s{jj} = sprintf('%.3f',r.data.param2(jj));
%         end
%         plot(data_x,data_y,'o-')
%         hold on
%         legend(s);
%     end
%     
    %% Surface Plot of (y,param1,param2)
    
%     clf(figure(23))
%     if r.currentRun == r.numRuns
%         figure(23);
%         [x,y] = meshgrid(r.data.param,r.data.param2);
%         surf(x,y,r.data.N);
%     end
end