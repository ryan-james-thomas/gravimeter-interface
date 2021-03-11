function varargout = makeSequence(varargin)
    %% Initialize sequence - defaults should be handled here
    sq = initSequence;
    sq.ddsTrigDelay = 1e-3;
    sq.find('ADC trigger').at(sq.ddsTrigDelay+0*15e-6,0);
    sq.dds(1).at(sq.ddsTrigDelay,110,0,0);
    sq.dds(2).at(sq.ddsTrigDelay,110,0,0);
    
    sq.find('3d coils top ttl').set(1);
    sq.find('3d coils bottom ttl').set(1);
    
    sidebandDelay = 3;
    sq.delay(sidebandDelay);
    %% MOT values
    sq.find('87 cooling amp eom').set(2.6);
    sq.find('87 repump amp eom').set(1.6);
    sq.find('3DMOT AOM TTL').set(0);
    sq.find('2DMOT AOM TTL').set(0);
    sq.find('2D coils ttl').set(1);
    sq.find('2d bias').set(1);
    sq.dds(1).set(110,2293,0);
    Tmot = 6;
    sq.delay(Tmot);
    
    %Turn Off 2D MOT
    sq.find('2DMOT AOM TTL').before(0.1,1);
    sq.find('2D Coils TTL').before(0.1,0);
    sq.find('2D Bias').before(0.1,0);
    
    %Shift Bias and CMOT
    t = linspace(50e-3,0,50);
    sq.find('Vertical Bias').before(t,sq.minjerk(t,sq.find('Vertical Bias').values(end),5));
    sq.find('N/S Bias').before(t,sq.minjerk(t,sq.find('N/S Bias').values(end),5.4));
    sq.find('E/W Bias').before(50e-3,0.8);
    sq.find('87 Cooling Freq EOM').before(t,sq.minjerk(t,sq.find('87 Cooling Freq EOM').values(end),3));
    sq.find('3D Coils Bottom').before(t,sq.minjerk(t,sq.find('3D Coils Bottom').values(end),0.13));
    sq.find('3D Coils Top').before(t,sq.minjerk(t,sq.find('3D Coils Top').values(end),0.14));
    
    Tcmot = 15e-3;
    sq.delay(Tcmot);
    
    %PGC
    tmag = linspace(0,5e-3,25);
    sq.find('3D Coils Bottom').after(tmag,sq.minjerk(tmag,sq.find('3D Coils Bottom').values(end),0));
    sq.find('3D Coils Top').after(tmag,sq.minjerk(tmag,sq.find('3D Coils Top').values(end),0.));
    sq.find('3D Coils Bottom TTL').after(5e-3,0);
    sq.find('3D Coils Top TTL').after(5e-3,0);
    
    sq.find('Vertical Bias').set(1);
    sq.find('E/W Bias').set(0.55);
    sq.find('N/S Bias').set(0.78);
    
    sq.find('87 Cooling Freq EOM').set(0);
    sq.find('87 Repump Amp EOM').set(1.5);
    
    t=linspace(0,15e-3,75);
%     sq.find('3DHMOT Amp AOM').after(t,sq.linramp(t,sq.find('3DHMot Amp AOM').values(end),-0.1));
    
%    sq.dds(1).after(t,110*ones(size(t)),sq.minjerk(t,sq.dds(1).values(end,2),485),zeros(size(t)));
%     sq.dds(1).after(t,110*ones(size(t)),sq.linramp(t,sq.dds(1).values(end,2),485),zeros(size(t)));
    
    
    %depump
    sq.find('87 Repump TTL EOM').after(15e-3,0);
    sq.delay(18e-3);    
    
    %%Drop MOT
    sq.find('3DMOT AOM TTL').set(1);
    sq.find('3DHMOT Amp AOM').set(-0.45);
    sq.dds(1).set(110,0,0);
    
    %% Ramp coils
    %t = linspace(0,100e-3,100);
    %sq.find('3d coils top').after(t,sq.linramp(t,sq.find('3d coils top').values(end),0));
    %sq.find('3d coils bottom').after(t,sq.linramp(t,sq.find('3d coils bottom').values(end),0));
    
    %%Take Absorption Image
    Tdrop = 15*10^-3;
    sq.delay(Tdrop);
    
     sq.find('87 Cooling Freq EOM').before(0.1*10^-3,7.91);
     sq.find('87 Cooling Amp EOM').before(0.1*10^-3,2);
     sq.find('87 Repump Freq EOM').before(0.1*10^-3,2.076);
     sq.find('87 Repump Amp EOM').before(0.1*10^-3,4);
     
%     %repump pulse     
     sq.find('87 Repump TTL EOM').set(1);
     sq.find('Imaging AOM TTL').set(1);
%     %imaging pulse
     sq.find('87 Repump TTL EOM').after(0.3*10^-3,0);
     sq.find('Camera Trigger').after(0.3*10^-3,1);
     sq.find('87 Repump Amp EOM').after(0.3*10^-3,0);
     sq.find('87 Cooling Amp EOM').after(0.3*10^-3,2.6);
%     %after imagepulse settings
     sq.find('87 Cooling Freq EOM').after(0.4*10^-3,0);
     sq.find('Camera Trigger').after(0.4*10^-3,0);
     sq.find('Imaging AOM TTL').after(0.4*10^-3,0);
     sq.find('87 Repump Amp EOM').after(0.4*10^-3,1.7);
    
     TbackgroundPic=0.1;
     sq.delay(TbackgroundPic);
    
    %BackgroundImage
    
      sq.find('87 Cooling Freq EOM').before(0.1*10^-3,7.91);
     sq.find('87 Cooling Amp EOM').before(0.1*10^-3,2);
     sq.find('87 Repump Freq EOM').before(0.1*10^-3,2.076);
     sq.find('87 Repump Amp EOM').before(0.1*10^-3,4);
     
%     %repump pulse     
     sq.find('87 Repump TTL EOM').set(1);
     sq.find('Imaging AOM TTL').set(1);
%     %imaging pulse
     sq.find('87 Repump TTL EOM').after(0.3*10^-3,0);
     sq.find('Camera Trigger').after(0.3*10^-3,1);
     sq.find('87 Repump Amp EOM').after(0.3*10^-3,0);
     sq.find('87 Cooling Amp EOM').after(0.3*10^-3,2.6);
%     %after imagepulse settings
     sq.find('87 Cooling Freq EOM').after(0.4*10^-3,0);
     sq.find('Camera Trigger').after(0.4*10^-3,0);
     sq.find('Imaging AOM TTL').after(0.4*10^-3,0);
     sq.find('87 Repump Amp EOM').after(0.4*10^-3,1.7);
    
    Tcleanup=0.1;
    sq.delay(Tcleanup);
    %% Finish
    sq.find('87 Repump TTL EOM').set(1);
    sq.find('87 repump amp eom').set(4);
    t = linspace(0,1,100);
    sq.find('87 cooling amp eom').after(t,sq.linramp(t,sq.find('87 cooling amp eom').values(end),0));
%     sq.dds(1).after(t,110-2*t,45*ones(size(t)),zeros(size(t)));
    
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