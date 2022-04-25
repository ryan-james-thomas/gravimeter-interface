function makeMOTSequence(sq,varargin)

%
% Define default parameters
%

LoadTime = 11;
TrappingFreq = 7.1;
TrappingAmp = 8;
RepumpFreq = 4.565;
RepumpAmp = 8;
MOTBias = 2.9;
Coil3D = 0.8;
Coil3DFine = 1;

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
            case 'motloadtime'
                LoadTime = v;
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
            case 'coil3d'
                Coil3D = v;
            case 'coil3dfine'
                Coil3DFine = v;
            otherwise
                error('Unsupported option %s',p);
        end
    end
end

%% MOT Sequence 

%
% Turn MOT Digital Channels on
%

sq.find('2DMOT').set(1);
sq.find('3DMOT').set(1);
sq.find('87 repump').set(1);
sq.find('87 push').set(1);
sq.find('CD bit 1').set(1);
sq.find('H-Bridge Quad').set(1);
sq.find('Repump Switch').set(0);


%test
sq.find('MOT Bias').set(0);

%
% Set Analogue Channel Values
%

sq.find('3DMOT Freq').set(TrappingFreq); %7.1
sq.find('3DMOT amp').set(TrappingAmp); %8

sq.find('87 repump freq').set(RepumpFreq);
sq.find('87 repump amp').set(RepumpAmp);
sq.find('MOT Bias Coil').set(MOTBias); 
sq.find('CD2').set(Coil3D);
sq.find('CD Fine/Fast').set(Coil3DFine);

sq.delay(LoadTime);

end