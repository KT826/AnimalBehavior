function SpeedMap = SpeedMap(VELOCITY,BinSpeed_cm_per_sec,draw_fig,figsavedir,path_save,FPS,downsampling)


fps = FPS;
%% make histogram
%{
SpeedMap.config.BinSpeed_cm_per_sec = BinSpeed_cm_per_sec;% cm/s. ヒストグラムのビンサイズ
SpeedMap.BinSpeed_Vector(:,1) = 0: SpeedMap.config.BinSpeed_cm_per_sec  : ceil(max(VELOCITY));
speed_dwell = hist(VELOCITY,SpeedMap.BinSpeed_Vector);
SpeedMap.dwellMap = speed_dwell'.* 1/fps;
SpeedMap.Unit_dwellMap = 'sec';
%}
SpeedMap = CalSPDwell(BinSpeed_cm_per_sec,VELOCITY,fps);

%% half trial
%%%%% First half & Second half data %%%%%
ndata = size(VELOCITY,1);
if rem(ndata,2) == 0
    idx.FirstHalf = [1:1:(ndata/2)]';
    idx.SecondHalf = [(ndata/2)+1:numel(VELOCITY)]';
    
else
    idx.FirstHalf = [1:1:(1+ndata)/2]';
    idx.SecondHalf = [(1+ndata)/2+1:numel(VELOCITY)]';
end 

FirstHalf = CalSPDwell(BinSpeed_cm_per_sec,VELOCITY(idx.FirstHalf),fps);
SecondHalf = CalSPDwell(BinSpeed_cm_per_sec,VELOCITY(idx.SecondHalf),fps);

if ~downsampling
    save(fullfile(path_save,'Processed_DLC','Dwell_Speed.mat'),'SpeedMap','FirstHalf','SecondHalf');
else
    save(fullfile(path_save,'Processed_DLC','Dwell_Speed_DownSampling.mat'),'SpeedMap','FirstHalf','SecondHalf');
end



%% FIGURE
if ~downsampling

if draw_fig
    close all
    figure('Name','SpeedHistMap','Position',[0 0 800 600])
    tiledlayout(2,1,'TileSpacing','Compact','Padding','Compact');
    nexttile   
    ax = bar(SpeedMap.BinSpeed_Vector, SpeedMap.dwellMap,1,'EdgeColor','k');  
    xlim([-0.5 50])
    box off
    set(gca,'TickDir','out');
    xlabel('cm/sec')
    ylabel('sec')
    title(figsavedir,'FontSize', 6,'FontName','Arial')
    subtitle('Speed map','FontSize',10,'FontWeight','bold')
 
    nexttile   
    plot(SpeedMap.BinSpeed_Vector,SpeedMap.dwellMap,'bs-')
    hold on
    plot(FirstHalf.BinSpeed_Vector,FirstHalf.dwellMap,'m*-')
    hold on
    plot(SecondHalf.BinSpeed_Vector,SecondHalf.dwellMap,'r*-')
    legend('First+Second','First half','Second half')
    subtitle('Half Trials','FontSize',10,'FontWeight','bold')
    xlabel('cm/sec')
    ylabel('sec')
 

    SAVEDIR = [figsavedir,'/DLC_DwellMaps/'];
    mkdir(SAVEDIR)
    exportgraphics(gcf,[SAVEDIR,'/SpeedMap.tiff'],'Resolution',300)  
    close all
end
end
close all


%%
%% LOCAL finction
function SpeedDwellMap = CalSPDwell(BinSpeed_cm_per_sec,VELOCITY,fps)
    SpeedDwellMap.config.BinSpeed_cm_per_sec = BinSpeed_cm_per_sec;% cm/s. ヒストグラムのビンサイズ
    SpeedDwellMap.BinSpeed_Vector(:,1) = 0: SpeedDwellMap.config.BinSpeed_cm_per_sec  : ceil(max(VELOCITY));
    speed_dwell = hist(VELOCITY,SpeedDwellMap.BinSpeed_Vector);
    SpeedDwellMap.dwellMap = speed_dwell'.* 1/fps;
    SpeedDwellMap.Unit_dwellMap = 'sec';
end

end