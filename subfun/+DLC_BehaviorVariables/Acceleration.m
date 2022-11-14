function [ACC,U_ACC] = Acceleration(VEL)

global fps
%%
%%%input%%%
%VEL: cm/sec
%%%%%%%%%%%

ACC = []; %acceleration (cm/sec^2) 
ACC(1:2,1) = NaN;
ACC(3:numel(VEL),1)= (VEL(3:end)-VEL(2:end-1))./(1/fps);
U_ACC = 'cm/sec^2';

end