function makeBraggSequence(dds,varargin)

%% Set up variables and parse inputs
f = 384.224e12;
k = 2*pi*f/const.c;
t0 = 10e-3;
width = 50e-6;
T = 1e-3;
Tasym = 0;
dt = 1e-6;
finalphase = 0;
power = 0.05*[1,2,1];
chirp = 2*k*9.795/(2*pi);

if mod(numel(varargin),2) ~= 0
    error('Arguments must appear as name/value pairs!');
else
    for nn = 1:2:numel(varargin)
        v = varargin{nn+1};
        switch lower(varargin{nn})
            case 't0'
                t0 = v;
            case 't'
                T = v;
            case 'dt'
                dt = v;
            case 'tasym'
                Tasym = v;
            case 'width'
                width = v;
            case {'finalphase','phase'}
                finalphase = v;
            case 'power'
                power = v;
            case 'chirp'
                chirp = v;
            case 'f'
                f = v;
            otherwise
                error('Option %s not supported',varargin{nn});
        end
    end
end

%% Calculate intermediate values
k = 2*pi*f/const.c;
recoil = const.hbar*k^2/(2*const.mRb*2*pi);
numPulses = numel(power);
fwhm = width/(2*sqrt(log(2)));

%% Create vectors
min_t = t0 - 5*width;
max_t = t0 + (numPulses-1)*T + Tasym + 5*width;
t = (min_t:dt:max_t)';

P = zeros(size(t));
for nn = 1:numPulses
    tc = t0 + (nn-1)*T + max((nn-2),0)*Tasym;
    P = P + power(nn)*exp(-(t - tc).^2/fwhm.^2);
end
P(:,2) = P(:,1);

ph = zeros(numel(t),2);
ph(:,2) = finalphase*(t > (t0 + 1.5*T));

freq(:,1) = dds(1).DEFAULT_FREQ - 0.25*chirp*t/(1e6) - 0.25*4*recoil/1e6;
freq(:,2) = dds(2).DEFAULT_FREQ + 0.25*chirp*t/(1e6) + 0.25*4*recoil/1e6;

%% Populate DDS values
for nn = 1:numel(dds)
    dds(nn).after(t,freq(:,nn),P(:,nn),ph(:,nn));
end


end