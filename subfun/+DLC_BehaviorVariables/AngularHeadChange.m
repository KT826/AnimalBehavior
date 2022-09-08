function [AHC,U_AHC, Config_AHC] = AngularHeadChange(HD,bin_ms,Config_HE)

global fps
%% Head turn-angle

AHC = [];%angular head change(Head turn-angle)

Config_AHC.bin_ms = bin_ms; %200; %head-angle change from 200ms before.
Config_AHC.bin_frame = Config_HE.bin_ms/(1000/fps);

AHC(1:numel(HD),1) = NaN;
dx1 = deg2rad(HD(1:end-Config_AHC.bin_frame+1));
dx2 = deg2rad(HD(Config_AHC.bin_frame:end));
AHC(Config_AHC.bin_frame:end,1) = rad2deg(angdiff(dx1,dx2)); %degree/ 200ms
U_AHC = 'degree-head angle change from Config_AHC.bin_frame(default 200ms)';

end