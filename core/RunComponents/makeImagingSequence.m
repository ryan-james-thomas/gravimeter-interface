function makeImagingSequence(sq,varargin)

%
% Define default parameters
%
pulseTime = 30e-6;
repumpTime = 100e-6;
repumpDelay = 00e-6;
fibreSwitchDelay = 20e-3;
camTime = 100e-6;
cycleTime = 40e-3;
repumpFreq = 4.58;
repumpAmplitude = 8;
imgFreq = 8.5;
imgAmplitude = 10;
manifold = 1;
take_dark_image = true;
%
% Parse input arguments as name/value pairs
%
if mod(numel(varargin),2) ~= 0
    error('Input arguments must be in name/value pairs');
else
    for nn = 1:2:numel(varargin)
        p = lower(varargin{nn});
        v = varargin{nn+1};
        switch p
            case 'tof'
                tof = v;
            case 'pulse time'
                pulseTime = v;
            case 'repump time'
                repumpTime = v;
            case 'repump delay'
                repumpDelay = v;
            case 'cycle time'
                cycleTime = v;
            case 'cam time'
                camTime = v;
            case 'repump freq'
                repumpFreq = v;
            case 'repump amp'
                repumpAmplitude = v;
            case 'imaging freq'
                imgFreq = v;
            case 'imaging amplitude'
                imgAmplitude = v;
            case 'fibre switch delay'
                fibreSwitchDelay = v;
            case 'manifold'
                manifold = v;
            case 'take dark image'
                take_dark_image = v;
            otherwise
                error('Unsupported option %s',p);
        end
    end
end


% Set imaging parameters BEFORE you take the image
% sq.find('87 imag freq').set(ImageFreq); %7.61 is 12Mhz, 8.354 is 0mhz
% sq.find('87 imag amp').set(ImageAmp);
% sq.find('87 repump freq').set(4.565); %perpate repump VCO at correct frequency
% sq.find('85 repump freq').set(4.64);
% sq.find('repump switch').set(0); %turn on fibre switch for repump (theres a delay (pat cant remember how long it is))
% sq.find('87 repump amp').set(8); %turn on repump amplitude
sq.find('CD0 Fast').set(0); %zero mag field
sq.find('MOT bias coil').set(2.95); %turn on the imaging coil (to align the axis of atoms)
sq.find('MOT bias').set(1); %ttl on imaging coil


%
% Preamble - set the imaging frequency
%
sq.find('87 imag freq').set(imgFreq);
sq.find('87 imag amp').set(imgAmplitude);

%Repump settings - repump occurs just before imaging
%If manifold is set to image F = 1 state, enable repump. Otherwise,
%disable repumping
if manifold == 1
    % Set repump amplitude and frequency
    sq.find('87 repump freq').set(repumpFreq);
    sq.find('87 repump amp').set(repumpAmplitude);
    %Turn on the repump TTL and the fiber switch (inverted!)
    sq.find('87 repump').after(tof-repumpTime-repumpDelay,1).after(repumpTime,0);
    sq.find('Repump Switch').after(tof - fibreSwitchDelay,0);
end

%
% Imaging beam and camera trigger for image with atoms
%
sq.find('87 imag').after(tof,1).after(pulseTime,0);     %Turn on after TOF, then turn off after pulse time
sq.find('87 cam trig').after(tof,1).after(camTime,0);   %Turn on after TOF, then turn off after camera time
sq.anchor(sq.latest);   %Re-anchor the sequence to the latest value
sq.delay(cycleTime);    %Delay 
%
% Take image without atoms
%
sq.find('87 imag').set(1).after(pulseTime,0);     %Turn on after TOF, then turn off after pulse time
sq.find('87 cam trig').set(1).after(camTime,0);   %Turn on after TOF, then turn off after camera time
sq.anchor(sq.latest);               %Re-anchor the sequence to the latest value
sq.find('Repump Switch').set(1);    %Turn off fiber switch
%
% Take a dark image
%
if take_dark_image
    sq.delay(cycleTime);
    sq.find('87 cam trig').after(tof,1).after(camTime,0);   %Turn on after TOF, then turn off after camera time
    sq.anchor(sq.latest);   %Re-anchor the sequence to the latest value
end
%
% Need a last instruction so that the run ends properly!
%
sq.delay(100e-3);
sq.find('87 imag').set(0);
sq.find('87 repump').set(0);


end