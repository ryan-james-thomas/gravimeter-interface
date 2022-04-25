function makeDropSequence(sq,varargin)

%
% Define default parameters
%


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
            case 'tpgc'
                tPGC = v;
            case 'numberofsteps'
                NumberOfSteps = v;
            case 'trappingfreq'
                TrappingFreq = v;
            case 'trappingamp'
                TrappingAmp = v;                
            case 'repumpfreq'
                RepumpFreq = v;
            case 'repumpamp'
                RepumpAmp = v;
            case 'motbias'
                MOTBias = v;
            case 'coil3dfine'
                Coil3DFine = v;                
            otherwise
                error('Unsupported option %s',p);
        end
    end
end


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


if DropMagOnOff == 1
    sq.find('CD0 Fast').set(0);
    sq.find('CD Fine/Fast').set(0);
    sq.find('Redpower CW').before(100e-6,0);
    sq.find('Redpower TTL').before(100e-6,0);
    sq.find('Keopsys FA').set(0);
    sq.find('Keopsys MO').set(0);
end


end