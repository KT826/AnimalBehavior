function [DM,U_DM] = DistanceMoved(dlc_cutoff_smoothing)
global Cali_ppc
global body_center
DM = []; %distance moved (cm/frame)
DM(1,1) = NaN;
for i = 2 : size(dlc_cutoff_smoothing,1)
    DM(i,1) = norm(body_center(i,:)-body_center(i-1,:))/Cali_ppc; %norm (cm)
end
U_DM = 'cm moved from previous frame';

end