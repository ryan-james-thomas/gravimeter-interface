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
    data = [8.0000    1.5000;
            7.0000    1.4570;
            6.0000    1.1930;
            5.0000    0.8100;
            4.0000    0.4200;
            3.0000    0.1190;
            2.0000    0.0046;
            3.5000    0.2450;
            4.5000    0.6090;
            5.5000    1.0000];
    [~,k] = sort(data(:,1));
    data = data(k,:);
    data(:,2) = data(:,2)/max(data(:,2));
    V = interp1(data(:,2),data(:,1),relative_power,'pchip');
    V(relative_power == 0) = 0;
end

end
