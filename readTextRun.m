function [t,a,d] = readTextRun(filename)

fid = fopen(filename);
t = [];
a = [];
d = [];
atmp = [];
dtmp = [];

while ~feof(fid)
    l = fgetl(fid);
    ch = strrep(l(1:3),' ','');
%     valstr = split(strip(l(4:end)));
    valstr = strsplit(strtrim(l(4:end)));
    switch ch(1)
        case 't'
            nn = size(t,1)+1;
            for mm = 1:numel(valstr)
                t(nn,1) = str2double(valstr{mm});
                nn = nn+1;
            end
            
        case 'a'
%             idx = str2double(ch(2:end));
            nn = size(atmp,1)+1;
            for mm = 1:numel(valstr)
                atmp(nn,1) = str2double(valstr{mm});
                nn = nn+1;
            end
            
        case 'd'
%             idx = str2double(ch(2:end));
            nn = size(dtmp,1)+1;
            for mm = 1:numel(valstr)
                dtmp(nn,1) = bin2dec(fliplr(valstr{mm}));
                nn = nn+1;
            end
            
        case '-'
            if ~isempty(atmp)
                a = [a;reshape(atmp,round(size(atmp,1)/24),24)];
                atmp = [];
            end
            if ~isempty(dtmp)
                d = [d;reshape(dtmp,round(size(dtmp,1)/4),4)];
                dtmp = [];
            end
            
    end
end

dtmp = d;
d = [];
for nn = 1:size(dtmp,1)
    f = @(x) bitget(dtmp(nn,x),1:8);
%     d(nn,:) = [f(4),f(3),f(2),f(1)];
    d(nn,:) = [f(1),f(2),f(3),f(4)];
end

% d = fliplr(d);


end

