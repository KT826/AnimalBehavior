function [DLC,BV,BV_UnitName,Configs] = SaveDLC_PostProcessed(dlc,dlc_cutoff_smoothing,body_center,Cali_ppc,partsname,fps)
%%
% Make table of behavioral variables / save
DLC.raw = dlc;
DLC.processed = dlc_cutoff_smoothing;

frame(:,1) = 1:1:size(body_center,1);
time_sec(:,1) = (1/fps) : (1/fps) : (1/fps) *length(body_center);
BV = table(frame,time_sec,body_center,DM,VEL,ACC,HE,HD,AHC,AHV,AHTD,BH,IMM,LM); %Behavioral Variables
BV_UnitName = UnitName;

Configs.PostProcessing = PostProcessing;
Configs.HE = Config_HE;
Configs.AHC = Config_AHC;
Configs.IMM = Config_IMM;
Configs.fps = fps;
Configs.Calibration_PixelPerCentimeter = Cali_ppc;
Configs.GetBodyParts = partsname;
DIRSAVE = [dir_matsave,'/DLC_Processed'];
mkdir(DIRSAVE)
save(fullfile(DIRSAVE,'DlcPostProcessed.mat'),'DLC','BV','BV_UnitName','Configs')


end