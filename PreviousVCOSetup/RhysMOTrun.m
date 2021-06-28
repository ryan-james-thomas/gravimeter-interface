function varargout = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
        
    sq = initSequence;
    sq.ddsTrigDelay = 1e-3;
    sq.find('ADC trigger').at(sq.ddsTrigDelay+0*15e-6,0); %when we thought there was a difference in clock rates
    sq.dds(1).at(sq.ddsTrigDelay,110,0,0); 
    sq.dds(2).at(sq.ddsTrigDelay,110,0,0);
    
    sq.find('3d coils top ttl').set(1);  %don't trust the initSequence
    sq.find('3d coils bottom ttl').set(1);
    
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
%     coolingFrequency=varargin{2};
    repumpFrequency=0;
    
    sq.find('87 cooling freq eom').set(FreqToV(repumpFrequency,coolingFrequency,'c'));
    sq.find('87 cooling amp eom').set(2.6);
    sq.find('87 repump amp eom').set(1.6);
    sq.find('87 repump freq eom').set(FreqToV(repumpFrequency,coolingFrequency,'r'));
    sq.dds(1).set(110,3000,0);

%     sq.find('3D Coils Top').set(varargin{1});
%     sq.find('3D Coils Bottom').set(varargin{1});
    sq.find('3D Coils Top').set(0.15);
    sq.find('3D Coils Bottom').set(0.15);
    sq.find('3DMOT AOM TTL').set(0);
    sq.find('2DMOT AOM TTL').set(0);
    sq.find('2D coils ttl').set(1);
    sq.find('2d bias').set(1);
    
    Tmot = 6;
    sq.delay(Tmot);
    
    
    tdepump=3e-3;
    sq.find('87 Repump TTL EOM').set(0);
    sq.delay(tdepump);    
    
    %Drop MOT so that the atoms may be held in the Mag trap
    sq.find('3DMOT AOM TTL').set(1);
    sq.find('87 Repump TTL EOM').set(0);
    sq.find('3DHMOT Amp AOM').set(-0.45);
    sq.dds(1).set(110,0,0);
    droptime=sq.time; %mark drop

   
%%Mag Field For Drop
    sq.find('87 repump freq eom').set(FreqToV(0,-8,'r'));  % The repump VCOs are slow, start ramp now

    
    %%Take Absorption Image
    sq.anchor(sq.latest);
    sq.anchor(droptime);
    sq.find('Vertical Bias').before(1e-3,3);
    sq.find('E/W Bias').before(1e-3,3);      %set the fields needed for image
  
    Tdrop = 15*10^-3;
    %Tdrop = varargin{1};
    sq.delay(Tdrop);
    

    imageVoltages= FreqToV(0,-0,'b'); %get both voltage, repump and cool
    
     sq.find('Bragg SSM Switch').before(0.1e-3,0);   
     sq.find('87 Cooling Freq EOM').before(0.1*10^-3,imageVoltages(2));
     sq.find('87 Cooling Amp EOM').before(0.1*10^-3,2.6);
     sq.find('87 Repump Freq EOM').before(0.1*10^-3,imageVoltages(1));
     sq.find('87 Repump Amp EOM').before(0.1*10^-3,4);
       
    sq.anchor(sq.latest);
    
%    %repump pulse
     Trepump=0.3*10^-3;
     sq.find('87 Repump TTL EOM').set(1);
     sq.find('Imaging AOM TTL').set(1);
%    %imaging pulse
     Timage=0.1*10^-3;
     sq.find('87 Repump TTL EOM').after(Trepump,0);
     sq.find('Camera Trigger').after(Trepump,1);
     sq.find('87 Repump Amp EOM').after(Trepump,0);
     sq.find('87 Cooling Amp EOM').after(Trepump,2.6);
%    %after imagepulse settings
     sq.find('87 Cooling Freq EOM').after(Trepump+Timage,0);
     sq.find('Camera Trigger').after(Timage,0);
     sq.find('Imaging AOM TTL').after(Trepump+Timage,0); %Note that this wasn't called in the repump pulse, hence you have to use both times
     sq.find('87 Repump Amp EOM').after(Timage,1.7);
    
     TbackgroundPic=0.1;
     sq.delay(TbackgroundPic);
    
    %BackgroundImage (ramp VCOs to desired value for imaging/repump)
    
     sq.find('87 Cooling Freq EOM').before(0.1*10^-3,imageVoltages(2));
     sq.find('87 Cooling Amp EOM').before(0.1*10^-3,2);
     sq.find('87 Repump Freq EOM').before(0.1*10^-3,imageVoltages(1));
     sq.find('87 Repump Amp EOM').before(0.1*10^-3,4);
       
    sq.anchor(sq.latest);
    
%    %repump pulse
     Trepump=0.3*10^-3;
     sq.find('87 Repump TTL EOM').set(1);
     sq.find('Imaging AOM TTL').set(1);
%    %imaging pulse
     Timage=0.1*10^-3;
     sq.find('87 Repump TTL EOM').after(Trepump,0);
     sq.find('Camera Trigger').after(Trepump,1);
     sq.find('87 Repump Amp EOM').after(Trepump,0);
     sq.find('87 Cooling Amp EOM').after(Trepump,2.6);
%    %after imagepulse settings
     sq.find('87 Cooling Freq EOM').after(Trepump+Timage,0);
     sq.find('Camera Trigger').after(Timage,0);
     sq.find('Imaging AOM TTL').after(Trepump+Timage,0);
     sq.find('87 Repump Amp EOM').after(Timage,1.7);
    
    Tcleanup=0.1;
    sq.delay(Tcleanup);
    %% Finish
    sq.find('87 Repump TTL EOM').set(1);
    sq.find('87 repump amp eom').set(4);
    tReset = linspace(0,1,50);
    sq.find('87 cooling amp eom').after(tReset,sq.linramp(tReset, sq.find('87 cooling amp eom').values(end),0));
   
%     sq.dds(1).after(t,110-2*t,45*ones(size(t)),zeros(size(t)));
    
    %% Automatic save of run
    fpathfull = [mfilename('fullpath'),'.m'];
    [fpath,fname,fext] = fileparts(fpathfull);
    dstr = datestr(datetime,'YY_mm_dd_hh_MM_ss');
    copyfile(fpathfull,sprintf('%s/%s/%s_%s%s',fpath,sq.directory,fname,dstr,fext));
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