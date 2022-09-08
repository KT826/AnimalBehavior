function HD_Dwell = HeadDirectionDwell(HD,BinAngle_Deg,draw_fig,figsavedir,path_save)

global fps
%%
HD_Dwell.config.BinAngle_Deg =  BinAngle_Deg; %degree
HD_Dwell.BinAngle_Vector(:,1) = linspace(0,2*pi,360/HD_Dwell.config.BinAngle_Deg); %linspace(pi*-1,pi,360/Dwell_HD.config.BinAngle_Deg);
wk_hd = sort(deg2rad(HD),'ascend');
wk_dwellmap = hist(wk_hd,HD_Dwell.BinAngle_Vector)';
HD_Dwell.dwellMap = wk_dwellmap * 1/fps; % occupancy map, unit: sec
HD_Dwell.Unit_dwellMap = 'sec';

save(fullfile(path_save,'DLC_Processed','Dwell_HD.mat'),'HD_Dwell');
%% Figure
Dwell.config.Figure = draw_fig;
if Dwell.config.Figure
    close all
    figure('Name','HD Dwell map','Position',[0 0 400 400])
    tiledlayout(1,1,'TileSpacing','Compact','Padding','Compact');
    
    nexttile
    polarplot([HD_Dwell.BinAngle_Vector;HD_Dwell.BinAngle_Vector(1)], [HD_Dwell.dwellMap;HD_Dwell.dwellMap(1)],'-b','LineWidth',1)
    title(figsavedir,'FontSize', 6,'FontName','Arial')
    ax = gca;
    ax.ThetaTick = [0:45:360];
    subtitle('Time spent (HeadDirection, sec)','FontSize',10,'FontWeight','bold')
        
    SAVEDIR = [figsavedir,'/DLC_DwellMaps/'];
    mkdir(SAVEDIR)
    exportgraphics(gcf,[SAVEDIR,'/HeadDirectionDwellMap.tiff'],'Resolution',300)  
end

%%






end
