%{
<Discription>
*file name: FM_DLC2BV.m (DeepLabCut to Behavioral Variables mat data)
*This script inports csv file from deeplabcut, and outputs Behaviuoral
variables, such as velocity, head-direction, and immobility. This scripts
also outputs behavior parameters, such as dwell map, head-direction map and
speed tuning
*Need to addpath subfunctuon folders, such as DLC_BehaviorVariables and DLC_Parameters

<Save data>
*'DlcPostProcessed' includes behavior variables.

*update: 2022/Nov/14
%}
%% Only change here = Inputs
clc;clear all;close all; global Cali_ppc;global body_center;global fps

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% INPUTs for DLC informations %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath(genpath('G:\332\Supl_Miniscope weight\Script_BehaviorOnly (After DLC)\subfun'))%path of original  toolbox- DLC_Parameters
path_DLC = []; %path of DLC csv file. Need to delet 1st row.
path_Video = []; '%path of mp4 video file to get fps.
dir_matsave =  %direction of folder where data is saved.
dir_figsave = []; as you like 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%% INPUTs for DLC postprocessing %%%%%%%%%%
Cali_ppc = 1254/62; %pixel-per-cm
%v = VideoReader(path_Video); frame = read(v,1);
%imshow(frame);[xi,yi] = getpts; close; single(abs(xi(1)-xi(2)))
partsname.body = 'body_center'; %name of csv file header
partsname.ear_R = 'Right_Ear';
partsname.ear_L = 'Left_Ear';
partsname.miniscope = 'Miniscope';
partsname.tail_base = 'Tail_base';
cutoff_thr = 0.5; %Cutoff of likelihood. If the likelihood is below from this value, the corresponding XY coordinations are repreaceld to NaN.
cutoff_parts = {'body';'miniscope';'ear_L';'ear_R';'tail_base'}; %Body parts which cutoff function is applyed.
SmoothingFilter_name = 'movmedian'; %smoothing filter name. Default.. 'movmedian'
bin_width_ms= 100; %Width of the smoothing fileter as milisecond.
draw_fig_PP = true; %true or false. If you want to save summary output figure write 'true'. if 'draw_fig = true'. Fig name...DwellMap.tiff
make_new_video.TF = true; %make mp4 file, overlaying smoothed coordinations. true or false
make_new_video.dawnsampling = 1; %1:dawnsampling:all frame
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%% INPUTs for caluculation of behavioral variables %%%%%%%%%%
Time_window = 200; %Time to compare. Used in 'Heading', 'AngularHeadChange' and 'Immobility'. "Z(t) - Z(t-bin_ms)".
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%% INPUTs for dwell map %%%%%%%%%%%%%%%%%%%%
%body_center = BV.body_center; %[x,y] coordinate of body center
DwellBinSize_CM = 2.5;% Bin size. Unit...centimeter
speedcut_apply = false; %false or true.
SpeedCutOff_threshold = 2; %If speedcut_apply is true, the columns where its value below this threshold are replaced to NaN
gaussfilter_sigma = 1.5; %size of gaussian filter- sigma
gaussfilter_filter = [9 9]; %size of gaussian filter- window
config_StayTimeCutFff = 0; %If the value of dwell map is below this threshold, there are replaced to NaN. Unit...second
draw_fig_SpatialDwell = true; %make figure. true or false
%if 'draw_fig = true'. Fig name...DwellMap.tiff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% INPUTs for head-direction dwell map %%%%%%%%%%%%%%%%%
%HD = BV.HD; %vector of head-direction as degree (Not radian)
BinAngle_Deg = 3; %Bin angle. Unit...degree
draw_fig_HDDwell = true; %make figure. true or false
%if 'draw_fig = true'. Fig name...HD_DwellMap.tiff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% INPUTs for head-direction dwell map %%%%%%%%%%%%%%%%%
%HD = BV.HD; %vector of head-direction as degree (Not radian)
BinAngle_Deg = 3; %Bin angle. Unit...degree
draw_fig_HDDwell = true; %make figure. true or false
%if 'draw_fig = true'. Fig name...HD_DwellMap.tiff
draw_movie_HDDwell = false ; %make movie. true or false
draw_movie_HDDwell_downsampling = 10; %downsampling factor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%% INPUTs for Speed map %%%%%%%%%%%%%%%%%%%%%
%vel = BV.VEL; %%vector of velocity. Unit...cm/sec
BinSpeed_cm_per_sec = 1.5; %Bin of velocity. Unit...sec
dir_matsave = dir_matsave; %save path of matfile
draw_fig_SPDwell = true; %make figure. true or false
%if 'draw_fig = true'. Fig name...SpeedMap.tiff
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%main scripts
%Post-processing of DLC exports
[dlc,fps] = general.LoadDLC_csv(path_DLC,path_Video,partsname);

%%%% Post-processing of DLC exports %%%% 
%1) Removing low-confidence tracking
%2) Smoothing with a median filter (width of frames  corresponding 250ms) 
% based on "Shamash,...& Branco et.al., 2021 Nature Neuroscience
clear PostProcessing dlc_cutoff dlc_cutoff_smoothing
SmoothingFilter_bin = bin_width_ms/(1000/fps);
[PostProcessing,dlc_cutoff,dlc_cutoff_smoothing] = DLC_BehaviorVariables.DLCPostProcessing(dlc,cutoff_thr,cutoff_parts,SmoothingFilter_name,SmoothingFilter_bin,draw_fig_PP,dir_figsave,path_Video,make_new_video);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%%%% Calculate behavioral variables & Make table of behavioral variables %%%%
body_center(:,1:2) = [dlc_cutoff_smoothing.body_x, dlc_cutoff_smoothing.body_y]; %centroid. pixel base
[DLC,BV,BV_UnitName,Configs] = DLC_BehaviorVariables.GetBehavVars_Save(dlc,PostProcessing,dlc_cutoff_smoothing,Time_window,partsname,dir_matsave);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%% Calculation of behavior indexes %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% dwell map (occuopancy map) %%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear SpatialDwell; clc
Body_Center = BV.body_center;
DistanceMoved(:,1) = BV.time_sec;
DistanceMoved(:,2) = BV.DM;
VELOCITY = BV.VEL;
SpatialDwell = DLC_OccupancyMaps.DwellMap(DwellBinSize_CM,speedcut_apply,SpeedCutOff_threshold,...
    gaussfilter_sigma,gaussfilter_filter,config_StayTimeCutFff,draw_fig_SpatialDwell,dir_figsave,dir_matsave,DistanceMoved,'SquareBox',false,Body_Center,fps,VELOCITY);
      

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%　Head direction dwel map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%hist or histcounts. speedtuning は histcountを使用している

HD = BV.HD;
Dwell_HD = DLC_OccupancyMaps.HeadDirectionDwell(HD,BinAngle_Deg,draw_fig_HDDwell,dir_figsave,dir_matsave,false,fps);
DLC_OccupancyMaps.AngularHeadVelocityDwell(BV.AHV,dir_figsave,fps)
if draw_movie_HDDwell
    DLC_GenMovies.GenMP4_HeadDirectionCompas(HD,BV.VEL,BV.time_sec,dir_figsave,draw_movie_HDDwell_downsampling)
end
            
            
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%　Speed (tuning) map
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VELOCITY = BV.VEL;
SpeedMap = DLC_OccupancyMaps.SpeedMap(VELOCITY,BinSpeed_cm_per_sec,draw_fig_SPDwell,dir_figsave,dir_matsave,fps,false);
     
