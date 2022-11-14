function [LM,U_LM] = LateralMobility(dlc_cutoff_smoothing,HD)
global body_center
global Cali_ppc
%%
%%% Lateral mobility %%%
%direction of moevment (rightward +1 or leftward -1）
%LM = Lateral_mobility(HE.degree,body_center,size(dlc,1),dlc); %v.NumFrame);


wk_HD = HD;
idx = find(wk_HD< 0);
wk_HD(idx) = wk_HD(idx) + 360;
wk_HD = wk_HD - 90;
Rightward = find(wk_HD>180);
Leftward = find(wk_HD<=180);
O(1:numel(wk_HD),1) = NaN;
O(Rightward,1) = 1;
O(Leftward,1) = -1;

M(1,1:2) = NaN;
M(2:numel(wk_HD),1:2) = body_center(2:end,:) - body_center(1:end-1,:);

try
    R = [dlc_cutoff_smoothing.nose_x, dlc_cutoff_smoothing.nose_y] - [dlc_cutoff_smoothing.tail_base_x, dlc_cutoff_smoothing.tail_base_y];
catch
    R = [dlc_cutoff_smoothing.body_x, dlc_cutoff_smoothing.body_y] - [dlc_cutoff_smoothing.tail_base_x, dlc_cutoff_smoothing.tail_base_y];
end

Proj(1,1:2) = NaN; 
Proj(2:numel(wk_HD),1:2) = [R(1:end-1,2),M(2:end,1)]; 
a = M - Proj;
LM = []; %Lateral mobility
LM(1,1) = NaN;
for i = 2 : numel(wk_HD)
    try
        LM(i,1) = norm(M(i,:) - Proj(i,:))*O(i);
    catch
        LM(i,1) = NaN;
    end
end
LM = LM./Cali_ppc;
U_LM = 'cm change of lateral movement from previous frame';


end