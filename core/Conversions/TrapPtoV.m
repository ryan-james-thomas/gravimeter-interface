function V = TrapPtoV(light_type,relative_power)

if strcmpi(light_type,'trap')
    if relative_power > 1
        relative_power = 1;
    elseif relative_power < 0
        relative_power = 0;
    end
%     V = asin(relative_power.^0.25).^2*1.8187 + 2.12;
    vv = [7,6,5,4,3,2,1,3.5,4.5];
    pp = [94,92,73.6,43.6,14,0.6,0,27.9,59.4];
    pp = pp/max(pp);
    V = interp1(pp,vv,relative_power,'pchip');
elseif strcmpi(light_type,'repump')
    if relative_power > 1
        relative_power = 1;
    elseif relative_power < 0
        relative_power = 0;
    end
    V = asin(relative_power.^0.25).^2*2.424 + 1.4774;
end

end
