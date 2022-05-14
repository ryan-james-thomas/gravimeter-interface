function V = TrapPtoV(light_type,relative_power)

if strcmpi(light_type,'trap')
    if relative_power > 1
        relative_power = 1;
    elseif relative_power < 0
        relative_power = 0;
    end
    V = asin(relative_power.^0.25).^2*1.8187 + 2.12;
elseif strcmpi(light_type,'repump')
    if relative_power > 1
        relative_power = 1;
    elseif relative_power < 0
        relative_power = 0;
    end
    V = asin(relative_power.^0.25).^2*2.424 + 1.4774;
end

end
