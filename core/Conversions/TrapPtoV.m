function V = TrapPtoV(light_type,relative_power)

if relative_power > 1
    relative_power = 1;
elseif relative_power < 0
    relative_power = 0;
end

if strcmpi(light_type,'trap')
%     V = asin(relative_power.^0.25).^2*1.8187 + 2.12;
    vv = [7,6,5,4,3,2,1,3.5,4.5];
    pp = [94,92,73.6,43.6,14,0.6,0,27.9,59.4];
    pp = pp/max(pp);
    V = interp1(pp,vv,relative_power,'pchip');
elseif strcmpi(light_type,'repump')
    V = asin(relative_power.^0.25).^2*2.424 + 1.4774;
elseif strcmpi(light_type,'nd')
    vv = 1:8;
    pp = [0,7.4e-6,185e-6,655e-6,1.28e-3,1.94e-3,2.4e-3,2.6e-3];
    pp = pp/max(pp);
    V = interp1(pp,vv,relative_power,'pchip');
end

end
