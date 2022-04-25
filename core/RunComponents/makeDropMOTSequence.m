function makeDropMOTSequence(sq,varargin)

%
% Define default parameters
%

DropMOTOnOff = 0;

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
            case 'dropmotonoff'
                DropMOTOnOff = v;
            otherwise
                error('Unsupported option %s',p);
        end
    end
end

%
%Error Check
%

if DropMOTOnOff == 1 || DropMOTOnOff == 0
    
else
    error('Depump must be on (1) or off (0)');
end

%% Drop
% If there is no mag trap etc after the MOT, you will want to turn the
% coils and light off to drop your cloud. This is done here

if DropMOTOnOff == 1
    sq.find('3DMOT amp').set(0);
    sq.find('3DMOT').set(0);
    sq.find('2DMOT').set(0);
    sq.find('87 repump').set(0);
    sq.find('CD fine/Fast').set(0);
    sq.find('CD bit 1').set(0);
    sq.find('H-Bridge Quad').set(0);
    sq.find('2D MOT Coils').set(0);
    timeAtDrop = sq.time;
end

end