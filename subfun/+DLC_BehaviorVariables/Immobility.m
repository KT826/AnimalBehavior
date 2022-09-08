function [IMM,U_IMM,Config_IMM] = Immobility(dlc_cutoff_smoothing,bin_ms,PostProcessing,Config_HE)

global fps
global Cali_ppc
%%
IMM = []; %Freezing... IMM = 0
Config_IMM.bin_ms = bin_ms; %200; %heading from 200ms before.
Config_IMM.bin_frame = Config_HE.bin_ms/(1000/fps);
IMM = [];
for p = 1 : numel(PostProcessing.cutoff_parts)
    eval(['x = dlc_cutoff_smoothing.',PostProcessing.cutoff_parts{p},'_x;']);
    eval(['y = dlc_cutoff_smoothing.',PostProcessing.cutoff_parts{p},'_y;']);
    X(:,p) = [repmat(NaN,Config_IMM.bin_frame-1,1); x(Config_IMM.bin_frame:end) - x(1:end-Config_IMM.bin_frame+1);];
    Y(:,p) = [repmat(NaN,Config_IMM.bin_frame-1,1); y(Config_IMM.bin_frame:end) - y(1:end-Config_IMM.bin_frame+1);];
end
for q = 1 : size(X,1)
    Z=[];
    for p = 1 : size(X,2)
        Z = [Z; X(q,p),Y(q,p)];
    end
    IMM(q,1) = norm(Z,'fro'); %= sqrt(norm([t0.A])^2 + norm([t0.B])^2 + norm([t0.C])^2 + norm([t0.D])^2 + norm([t0.E])^2)
end
IMM = IMM./Cali_ppc;
U_IMM = 'cm';

end
