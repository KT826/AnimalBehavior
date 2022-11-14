function [BH,U_BH] = BodyHeadAngle(dlc_cutoff_smoothing)
global body_center

%% Body/Head angle %%% -> check equision
BH = []; %Body/Head angle
head_center(:,1:2) = [dlc_cutoff_smoothing.miniscope_x, dlc_cutoff_smoothing.miniscope_y];    
x = body_center(:,1) - head_center(:,1);
y = body_center(:,2) - head_center(:,2);
tilt = y./x;
tilt_reciprocal(:,1) = (1./tilt) * -1;
alp = rad2deg(atan2(tilt_reciprocal,1));
k = 0;
for q = 1 : numel(alp)
    if  x(q) < 0 && y(q) >= 0
        alp(q) = alp(q) * -1;
    elseif x(q) < 0 && y(q) < 0
        alp(q) = alp(q) * -1;
    elseif x(q) >= 0 && y(q) < 0
        alp(q) = -1*(180+alp(q));
    elseif x(q) >= 0 && y(q) >= 0
        alp(q) = 180- alp(q);
    end
end
BH = alp;
U_BH = 'degree';
end
