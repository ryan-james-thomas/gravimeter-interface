function makeVelocitySelectionpulse(dds,varargin)

%% Set up variables and parse inputs
f = 384.224e12;
Pulse_Detuning=5e9;
t0 = 0e-3;
tvs=0e-3;
k = 2*pi*f/const.c;
width = 300e-6;
power = 0.03;
chirp = 2*k*9.795/(2*pi);
start_order = 0;
delta_order = 1;
mirrorSwitch = 1;

if mod(numel(varargin),2) ~= 0
    error('Arguments must appear as name/value pairs!');
else
    for nn = 1:2:numel(varargin)
        v = varargin{nn+1};
        switch lower(varargin{nn})
            case 'tvs'
                tvs = v;
            case 'dt'
                dt = v;
            case 'width'
                 width = v;
                 if width<0
                     error('width requires a positive value');
                 elseif width>10e-3
                     error('width requires a smaller value')
                 else
                     width = v;
                 end
            case 'power'
                power = v;
                if power<0
                    error('power needs a value between 0 and 1.');
                elseif power>1
                    error('power needs a value between 0 and 1.');
                else
                    power=v;
                end
            case 'chirp'
                chirp = v;
            case 'f'
                f = v;
                k = 2*pi*f/const.c;
            case 'k'
                k = v;
            case {'order','delta_order'}
                if v == 0
                    error('Bragg order should be non-zero!');
                elseif round(v) ~= v
                    error('Bragg order must be an integer!');
                else
                    order = v;
                end
            case 'start_order'
                 if round(v) ~= v
                     error('Bragg start order must be an integer!');
                else
                    start_order = v;
                end
            otherwise
                error('Option %s not supported',varargin{nn});
        end
    end
end

%% Conditions on the time step
if width<50e-6
    dt=1e-6;
else
    intermediatewidth=width*10^6;
    dt = ceil(intermediatewidth/50)*10^-6;
end


%% Calculate intermediate values
recoil = order*const.hbar*k^2/(2*const.mRb*2*pi);
% detuning=recoil/2.8;
detuning=0;
fwhm = width/(2*sqrt(log(2)));

tc=tvs;

%% Create vectors
min_t = tc - 5*width;
max_t = tc + 5*width;
t = (min_t:dt:max_t)';

P = power*exp(-(t - tc).^2/fwhm.^2);
P(:,2) = P(:,1);

freq(:,1) = dds(1).DEFAULT_FREQ + mirrorSwitch*0.25/1e6*(chirp*tc + (2*start_order+delta_order)*4*recoil);
freq(:,2) = dds(2).DEFAULT_FREQ - mirrorSwitch*0.25/1e6*(chirp*tc + (2*start_order+delta_order)*4*recoil);
ph = zeros(numel(t),2);

%% Populate DDS values
for nn = 1:numel(dds)
    dds(nn).after(t,freq(:,nn),P(:,nn),ph(:,nn));
end


end