function HD_Dwell = HeadDirectionDwell(HD,BinAngle_Deg,draw_fig,figsavedir,path_save,downsampling,FPS)

fps = FPS;
%% whole trial
%{
clear HD_Dwell
HD_Dwell.config.BinAngle_Deg =  BinAngle_Deg; %degree
HD_Dwell.BinAngle_Vector(:,1) = linspace(0,2*pi,360/HD_Dwell.config.BinAngle_Deg); %linspace(pi*-1,pi,360/Dwell_HD.config.BinAngle_Deg);
wk_hd = sort(deg2rad(HD),'ascend');
wk_dwellmap = hist(wk_hd,HD_Dwell.BinAngle_Vector)';
HD_Dwell.dwellMap = wk_dwellmap * 1/fps; % occupancy map, unit: sec

HD_Dwell.dwellMap(1) = HD_Dwell.dwellMap(1)+HD_Dwell.dwellMap(end);
HD_Dwell.dwellMap(end) = [];
HD_Dwell.BinAngle_Vector(end) = [];
HD_Dwell.Unit_dwellMap = 'sec';
%}

HD_Dwell = CalHDDwell(BinAngle_Deg,HD,fps);

%% half trial
%%%%% First half & Second half data %%%%%

ndata = size(HD,1);
if rem(ndata,2) == 0
    idx.FirstHalf = [1:1:(ndata/2)]';
    idx.SecondHalf = [(ndata/2)+1:numel(HD)]';
    
else
    idx.FirstHalf = [1:1:(1+ndata)/2]';
    idx.SecondHalf = [(1+ndata)/2+1:numel(HD)]';
end 

FirstHalf = CalHDDwell(BinAngle_Deg,HD(idx.FirstHalf),fps);
SecondHalf = CalHDDwell(BinAngle_Deg,HD(idx.SecondHalf),fps);


%%
if ~downsampling
    save(fullfile(path_save,'Processed_DLC','Dwell_HD.mat'),'HD_Dwell','FirstHalf','SecondHalf');
else
    save(fullfile(path_save,'Processed_DLC','Dwell_HD_DownSampling.mat'),'HD_Dwell','HD_Dwell','FirstHalf','SecondHalf');
end

%% Figure
if ~downsampling
    Dwell.config.Figure = draw_fig;
    if Dwell.config.Figure
        close all
        figure('Name','HD Dwell map','Position',[0 0 800 400])
        tiledlayout(1,2,'TileSpacing','Compact','Padding','Compact');
        ANGLEBIN = HD_Dwell.BinAngle_Vector;

        DWELLMAP = HD_Dwell.dwellMap;%whole
        DWELLMAP_1 = FirstHalf.dwellMap; %firsthalf
        DWELLMAP_2 = SecondHalf.dwellMap; %second half

        nexttile(1)
        polarplot([ANGLEBIN;ANGLEBIN(1)], [DWELLMAP;DWELLMAP(1)],'-b','LineWidth',1)
        title(figsavedir,'FontSize', 6,'FontName','Arial')
        ax = gca;
        ax.ThetaTick = [0:45:360];
        subtitle('Time spent (HeadDirection, sec)','FontSize',10,'FontWeight','bold')

        nexttile(2)
        polarplot([ANGLEBIN;ANGLEBIN(1)], [DWELLMAP_1;DWELLMAP_1(1)],'-m','LineWidth',1)
        hold on
        polarplot([ANGLEBIN;ANGLEBIN(1)], [DWELLMAP_2;DWELLMAP_2(1)],'-r','LineWidth',1)
        title('1st&2nd Half','FontSize', 6,'FontName','Arial')
        ax = gca;
        ax.ThetaTick = [0:45:360];
        subtitle('Time spent (HeadDirection, sec)','FontSize',10,'FontWeight','bold')


        SAVEDIR = [figsavedir,'/DLC_DwellMaps/'];
        mkdir(SAVEDIR)
        exportgraphics(gcf,[SAVEDIR,'/HeadDirectionDwellMap.tiff'],'Resolution',300)  
    end
end

close all

%% LOCAL finction

function HeadDirectionDwellMap = CalHDDwell(BinAngle_Deg,Vector_HD,fps)

    HeadDirectionDwellMap.config.BinAngle_Deg =  BinAngle_Deg; %degree
    numBins = ceil(360 / HeadDirectionDwellMap.config.BinAngle_Deg);
    HeadDirectionDwellMap.BinAngle_Vector(:,1) = deg2rad((0:numBins-1) * 360/numBins + 180./numBins);

    wk_hd = sort(deg2rad(Vector_HD),'ascend');
    wk_dwellmap = hist(wk_hd,HeadDirectionDwellMap.BinAngle_Vector)';
    HeadDirectionDwellMap.dwellMap = wk_dwellmap * 1/fps; % occupancy map, unit: sec
    %HeadDirectionDwellMap.BinAngle_Vector(end) = [];
    HeadDirectionDwellMap.Unit_dwellMap = 'sec';

end

end
