function makeCMOTSequence(sq,varargin)

%
% Define default parameters
%

%time
tCMOT = 5e-3;
%light
TrappingFreq = 5.9;
RepumpFreq = 4;
TrappingAmp = 8;
RepumpAmp = 8;
%mag
MOTBias = 2.9;
Coil3D = 0.8;
Coil3DFine = 5;

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
            case 'tcmot'
                tCMOT = v;
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

%% CMOT Sequence 


%switch off 2DMOT/push beams (stop blowing hot atoms into the 3D MOT)
sq.find('2D Mot coils').set(0); %turn off 2d mag coils
sq.find('CD bit 1').set(0); % switch CD to channel 0
sq.find('87 push').set(0); %turn off push beams
sq.find('85 Push').set(0);
sq.find('2DMot').set(0); %turn off 2dmot light

%CMOT parameters
sq.find('CD Fine/Fast').set(Coil3DFine); 
sq.find('CD2').set(Coil3D);
sq.find('MOT Bias Coil').set(MOTBias);

sq.find('3DMOT freq').set(TrappingFreq); 
sq.find('87 repump freq').set(RepumpFreq); 

sq.find('87 repump amp').set(RepumpAmp); 
sq.find('3DMOT amp').set(TrappingAmp);

sq.delay(tCMOT); %apply CMOT length


end