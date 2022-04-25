function makePGCSequence(sq,varargin)

%
% Define default parameters
%

%time
tPGC = 5e-3;
NumberOfSteps = 30;
%light
TrappingFreq = 2.2;
RepumpFreq = 3.87;
TrappingAmp = 5;
RepumpAmp = 8;
%mag
MOTBias = 0.3;
Coil3DFine = 0.6;

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

%% PGC Sequence 

% tPGC = 10e-3;
t = linspace(0,tPGC,NumberOfSteps);    % t vector is an array of times from 0 to 'tPGC' in 'NumberOfSteps' steps

        % sq.minjerk(t,init, final) creates a ramp from init to final with
        % times t using a minimum jerk profile
        % Minimum jerk profile is an s shaped curve
        % from the initial to the final value where
        % the jerk of this curve (third derivative)
        % is minimised. The acceleration (second
        % derrivative) of the first/final point in
        % the curve is zero.
        
        %sq.find('chan').values(end) : find the last set value of the
        % 'chan' channel
        
        %sq.find('chan').after(t,vals) : apply updates with t times and vals

%Make mag field 0
sq.find('CD bit 1').set(0);
sq.find('CD fine/fast').set(Coil3DFine);
sq.find('MOT Bias Coil').set(MOTBias);

%Reduce Scatter Rate
sq.find('3DMOT amp').after(t,sq.minjerk(t,sq.find('3DMOT amp').values(end),TrappingAmp));
sq.find('3DMOT freq').after(t,sq.minjerk(t,sq.find('3DMOT freq').values(end),TrappingFreq));
sq.find('87 repump freq').set(RepumpFreq);
sq.find('87 repump amp').set(RepumpAmp);

sq.delay(tPGC);


end