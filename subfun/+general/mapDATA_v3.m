function [mapout,mapset] = mapDATA_v3(x,y,ls,p,bs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   This function bins any type of x,y data into a 3D (x,y,count) map or histogram
%   This version has been reworked so that x,y data can be easily corrected to match
%   bins in the map. It has also been changed to accept only data in cm, not pixels
%   [mapout,mapset] = mapDATA_v2(x,y,ls,p,bs)
%
%%%%%%%% Inputs
%   x = x coordinates of data
%   y = y coordinates of data
%   ls = map limits (if required) in the format [xmin xmax ymin ymax]
%   p = (default = 2) padding for data in bins
%   bs = (default = 2) the binsize in cm 
%
%%%%%%%% Outputs
%   mapout = the 2d map of the data, unsmoothed. This is created so that the centre of the x,y data falls on in the centre point of the map
%   mapset = a structure containing the bin edges of the map and corrected position data:
%         mapset.bin_pix = the binsize in pixels
%         mapset.xloc = x bin edges
%         mapset.yloc = y bin edges
%         mapset.xnew = x data corrected to match map
%         mapset.ynew = y data corrected to match map
%
%   to convert other position or spike data to match the map do this:
%         newx = (oldx /(bs / 100 * pr)) + (size(mapout,2) / 2)
%         newy = (oldy /(bs / 100 * pr)) + (size(mapout,1) / 2)
%
%%%%%%%% Comments
%   08/08/16 created as a simple mapping function
%   20/04/17 created from mapDATA because I want a function I can use with overdispersion
%   20/04/17 function now outputs converted position data (to match map)
%   20/04/17 added limit capability so spike and time maps can be made with same limits
%   27/07/17 changed to v3, this version expects data to be in cm, not pixels (meant to work with variable pixel ratio klustest)
%
%   � Roddy Grieves: rmgrieves@gmail.com (not sure who wrote the original postprocess_pos_data though)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initial variables
% if no padding is given
if ~exist('p','var') || isempty(p)
    p = 2;
end 
p=0;

% if no binsize is given
if ~exist('bs','var') || isempty(bs)
    bs = 2;
end

x = double(x(:));
y = double(y(:));

% prepare limits of map
if ~exist('ls','var') || isempty(ls) || all(isnan(ls(:)))
    % determine limits from data
    lx = [nanmin(x) nanmax(x)];
    ly = [nanmin(y) nanmax(y)];
else
    % cut data to limits
    indx = x >= ls(1,1) & x <= ls(1,2) & y >= ls(2,1) & y <= ls(2,2);
    x = x(indx);
    y = y(indx);
    
    % get limits from ls
    lx = ls(1,:);
    ly = ls(2,:);
end
mapset.limits = [lx; ly];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Generate map
bin_size = bs;
mapset.bin_size = bin_size;

% centre data on the origin
x = x - mean(lx); 
y = y - mean(ly);    
lx = lx - mean(lx); 
ly = ly - mean(ly);  

xvec = 0 : bin_size : (max(abs(lx))+bin_size+bin_size*p); 
yvec = 0 : bin_size : (max(abs(ly))+bin_size+bin_size*p);    

% sort them to increase from -max to max
xvec = sort([-xvec xvec],'ascend'); 
yvec = sort([-yvec yvec],'ascend');
mapset.xloc = xvec;
mapset.yloc = yvec;

% 3D histogram
mapout = hist3([y,x],{yvec,xvec}); 
mapset.xnew = (x./bin_size)+(size(mapout,2)./2);
mapset.ynew = (y./bin_size)+(size(mapout,1)./2);

















