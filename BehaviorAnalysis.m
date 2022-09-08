%{
<Discription>
This script needs csv file exported from deeplabcut and any other similar software.
Outputs... Behaviuoral variables (e.g. velocity, head-direction, etc.).
           Behavior parameters (e.g. dwell map, head-direction map and speed tuning)

*update: 2022/Mar/25
%}


%% INPUT (change to appropriates. )
clc;clear all;close all;
global Cali_ppc;global body_center;global fps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTs for DLC informations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath([pwd, '\subfun']))%path of original toolbox- DLC_Parameters
path_DLC = [pwd, '\DLC/csv.csv']; %path of DLC csv file. Need to delet 1-st row.
path_Video = [pwd,'\DLC/video.mp4']; %path of mp4 video file to get fps.
dir_matsave = pwd;
dir_figsave = dir_matsave; mkdir(dir_matsave)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% INPUTs for DLC postprocessing %%%%%%%%%%
Cali_ppc = 1160/65; %pixel-per-cm  % v = VideoReader(path_Video); imshow(read(v,1))
partsname.body = 'body_center'; %name of csv file header
partsname.ear_R = 'Right_Ear';
partsname.ear_L = 'Left_Ear';
partsname.miniscope = 'Miniscope';
partsname.tail_base = 'Tail_base';
cutoff_thr = 0.35; %Cutoff of likelihood. If the likelihood is below from this value, the corresponding XY coordinations are repreaceld to NaN.
cutoff_parts = {'body';'miniscope';'ear_L';'ear_R';'tail_base'}; %Body parts which cutoff function is applyed.
SmoothingFilter_name = 'movmedian'; %smoothing filter name. Default.. 'movmedian'
bin_width_ms= 100; %Width of the smoothing fileter as milisecond.
draw_fig_PP = true; %true or false. If you want to save summary output figure write 'true'. if 'draw_fig = true'. Fig name...DwellMap.tiff
make_new_video.TF = false; %make mp4 file, overlaying smoothed coordinations. true or false
make_new_video.dawnsampling = []; %1:dawnsampling:all frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%% INPUTs for caluculation of behavioral variables %%%%%%%%%%
bin_ms = 50; %Time to compare. Used in 'Heading', 'AngularHeadChange' and 'Immobility'. "Z(t) - Z(t-bin_ms)".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% INPUTs for dwell map %%%%%%%%%%%%%%%%%%%%
%body_center = BV.body_center; %[x,y] coordinate of body center
DwellBinSize_CM = 2.0;% Bin size. Unit...centimeter
speedcut_apply = false; %false or true.
SpeedCutOff_threshold = 0; %If speedcut_apply is true, the columns where its value below this threshold are replaced to NaN
gaussfilter_sigma = 1.5; %size of gaussian filter- sigma
gaussfilter_filter = [9 9]; %size of gaussian filter- window
config_StayTimeCutFff = 0; %If the value of dwell map is below this threshold, there are replaced to NaN. Unit...second
dir_matsave = dir_matsave; %save path of matfile
draw_fig_SpatialDwell = true; %make figure. true or false
%if 'draw_fig = true'. Fig name...DwellMap.tiff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% INPUTs for head-direction dwell map %%%%%%%%%%%%%%%%%
%HD = BV.HD; %vector of head-direction as degree (Not radian)
BinAngle_Deg = 3; %Bin angle. Unit...degree
dir_matsave = dir_matsave; %save path of matfile
draw_fig_HDDwell = true; %make figure. true or false
%if 'draw_fig = true'. Fig name...HD_DwellMap.tiff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%% INPUTs for Speed map %%%%%%%%%%%%%%%%%%%%%
%vel = BV.VEL; %%vector of velocity. Unit...cm/sec
BinSpeed_cm_per_sec = 1.5; %Bin of velocity. Unit...sec
dir_matsave = dir_matsave; %save path of matfile
draw_fig_SPDwell = true; %make figure. true or false
%if 'draw_fig = true'. Fig name...SpeedMap.tiff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Post-processing of DLC exports
[dlc,fps] = general.LoadDLC_csv(path_DLC,path_Video,partsname);

%  Post-processing of DLC exports
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%1) Removing low-confidence tracking
%2) Smoothing with a median filter (width of frames  corresponding 250ms) 
% based on "Shamash,...& Branco et.al., 2021 Nature Neuroscience
clear PostProcessing dlc_cutoff dlc_cutoff_smoothing
SmoothingFilter_bin = bin_width_ms/(1000/fps);
[PostProcessing,dlc_cutoff,dlc_cutoff_smoothing] = DLC_BehaviorVariables.DLCPostProcessing(dlc,cutoff_thr,cutoff_parts,SmoothingFilter_name,SmoothingFilter_bin,draw_fig_PP,dir_figsave,path_Video,make_new_video);

% Calculate behaviorla variables & Make table of behavioral variables / save
body_center(:,1:2) = [dlc_cutoff_smoothing.body_x, dlc_cutoff_smoothing.body_y]; %centroid. pixel base
[DLC,BV,BV_UnitName,Configs] = DLC_BehaviorVariables.GetBehavVars_Save(dlc,PostProcessing,dlc_cutoff_smoothing,bin_ms,partsname,dir_matsave);


%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Calculation of behavior indexes %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% dwell map (occuopancy map) %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear SpatialDwell
body_center = BV.body_center; %[x,y] coordinate of body center
DistanceMoved(:,1) = BV.time_sec;
DistanceMoved(:,2) = BV.DM;
SpatialDwell = DLC_OccupancyMaps.DwellMap(DwellBinSize_CM,speedcut_apply,SpeedCutOff_threshold,...
    gaussfilter_sigma,gaussfilter_filter,config_StayTimeCutFff,draw_fig_SpatialDwell,dir_figsave,dir_matsave,DistanceMoved);

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%　Head direction dwel map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hist or histcounts. speedtuning は histcountを使用している
clear Dwell_HD
HD = BV.HD;
Dwell_HD = DLC_OccupancyMaps.HeadDirectionDwell(HD,BinAngle_Deg,draw_fig_HDDwell,dir_figsave,dir_matsave);close all
DLC_GenMovies.GenMP4_HeadDirectionCompas(HD,BV.VEL,BV.time_sec,dir_figsave,10)

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%　Speed (tuning) map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vel = BV.VEL;
SpeedMap = DLC_OccupancyMaps.SpeedMap(vel,BinSpeed_cm_per_sec,draw_fig_SPDwell,dir_figsave,dir_matsave);
