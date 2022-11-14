function [VEL,U_VEL] = Velocity(DM)
global fps
%%
VEL = []; %velocity (cm/sec)
VEL = DM./(1/fps); %cm/frame
U_VEL = 'cm/sec';

end