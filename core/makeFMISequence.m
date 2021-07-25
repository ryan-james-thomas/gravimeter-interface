function makeFMISequence(sq,varargin)
    
%% Parse parameters
tof = 730e-3;
manifold = 1;
imgFreq = 8.5;
repumpFreq = 4.3;
fibreSwitchDelay = 20e-3;
repumpTime = 100e-6;
repumpDelay = 00e-6;
duration = 100e-3;
offset = 30e-3;

if mod(numel(varargin),2) ~= 0
    error('Input arguments must be in name/value pairs');
else
    for nn = 1:2:numel(varargin)
        p = lower(varargin{nn});
        v = varargin{nn+1};
        switch p
            case 'tof'
                tof = v;
            case 'duration'
                duration = v;
            case 'offset'
                offset = v;
            case 'repump time'
                repumpTime = v;
            case 'repump delay'
                repumpDelay = v;
            case 'pulse delay'
                pulseDelay = v;
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

%% Create sequence
sq.delay(tof - offset);
sq.find('F MOD Imaging Trigger').set(1).after(1e-3,0);
sq.find('imaging freq').set(imgFreq);
if manifold == 1
    sq.find('liquid crystal repump').set(7);
    sq.find('fiber switch repump').before(fibreSwitchDelay,1); 
    sq.find('drop repump freq').set(repumpFreq);
    sq.find('drop repump').set(1);
end
sq.find('Imaging Amp TTL').set(1);
sq.delay(duration);
sq.find('fiber switch repump').set(0); 
sq.find('drop repump').set(0);
sq.find('Imaging Amp TTL').set(0);




end