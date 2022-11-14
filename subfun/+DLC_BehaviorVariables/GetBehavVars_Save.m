function [DLC,BV,BV_UnitName,Configs] = GetBehavVars_Save(dlc,PostProcessing,dlc_cutoff_smoothing,bin_ms,partsname,dir_matsave)

global body_center
global fps
global Cali_ppc
%%
%%%%%% List of behaviorla variables %%%%%%
ListBehavVars.DM = 'distance moved';
ListBehavVars.VEL = 'velocity';
ListBehavVars.ACC = 'acceleration';
ListBehavVars.HE = 'heading: direction of movement based on the body_center (centroid)';
ListBehavVars.HD = 'head direction {.degree, .radian}';
ListBehavVars.AHC = 'angular head change(Head turn-angle)';
ListBehavVars.AHV = 'anglar head velocity';
ListBehavVars.AHTD = 'anglar head turn direction';
ListBehavVars.BH = 'Body/Head angle';
ListBehavVars.IMM = 'Immobility. How much the mouse moved from X frames before. (Freezing... IMM = 0)';
ListBehavVars.LM = 'LateralMobility';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
ts(:,1) = (1/fps) : (1/fps) : (1/fps) *length(body_center);
[DM,UnitName.DM] = DLC_BehaviorVariables.DistanceMoved(dlc_cutoff_smoothing); %cm from previous frame
[VEL,UnitName.VEL] = DLC_BehaviorVariables.Velocity(DM); %'cm/sec'
[ACC,UnitName.ACC] = DLC_BehaviorVariables.Acceleration(VEL); %'cm/sec^2'
%bin_ms = 200; 
[HE,UnitName.HE,Config_HE] = DLC_BehaviorVariables.Heading(bin_ms,DM); %heading direction(degree) from 200ms before.
[HD,UnitName.HD] = DLC_BehaviorVariables.HeadDirection(dlc_cutoff_smoothing); %direction(degree)

[AHC,U_AHC,Config_AHC,AHV,U_AHV] = DLC_BehaviorVariables.AngularHeadVelocity(HD,bin_ms); %Angular head velocity

[AHTD,UnitName.AHTD] = DLC_BehaviorVariables.HeadTurnDirection(AHC);% CW or CCW
[BH,UnitName.BH] = DLC_BehaviorVariables.BodyHeadAngle(dlc_cutoff_smoothing); %degree at a frame -> check equision and meaning 
[IMM,UnitName.IMM,Config_IMM] = DLC_BehaviorVariables.Immobility(dlc_cutoff_smoothing,bin_ms,PostProcessing,Config_HE); %cm
[LM,UnitName.LM] = DLC_BehaviorVariables.LateralMobility(dlc_cutoff_smoothing,HD); %'cm change of lateral movement from previous frame'
%{
%%% Head and body rotation angle %%%
[BH] = body_head_rotation(body_center,v.FrameRate, BH);
%}


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
DIRSAVE = [dir_matsave,'/Processed_DLC'];
mkdir(DIRSAVE)
save(fullfile(DIRSAVE,'DlcPostProcessed.mat'),'DLC','BV','BV_UnitName','Configs')

end