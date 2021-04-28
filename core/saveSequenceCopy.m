function saveSequenceCopy(filepath,directory,args)

[fpath,fname,fext] = fileparts(filepath);
dstr = datestr(datetime,'YY_mm_dd_hh_MM_ss');
s = fileread(filepath);

%Find first line break
r = regexp(s,'\r\n');
%Break file into to parts, one before line break and one after
s1 = s(1:(r(1)+1));
s2 = s((r(1)+2):end);
%Create new string to insert
sinsert = ['    %% These were the input arguments',sprintf('\r\n')];
for nn = 1:numel(args)
    sinsert = [sinsert,sprintf('    varargin{%d} = %.3g;\r\n',nn,args{nn})]; %#ok<*AGROW>
end
%Insert string into file
snew = [s1,sinsert,s2];

%Get year, month, and day as characters
year = char(datetime('now','format','y'));
month = char(datetime('now','format','MM'));
day = char(datetime('now','format','dd'));
%
% Create year, month, and day directories as needed
%
saveDir = sprintf('%s/%s',fpath,directory);
yearDir = sprintf('%s/%s',saveDir,year);
if ~isfolder(yearDir)
    mkdir(yearDir);
end
monthDir = sprintf('%s/%s',yearDir,month);
if ~isfolder(monthDir)
    mkdir(monthDir);
end
dayDir = sprintf('%s/%s',monthDir,day);
if ~isfolder(dayDir)
    mkdir(dayDir);
end
%
% Write file to appropriate directory
%
newName = sprintf('%s_%s',fname,dstr);
srep = strrep(snew,fname,newName);
fid = fopen(sprintf('%s/%s%s',dayDir,newName,fext),'w');
fprintf(fid,'%s',srep);
fclose(fid);
