function [HD,U_HD] = HeadDirection(dlc_cutoff_smoothing)

%0-360deg
HD = []; %head direction {.degree, .radian}
x = dlc_cutoff_smoothing.ear_R_x-dlc_cutoff_smoothing.ear_L_x;
y = dlc_cutoff_smoothing.ear_R_y-dlc_cutoff_smoothing.ear_L_y;
tilt_ear = y./x;
tilt_ear_reciprocal(:,1) = (1./tilt_ear) *-1;
alp = rad2deg(atan2(tilt_ear_reciprocal,1));

for q = 1 : numel(alp)
    if  x(q) >= 0 && y(q) >= 0
        degree(q) = (alp(q)*-1); 
        %radian = pi+deg2rad(alp);
        %HD(i,2) = cos(HD(i,1))*-1;
        %HD(i,3) = sin(HD(i,1));
    elseif x(q) >= 0 && y(q) < 0
        degree(q) = 180-alp(q); 
        %radian = deg2rad(alp);
        %HD(i,2) = cos(HD(i,1));
        %HD(i,3) = sin(HD(i,1));
    elseif x(q) < 0 && y(q) <= 0
        degree(q) = abs(alp(q)-180); 
        %radian = deg2rad(alp);
        %HD(i,2) = cos(HD(i,1));
        %HD(i,3) = sin(HD(i,1))*-1;
    elseif x(q) <= 0 && y(q) > 0
        degree(q) = 360-alp(q);
        %radian = pi+deg2rad(alp);
        %HD(i,2) = cos(HD(i,1))*-1;
        %HD(i,3) = sin(HD(i,1))*-1;
    
    elseif isnan(x(q))&& isnan(y(q)) 
        degree(q) = NaN; 
        %radian = NaN; 
    end
end
HD(:,1) = degree;
U_HD = 'degree';
