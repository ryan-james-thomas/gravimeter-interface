function makeDepumpSequence(sq,varargin)

%
% Define default parameters
%

tDepump = 2e-3;
DepumpOnOff = 1;

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
            case 'tdepump'
                tDepump = v;
            case 'depumponoff'
                DepumpOnOff = v;
            case 'dropmot'
                DropMOT = v;
            otherwise
                error('Unsupported option %s',p);
        end
    end
end

%
%Error Check
%

if DepumpOnOff == 1 || DepumpOnOff == 0
    
else
    error('Depump must be on (1) or off (0)');
end

%% Depump sequence

% PGC has atoms in the F=2 state, yet the Mag trap wants atoms in the F=1 state
% Hence there's a depump stage that pumps atoms into F=1
% We do this by leaving the trapping light on without any repump on
% Don't put trapping light to resonance or you will heat. Hope to get more
% cooling by maintaining trapping frequency
if DepumpOnOff == 1
    sq.find('repump switch').set(1); %fiber switch off (its inverted)
    sq.find('87 repump').set(0);
    sq.find('87 repump amp').set(0);
    sq.find('85 repump').set(0);
    sq.find('85 repump amp').set(0);
elseif DepumpOnOff == 0

end

sq.delay(tDepump);

sq.find('3DMOT').set(0);  %Turn off cooling light after depump. You need light off for mag trap

end