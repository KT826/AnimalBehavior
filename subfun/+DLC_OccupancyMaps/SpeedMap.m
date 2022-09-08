function SpeedMap = SpeedMap(vel,BinSpeed_cm_per_sec,draw_fig,figsavedir,path_save)

global fps
%%
%SpeedMap.config.BinSpeed_cm_per_sec = 1;% cm/s. ヒストグラムのビンサイズ
SpeedMap.config.BinSpeed_cm_per_sec = BinSpeed_cm_per_sec;% cm/s. ヒストグラムのビンサイズ

%histogram(speed)
SpeedMap.BinSpeed_Vector(:,1) = 0: SpeedMap.config.BinSpeed_cm_per_sec  : ceil(max(vel));
speed_dwell = hist(vel,SpeedMap.BinSpeed_Vector);
SpeedMap.dwellMap = speed_dwell'.* 1/fps;
SpeedMap.Unit_dwellMap = 'sec';

save(fullfile(path_save,'DLC_Processed','Dwell_Speed.mat'),'SpeedMap');

%% FIGURE
if draw_fig
    close all
    figure('Name','SpeedHistMap','Position',[0 0 800 400])
    tiledlayout(1,1,'TileSpacing','Compact','Padding','Compact');
    nexttile   
    ax = bar(SpeedMap.BinSpeed_Vector, SpeedMap.dwellMap,1,'EdgeColor','k');  
    xlim([-0.5 50])
    box off
    set(gca,'TickDir','out');
    xlabel('cm/sec')
    ylabel('sec')
    
    title(figsavedir,'FontSize', 6,'FontName','Arial')
    subtitle('Speed map','FontSize',10,'FontWeight','bold')
 
    
    SAVEDIR = [figsavedir,'/DLC_DwellMaps/'];
    mkdir(SAVEDIR)
    exportgraphics(gcf,[SAVEDIR,'/SpeedMap.tiff'],'Resolution',300)  
    close all
end


end