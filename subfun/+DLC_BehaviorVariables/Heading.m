function [HE,U_HE,Config_HE] = Heading(bin_ms,DM)


%0-360deg
HE = []; %heading: direction of movement based on the body_center
global fps
global body_center
global Cali_ppc

%%
Config_HE.bin_ms = bin_ms; %heading from 200ms before.
Config_HE.bin_frame = Config_HE.bin_ms/(1000/fps);
Config_HE.bin_frame = 8;

dx =[];
dy =[];
dx(1:Config_HE.bin_frame,1) = NaN;
dy(1:Config_HE.bin_frame,1) = NaN;

dx(Config_HE.bin_frame:size(body_center,1),1) =  body_center(Config_HE.bin_frame:end,1) - body_center(1:end-Config_HE.bin_frame+1,1);
dy(Config_HE.bin_frame:size(body_center,1),1)  = body_center(Config_HE.bin_frame:end,2) - body_center(1:end-Config_HE.bin_frame+1,2);
abs_dx = abs(dx);
DM_Unit_pixel = DM*Cali_ppc;% unit change from cm to pixel. this is because body_center is pixel base coordinate.

alp = -1*dy./dx;
alp = rad2deg(atan2(alp,1));
%alp(fc)
degree = [];

for q = 1 : numel(alp)
    if  dx(q) >= 0 && dy(q) >= 0 %ok
        degree(q) = 360+ alp(q); 
        %radian = pi+deg2rad(alp);
        %HD(i,2) = cos(HD(i,1))*-1;
        %HD(i,3) = sin(HD(i,1));
    elseif dx(q) >= 0 && dy(q) < 0 %ok
        degree(q) = alp(q); 
        %radian = deg2rad(alp);
        %HD(i,2) = cos(HD(i,1));
        %HD(i,3) = sin(HD(i,1));
    elseif dx(q) < 0 && dy(q) <= 0 %ok
        degree(q) = alp(q)+180; 
        %radian = deg2rad(alp);
        %HD(i,2) = cos(HD(i,1));
        %HD(i,3) = sin(HD(i,1))*-1;
    elseif dx(q) <= 0 && dy(q) > 0 %OK
        degree(q) = 180+alp(q);
        %radian = pi+deg2rad(alp);
        %HD(i,2) = cos(HD(i,1))*-1;
        %HD(i,3) = sin(HD(i,1))*-1;
    
    elseif isnan(dx(q))&& isnan(dy(q)) 
        degree(q) = NaN;
        %radian = NaN; 
    end
end
HE(:,1) = degree;
U_HE = 'degree';
end
%%
%{
clc
%fc = 13220;
fc = 16080;
fb = fc-Config_HE.bin_frame+1;

cla
subplot(131)
imshow(read(v,fc))
subplot(132)
imshow(read(v,fb))

subplot(133)
plot(body_center(fc,1),body_center(fc,2),'*b')
hold on
plot(body_center(fb,1),body_center(fb,2),'*m')
xlim([0 914])
ylim([0 906])
axis square
ax = gca;
ax.YDir = 'reverse';
alp(fc)
degree(fc)
%}
%%