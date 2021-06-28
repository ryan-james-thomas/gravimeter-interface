function varargout = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    RStable=double.empty(2,0);
    
    sq = initSequence;
    sq.ddsTrigDelay = 1e-3;
    sq.find('ADC trigger').at(sq.ddsTrigDelay+0*15e-6,0); %when we thought there was a difference in clock rates
    sq.dds(1).at(sq.ddsTrigDelay,110,0,0); 
    sq.dds(2).at(sq.ddsTrigDelay,110,0,0);
    
    sq.find('3d coils top ttl').set(1);  %don't trust the initSequence
    sq.find('3d coils bottom ttl').set(1);
    
    sq.find('87 Repump TTL EOM').after(100e-3,0);
    sq.find('85 Repump TTL EOM').set(1);
    sq.find('87 Repump amp EOM').after(100e-3,0);
    sq.find('85 Repump amp EOM').set(10);
    sidebandDelay = 3;
    sq.delay(sidebandDelay);
        
    %TurnOnDipoles
    sq.find('WG 1 TTL').set(1);
    sq.find('WG 2 TTL').set(1);
    sq.find('WG 3 TTL').set(1);
    sq.find('WG AMP 1').set(0);
    sq.find('WG AMP 2').set(0);
    sq.find('WG AMP 3').set(0);
    
    %% MOT values
    coolingFrequency=-18;
    repumpFrequency=0;
    
    sq.find('87 cooling freq eom').set(Freq2ToV(repumpFrequency,coolingFrequency,'c'));
    sq.find('87 cooling amp eom').set(3);%was 2.6 in old run
    sq.find('85 repump amp eom').set(2.1);
    RStable(:,end+1) = [double(Freq2ToV(repumpFrequency,coolingFrequency,'r'))*-1e6; 19];
    sq.dds(1).set(110,3000,0);
    
    sq.find('3D Coils Top').set(0.15);
    sq.find('3D Coils Bottom').set(0.15);
    sq.find('3DMOT AOM TTL').set(0);
    sq.find('2DMOT AOM TTL').set(0);
    sq.find('2D coils ttl').set(1);
	sq.find('2d bias').set(1);
    
	Tmot = 6;  
    sq.delay(Tmot);
    
    %% CMOT
%     cMOTFrequency = -36;
%     tCmotDelay = 100e-3;
%     tCmotRamp = linspace(0,tCmotDelay,50);
%     sq.find('87 Cooling Freq EOM').after(tCmotRamp,sq.minjerk(tCmotDelay,sq.find('87 Cooling Freq EOM').values(end),Freq2ToV(0,cMOTFrequency,'c')));  %3
%     sq.delay(tCmotDelay)
    
    %% PGC Prep
    %Turn Off 2D MOT to stop pushing hot atoms into MOT
	sq.find('2DMOT AOM TTL').before(0.1,1);
    sq.find('2D Coils TTL').before(0.1,0);
    sq.find('2D Bias').before(0.1,0);
    
    %Shift Bias (align MOT with mag trap centre) and CMOT
    TpushDelay= 100e-3;
    tPush = linspace(0,TpushDelay,50);
    
    %mag field push
    sq.find('Vertical Bias').after(tPush,sq.minjerk(tPush,sq.find('Vertical Bias').values(end),1.3)); %5
    sq.find('N/S Bias').after(tPush,sq.minjerk(tPush,sq.find('N/S Bias').values(end),5));  %5.2
    sq.find('E/W Bias').set(1); %0.8
    sq.find('3D Coils Bottom').after(tPush,sq.minjerk(tPush,sq.find('3D Coils Bottom').values(end),0.18));
    sq.find('3D Coils Top').after(tPush,sq.minjerk(tPush,sq.find('3D Coils Top').values(end),0.214));
    
    %CMOT prep
    cMOTFrequency = -36;
    sq.find('87 Cooling Freq EOM').after(tPush,sq.minjerk(tPush,sq.find('87 Cooling Freq EOM').values(end),Freq2ToV(0,cMOTFrequency,'c')));  %3
        
    sq.delay(TpushDelay); 
    
    %% CMOT
    Tcmot = 15e-3;
    sq.delay(Tcmot);
    
    %% PGC 
    %PGC requires B=0 and reduced scattering rate
        %Note that these events start at the same time
 
    %mag field zeroing
    tMagZero=5e-3;
    tMagZeroRamp = linspace(0,tMagZero,25);
    
    sq.find('Vertical Bias').set(3.1);
    sq.find('E/W Bias').set(0.7);
    sq.find('N/S Bias').set(0.8);
    sq.find('3D Coils Bottom').after(tMagZeroRamp,sq.minjerk(tMagZeroRamp,sq.find('3D Coils Bottom').values(end),0));
    sq.find('3D Coils Top').after(tMagZeroRamp,sq.minjerk(tMagZeroRamp,sq.find('3D Coils Top').values(end),0.));
    sq.find('3D Coils Bottom TTL').after(tMagZero,0);
    sq.find('3D Coils Top TTL').after(tMagZero,0);
       
    %reduce scattering rate
    sq.find('87 Cooling Freq EOM').set(Freq2ToV(0,-60,'c'));
    sq.find('85 Repump Amp EOM').set(2);
    tScatterLength= 15e-3;
    tScatterRate=linspace(0,tScatterLength,75);
    sq.find('3DHMOT Amp AOM').after(tScatterRate,sq.minjerk(tScatterRate,sq.find('3DHMot Amp AOM').values(end),-0.35));
    sq.dds(1).after(tScatterRate,110*ones(size(tScatterRate)),sq.minjerk(tScatterRate,sq.dds(1).values(end,2),480),zeros(size(tScatterRate))); %485
    
    sq.delay(tScatterLength);
    
    %% Mag Prep
        %depump into the F=1 ground state 
            %microwave drives |1,-1> -> |2,-1> for evap)
    tdepump=3e-3;
    sq.find('85 Repump TTL EOM').set(0);
    sq.find('87 Cooling Freq EOM').after(3.5e-3,Freq2ToV(0,0,'c'));
    sq.delay(tdepump);    
    
    %% Turn off
    %Drop MOT so that the atoms may be held in the Mag trap
    sq.find('3DMOT AOM TTL').set(1);
    sq.find('3DHMOT Amp AOM').set(-0.45);
    sq.dds(1).set(110,0,0);
    
    %mark drop
    droptime=sq.time; 
    
    %% Imaging 
    sq.find('Vertical Bias').set(3);
    sq.find('E/W Bias').set(3);      %set the fields needed for image
    
    %% drop
    Tdrop = 25*10^-3;
  %  Tdrop = varargin{1};
    sq.delay(Tdrop);

    %% FMI Imaging
%     imageVoltages= FreqToV(-24,-24.,'b');
%     sq.find('Imaging AOM Amp').set(10);
%     sq.find('Bragg SSM Switch').set(0);
%     sq.find('87 Cooling Freq EOM').set(imageVoltages(2));
%     sq.find('87 Cooling Amp EOM').set(2.6);
%     sq.find('87 Repump Freq EOM').set(imageVoltages(1));
%     sq.find('87 Repump Amp EOM').set(1.7);
%     sq.find('87 Repump TTL EOM').set(1);
%     sq.find('Imaging AOM TTL').set(1);
%     sq.find('FMI Trigger').set(1);
%     
%     tFMI = 200e-3;
%     sq.delay(tFMI);
%% Asorption Imaging
    imageVoltages= Freq2ToV(0,0,'b'); %get both voltage, repump and cool
    RStable(:,end+1) = [double(imageVoltages(1))*-1e6; 19];
    sq.find('Repump/Microwave Switch').set(0);
    sq.find('Bragg SSM Switch').before(0.1e-3,0);
    sq.find('87 Cooling Freq EOM').before(0.1*10^-3,imageVoltages(2));
    sq.find('87 Cooling Amp EOM').before(0.1*10^-3,3);
    sq.find('SSB Carrier').set(0);
	sq.find('85 Repump Amp EOM').before(0.1*10^-3,3);
    sq.find('RS Microwave TTL').set(1);
    sq.find('RS Microwave TTL').after(200e-6,0);
       
    sq.anchor(sq.latest);
    
	%repump pulse
	Trepump=0.3*10^-3;
	sq.find('85 Repump TTL EOM').set(1);
    sq.find('Imaging AOM TTL').set(1);
	%imaging pulse
    Timage=0.1*10^-3;
    sq.find('85 Repump TTL EOM').after(Trepump,0);
    sq.find('Camera Trigger').after(Trepump,1);
    sq.find('Bragg SSM Switch').before(0.1e-3,0); 
    sq.find('85 Repump Amp EOM').after(Trepump,0);
    sq.find('87 Cooling Amp EOM').after(Trepump,3);
    %after imagepulse settings
    sq.find('87 Cooling Freq EOM').after(Trepump+Timage,Freq2ToV(0,-60,'c'));
    sq.find('Camera Trigger').after(Timage,0);
    sq.find('Imaging AOM TTL').after(Trepump+Timage,0); %Note that this wasn't called in the repump pulse, hence you have to use both times
    sq.find('85 Repump Amp EOM').after(Timage,3);
    
    TbackgroundPic=0.1;
    sq.delay(TbackgroundPic);
    
    %BackgroundImage (ramp VCOs to desired value for imaging/repump)
    
    sq.find('87 Cooling Freq EOM').before(0.1*10^-3,imageVoltages(2));
    sq.find('87 Cooling Amp EOM').before(0.1*10^-3,3);
    % sq.find('87 Repump Freq EOM').before(0.1*10^-3,imageVoltages(1));
    sq.find('85 Repump Amp EOM').before(0.1*10^-3,3);
       
    sq.anchor(sq.latest);
    
	%repump pulse
    Trepump=0.3*10^-3;
    sq.find('85 Repump TTL EOM').set(1);
    sq.find('Imaging AOM TTL').set(1);
    %imaging pulse
    Timage=0.1*10^-3;
    sq.find('85 Repump TTL EOM').after(Trepump,0);
    sq.find('Camera Trigger').after(Trepump,1);
    sq.find('Bragg SSM Switch').before(0.1e-3,0); 
    sq.find('85 Repump Amp EOM').after(Trepump,0);
    sq.find('87 Cooling Amp EOM').after(Trepump,3);
    %after imagepulse settings
    sq.find('87 Cooling Freq EOM').after(Trepump+Timage,Freq2ToV(0,-60,'c'));
    sq.find('Camera Trigger').after(Timage,0);
    sq.find('Imaging AOM TTL').after(Trepump+Timage,0); %Note that this wasn't called in the repump pulse, hence you have to use both times
    sq.find('85 Repump Amp EOM').after(Timage,3);
    
    Tcleanup=0.2;
    sq.delay(Tcleanup);
 
    %% Finish
	sq.find('85 Repump TTL EOM').set(0);
    sq.find('87 Repump TTL EOM').set(1);
    sq.find('87 Repump amp EOM').set(10);
    sq.find('85 repump amp eom').set(0);
    tReset = linspace(0,1,50);
    sq.find('87 cooling amp eom').after(tReset,sq.linramp(tReset, sq.find('87 cooling amp eom').values(end),0));
   
    
	sq.find('RS Microwave TTL').set(1);
	sq.find('RS Microwave TTL').after(200e-6,0);

    %%upload list to R&S and RESET
    clear RSGen
    RSGen=visadev('TCPIP::192.168.1.3::INSTR');
    RSGen.Timeout=1;
    write(RSGen,"FREQ:MODE LIST")

    %FREQ = [7300000000; 6300000000; 5300000000; 4300000000];
    %POW = [1 2 3 4];
    FREQ = RStable(1,:);
    POW = RStable(2,:);
	FREQstring = strjoin(string(FREQ),', ');
    POWstring = strjoin(string(POW),', ');
    
    write(RSGen,"LIST:SEL '/var/autolist0'","string")
    write(RSGen,strcat("LIST:FREQ ",FREQstring),"string")
    write(RSGen,strcat("LIST:POW ",POWstring),"string")
    write(RSGen,"LIST:MODE STEP","string")
    write(RSGen,"LIST:TRIG:SOUR EXT","string")
    write(RSGen,"LIST:LEAR","string")

    write(RSGen,"LIST:FREQ:POIN?","string")
    FreqPoints=readline(RSGen);
    write(RSGen,"LIST:POW:POIN?","string")
    PowerPoints=readline(RSGen);
    write(RSGen,"LIST:RES","string")

	fprintf('Uploaded %d Frequencies and %d Powers\n',str2num(FreqPoints),str2num(PowerPoints));
    fprintf('Frequencies: %s\nPowers: %s\n',FREQstring,POWstring);
    write(RSGen,"FREQ:MODE LIST")
    
    %% Automatic save of run
    fpathfull = [mfilename('fullpath'),'.m'];
    [fpath,fname,fext] = fileparts(fpathfull);
    dstr = datestr(datetime,'YYYY\\mm\\dd\\hh_MM_ss');
    
    dirname = sprintf('%s\\%s\\%s',fpath,sq.directory,datestr(datetime,'YYYY\\mm\\dd'));
    if ~isfolder(dirname)
        mkdir(dirname);
    end

    copyfile(fpathfull,sprintf('%s\\%s\\%s_%s%s',fpath,sq.directory,dstr,fname,fext));
    %% Automatic start
    %If no output argument is requested, then compile and run the above
    %sequence
    if nargout == 0
        r = RemoteControl;
        r.upload(sq.compile);
        r.run;
    else
        varargout{1} = sq;
    end

end



function makeImagingSequence(sq,varargin)
    imgType = 'in-trap';
    pulseTime = 30e-6;
    repumpTime = 100e-6;
    repumpDelay = 00e-6;
    fibreSwitchDelay = 20e-3;
    camTime = 100e-6;
    pulseDelay = 0;
    cycleTime = 100e-3;
    repumpFreq = 4.3;
    imgFreq = 8.5;
    manifold = 1;
    if mod(numel(varargin),2) ~= 0
        error('Input arguments must be in name/value pairs');
    else
        for nn = 1:2:numel(varargin)
            p = lower(varargin{nn});
            v = varargin{nn+1};
            switch p
                case 'tof'
                    tof = v;
                case 'type'
                    imgType = v;
                case 'pulse time'
                    pulseTime = v;
                case 'repump time'
                    repumpTime = v;
                case 'repump delay'
                    repumpDelay = v;
                case 'pulse delay'
                    pulseDelay = v;
                case 'cycle time'
                    cycleTime = v;
                case 'cam time'
                    camTime = v;
                case 'repump freq'
                    repumpFreq = v;
                case 'imaging freq'
                    imgFreq = v;
                case 'fibre switch delay'
                    fibreSwitchDelay = v;
                case 'manifold'
                    manifold = v;
                otherwise
                    error('Unsupported option %s',p);
            end
        end
    end
    
    switch lower(imgType)
        case {'in trap','in-trap','trap','drop 1'}
            camChannel = 'cam trig';
            imgType = 0;
        case {'drop 2'}
            camChannel = 'drop 1 camera trig';
            imgType = 1;
        otherwise
            error('Unsupported imaging type %s',imgType);
    end
    
    %Preamble
    sq.find('imaging freq').set(imgFreq);

    %Repump settings - repump occurs just before imaging
    %If manifold is set to image F = 1 state, enable repump. Otherwise,
    %disable repumping
    if imgType == 0 && manifold == 1
        sq.find('liquid crystal repump').set(-2.22);
        sq.find('repump amp ttl').after(tof-repumpTime-repumpDelay,1);
        sq.find('repump amp ttl').after(repumpTime,0);
        if ~isempty(repumpFreq)
            sq.find('repump freq').after(tof-repumpTime-repumpDelay,repumpFreq);
        end
    elseif imgType == 1 && manifold == 1
        sq.find('liquid crystal repump').set(7);
        sq.find('drop repump').after(tof-repumpTime-repumpDelay,1);
        sq.find('drop repump').after(repumpTime,0);
        sq.find('fiber switch repump').after(tof-fibreSwitchDelay,1);   
        if ~isempty(repumpFreq)
            sq.find('drop repump freq').after(tof-repumpTime-repumpDelay,4.3);
        end
    end
     
    %Imaging beam and camera trigger for image with atoms
    sq.find('Imaging amp ttl').after(tof+pulseDelay,1);
    sq.find(camChannel).after(tof,1);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find(camChannel).after(camTime,0);
    sq.anchor(sq.latest);
    sq.delay(cycleTime);
    
    %Take image without atoms
    sq.find('Imaging amp ttl').after(pulseDelay,1);
    sq.find(camChannel).set(1);
    sq.find('imaging amp ttl').after(pulseTime,0);
    sq.find(camChannel).after(camTime,0);
    sq.anchor(sq.latest);
    sq.find('fiber switch repump').set(0);
    
end