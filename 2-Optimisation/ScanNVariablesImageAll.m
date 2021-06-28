%Scanning Function
function ScanSinglePlotNumber(r)
if r.isInit()
    %Initialize run
    %% Analysis Requirements (enter this for your run)
    r.data.Detuning = 0;
    r.data.Tdrop = 10e-3;
        
    %Draw a box around your cloud below in second function
    r.data.TopEdge = 1; %this cannot be 0 or the step size determination below fails???
    r.data.BottomEdge = 512;
    r.data.LeftEdge = 200;
    r.data.RightEdge = 800;
    % Note that to change the fit type, you must go to line 178
    
    r.data.imagesPerSet = 3;
    
	%% Simple Scan
	r.data.param = 1;
%     r.data.param = (3.5:0.1:4.3);
%     r.data.param2 = (1:1:30);
	r.data.param2 = (-1:0.05:1)*10^5;

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
    
    r.makerCallback = @RadiCOOLMagRamanImageAll;
    
elseif r.isSet()
    %Increment counter
    if r.currentRun ~= 1
        r.data.count.increment;
    end
    
    %Build/upload/run sequence
    r.make(r.data.param(r.data.count.idx(1)),r.data.param2(r.data.count.idx(2)));
    r.upload;
    %Print information about current run
    fprintf(1,'Run %d/%d, run, param2 : %.3f \n',r.currentRun,r.numRuns,r.data.param2(r.data.count.idx(2)));
%     fprintf(1,'Run %d/%d, bean, param2: %.3f \n',r.currentRun,r.numRuns,r.data.param2(r.data.count.idx(2)),r.data.param(r.data.count.idx(2)));


elseif r.isAnalyze()
    % Make shorthand variables for indexing[rom
    nn = r.currentRun;
    i1 = r.data.count.idx(1);
    i2 = r.data.count.idx(2);
    pause(1.0); %Wait for other image analysis program to finish with files
%     i2=1;
    %Analyze image data from last image
    c = Abs_Analysis_Internal(r.data.Tdrop,r.data.Detuning,r.data.imagesPerSet,r.data.TopEdge,r.data.BottomEdge,r.data.LeftEdge,r.data.RightEdge); %see top
    r.data.files{i1,i2} = {c(1).raw.files(1).name,c(2).raw.files(2).name};

    %% Plottable Data
    %cloud 1 properties
    r.data.N1(i1,i2) = c(1).N;
    r.data.Nsum1(i1,i2) = c(1).Nsum;
    
    %cloud 2 properties
    r.data.N2(i1,i2) = c(2).N;
    r.data.Nsum2(i1,i2) = c(2).Nsum;    
    
%     r.data.Nth(i1,i2) = c.N.*(1-c.becFrac);
%     r.data.Nbec(i1,i2) = c.N.*c.becFrac;
%     r.data.F(i1,i2) = c.becFrac;
%     r.data.xw(i1,i2) = c.gaussWidth(1);
%     r.data.x0(i1,i2) = c.pos(1);
%     r.data.yw(i1,i2) = c.gaussWidth(2);
%     r.data.y0(i1,i2) = c.pos(2);
%     r.data.OD(i1,i2) = c.fitdata.params.gaussAmp(1);
%     r.data.OD(i1,i2) = c.peakOD;
%     r.data.Tx(i1,i2) = c.T(1);
%     r.data.Ty(i1,i2) = c.T(2);

    
    %% Catch bad fits
    %need to make all variables nil
    if c(1).N > 1e10
       r.data.N1(i1,i2) = NaN;
    end
    
    if c(1).N > 1e10
       r.data.Nsum2(i1,i2) = NaN;
    end
    
    %% Plot single variable 
    [data_x, sortIdx] = sort(r.data.param2(1:i2));
    data_y = r.data.N1./r.data.N2;
    
    figure(8);
    plot(data_x,data_y,'o-')
    title(char(datetime))
    ylim([0.,0.7])
    
    
	[data_x, sortIdx] = sort(r.data.param2(1:i2));
    data_y2 = r.data.N1;   
    figure(6);
    plot(data_x,data_y2,'o-')
    title(char(datetime))


	[data_x, sortIdx] = sort(r.data.param2(1:i2));
    data_y3 = r.data.N2;     
    figure(7);
    plot(data_x,data_y3,'o-')
    title(char(datetime))


 %% Plot variable against run number (eg hold variables constant and measure fluctuation)
%     data_y = r.data.N1./r.data.N2;
%     data_y = r.data.N1
%     data_x = (1:1:length(r.data.N1));
%     figure(23)
%     plot(data_x,data_y,'o-');
%     subtitle(char(datetime))
%     title('Imaging Field On')
%     ylim([0.2,0.4])
%     std(data_y)

   
    %% Plot 2 variables on same graph(eg hold variables constant and measure fluctuation)
%     data_y = r.data.N1;
%     data_y2 = r.data.N2;
%     data_x = (1:1:length(r.data.N1));
% 
%     figure(23)
%     plot(data_x,data_y,'o-');
%     hold on;
%     plot(data_x,data_y2,'sq-');
%     hold off;
%     title(char(datetime))

    
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
%    title(char(datetime))
   
    %% Plot (y,param2) for a given param1( on subplot 1 and (y,param2) on subplot 2 where each line is a different param1
	
%     data_y = r.data.N1./r.data.N2;
%     data_x = (1:1:length(r.data.param2));
%     
%     figure(24)
%     title(char(datetime))
%     subplot(1,2,1);
%     cla;
%     plot(data_x,data_y,'o-');
%     subplot(1,2,2);
%     if length(data_x) == length(r.data.param2)
%         if i2 == 1
%             cla;
%         end
%         plot(data_x,data_y,'x-')
%         hold on
%     end   
%     
    
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
%     title(char(datetime))
    
    %% Surface Plot of (y,param1,param2)
    
%     clf(figure(23))
%     if r.currentRun == r.numRuns
%         figure(23);
%         [x,y] = meshgrid(r.data.param,r.data.param2);
%         surf(x,y,r.data.N);
%     end
%    title(char(datetime))

end %end if statement

end %end function














%% abs analysis function called above:
function [cloud,Nsum] = Abs_Analysis_Internal(tof,detuning,imagesPerSet,TopEdge,BottomEdge,LeftEdge,RightEdge)
atomType = 'Rb87';

col1 = 'b.-';
col2 = 'r--';
dispOD = [0,0.5];
plotROI = 0;

numPixels = abs((TopEdge-BottomEdge)*(LeftEdge-RightEdge));
if numPixels > 200^2 && numPixels < 400^2
    stepSize = 2;
elseif numPixels >= 400^2 && numPixels < 600^2
    stepSize = 5;
elseif numPixels >= 600^2
    stepSize = 10;
else
    stepSize = 1;
end

fitdata = AtomCloudFit('roiRow',[TopEdge,BottomEdge],...%was 201
                       'roiCol',[LeftEdge,RightEdge],...
                       'roiStep',stepSize,...
                       'fittype','gauss2d');    %Options: none, gauss1d, twocomp1d, bec1d, gauss2d, twocomp2d, bec2d, sum

imgconsts = AtomImageConstants(atomType,'exposureTime',100e-6,'tof',tof,...
            'pixelsize',5.5e-6,'magnification',0.25,...
            'freqs',2*pi*[40,23,8],'detuning',detuning,... %set detuning here
            'polarizationcorrection',1.5,'satOD',3);

directory = 'D:\RawImages\2020\12December\';

%% Load raw data
raw = RawImageData('filenames','last','directory',directory,'length',imagesPerSet);

%% Analyze data
%
% Create two images, one which is blank
%
cloud = AbsorptionImage(raw,imgconsts,fitdata);
cloud(2) = AbsorptionImage;
%
% Make copies of "constant" classes for the second fit
%
cloud(2).raw.copy(raw);
cloud(2).constants.copy(imgconsts);
cloud(2).fitdata.copy(fitdata);
%
% Make absorption images
%
cloud(1).makeImage([1,3]);
cloud(2).makeImage([2,3]);
%
% Perform fits
%
cloud(1).fit('method','y');  %'y' indicates the marginal distribution to use for calculating number of atoms.  Can also be 'x' or 'xy'
cloud(2).fit('method','y');


% 
% fitdata.image = fitdata.image - offset;     %Subtracts offset from image
% fitdata.fittype = 'sum';                    %Change fit type to 'sum'
% cloud.fit([],tof,'y');                      %Re-'fit' the data
% Nsum = cloud.N;

%% Plot image and fits
figure(3);clf;
cloud(1).plotAllData(dispOD,col1,col2,plotROI);
figure(4);clf;
cloud(2).plotAllData(dispOD,col1,col2,plotROI);

%% Print labels
[labelStr,numStr] = cloud(1).labelOneROI;
disp(labelStr);
disp(numStr);
[~,numStr] = cloud(2).labelOneROI;
disp(numStr);

end