function [AHTD,U_AHTD] = HeadTurnDirection(AHV)

%%% Head turn-angle, anglar head velocity, head turn direction  %%%
% CW <0<= CCW
AHTD = [];
for q = 1 : numel(AHV)
    if AHV(q) < 0
        AHTD(q,1) = -1;
    elseif AHV(q) >= 0
        AHTD(q,1) = 1;
    else 
        AHTD(q,1) = NaN; 
    end
end
U_AHTD = 'CW(<0) or CCW(>0)';

end