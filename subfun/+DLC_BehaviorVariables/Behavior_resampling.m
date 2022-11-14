function [BV_downsampling,DLC_downsampling] = Behavior_resampling(fps,GlobalSheet,BV,DLC,SamplingRate_of_CNMFe,dir_save)
%行動動画とnVokeイメージング動画のフレームレートを一致させるために、行動動画をダウンサンプリングする。
%nVokeは現状20fpsで記録し、10fps に temporal downsamplingを施している。このdownsamplingは


ds = fps/10; %downsampoling to 10Hz
IDX = 1:ds:size(GlobalSheet,1);
GlobalSheet_downsampling = GlobalSheet(IDX,:);
BV_downsampling = BV(IDX,:);
DLC_downsampling.raw = DLC.raw(IDX,:);
DLC_downsampling.processed = DLC.processed(IDX,:);


%%save
save([dir_save,'/Processed_DLC/DlcPostProcessed_DownSampling.mat'],'BV_downsampling','DLC_downsampling')
save([dir_save,'/Processed_GPIO/GpioSheet_DownSampling.mat'],'GlobalSheet_downsampling')


end