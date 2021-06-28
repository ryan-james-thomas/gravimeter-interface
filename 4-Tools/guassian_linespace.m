function [s,d,f] = guassian_linespace(number_of_points,start_freq,stop_freq,varargin)

%It would be nice to generate a aray of numbers with a distributiun around
%particualr points. It will need start and end points, total number of
%points and guasians with poitions, widths and probabilities

%to achive this I belive I can plot this out, then use a normcdf to
%generate the array


%example

%guassian_linespace(50,-2.7e6,1e6,[0e6, 1e6, 1],[-1e6, 0.3e6, 2]);



%check inputs
input_num = nargin-3;
%check this is greater than 0
if (input_num<1)
    error('Incorrect number of arguments');
end
%check that all varargins are three length arrays
for i=1:length(varargin)
    validateattributes(varargin{i},{'numeric'},{'row','numel', 3});
end


%number_of_points = 50;
%start_freq = -1e6;
%stop_freq = 4e6;
lin_array = linspace(start_freq,stop_freq,number_of_points);
f = lin_array;

%each guassian has a position, width and weight
guass_array = zeros(1,number_of_points);
for i=1:length(varargin)
    array = varargin{i};
    guass_array =  guass_array+gaussmf(lin_array,[array(2),array(1)])*array(3);
end
d = guass_array;

%normalised cumulative sum
cumulative = cumsum(guass_array)/sum(guass_array);

%remove identicals
[C,indexes,~] = unique(cumulative);

%build array from this that makes a interpolated frequency every
%fracion of the cumsum
%datapoints from 0 to 1
xq = linspace(0,1,number_of_points);
%interpolate frequency positions
s = interp1(C,lin_array(indexes),xq);


% figure(1);
% plot(lin_array,guass_array)
% figure(2);
% plot(cumulative,lin_array)
% figure(3);
% plot(s);
end

