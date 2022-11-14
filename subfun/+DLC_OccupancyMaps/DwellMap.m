function SpatialDwell = DwellMap(DwellBinSize_CM,speedcut_apply,SpeedCutOff_threshold,...
    gaussfilter_sigma,gaussfilter_filter,config_StayTimeCutFff,draw_fig,dir_figsave_behavior,dir_matsave,DistanceMoved,TrialEnviroment,downsampling,Body_Center,FPS,VELOCITY)

%%
global Cali_ppc
fps = FPS;
%input
%downsampling = true of false

%%
%Dwell.config.DwellBinSize_CM = 1; %cm
SpatialDwell.config.BinSize_CM = DwellBinSize_CM;
SpatialDwell.config.BinSize_Pixel = round(Cali_ppc  * SpatialDwell.config.BinSize_CM); %pixels/ desire-CM
wk_x = Body_Center(:,1); 
wk_y = Body_Center(:,2); 

%%%% INSERT speedcutoff function %%%%
SpatialDwell.config.SpeedCutOff = speedcut_apply; %true or false
if SpatialDwell.config.SpeedCutOff
    SpatialDwell.config.SpeedCutOff_threshold = SpeedCutOff_threshold; %cm/sec
    wk_VEL = VELOCITY; %cm/sec
    wk_IDX = find(wk_VEL < SpatialDwell.config.SpeedCutOff_threshold );
    wk_x(wk_IDX) = NaN;
    wk_y(wk_IDX) = NaN;
    wk_VEL(wk_IDX) = NaN;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%% whole data %%%%%
[SpatialDwell.SpatialDwellMap, SpatialDwell.mapset_base] = general.mapDATA_v3(wk_x,wk_y,[],2,SpatialDwell.config.BinSize_Pixel);
SpatialDwell.SpatialDwellMap = SpatialDwell.SpatialDwellMap * 1/fps;
SpatialDwell.Unit_SpatialDwellMap = 'sec';
%Smoothing Filter
SpatialDwell.config.gaussfilter.sigma = gaussfilter_sigma; 
SpatialDwell.config.gaussfilter.filter = gaussfilter_filter;
SpatialDwell_g = imgaussfilt(SpatialDwell.SpatialDwellMap,SpatialDwell.config.gaussfilter.sigma,'FilterSize',SpatialDwell.config.gaussfilter.filter);%Igarashi-san-> boxer カーネル使ってる.
SpatialDwell.config.StayTimeCutFff = config_StayTimeCutFff; %sec
SpatialDwell_g(find(SpatialDwell_g < SpatialDwell.config.StayTimeCutFff)) = NaN; %cutoff: stay time
SpatialDwell.SpatialDwellMap_Smooth = SpatialDwell_g;
SpatialDwell.Unit_SpatialDwellMap_Smooth = 'sec';
%%
%%%%% First half & Second half data %%%%%
MatrixBase = size(SpatialDwell.SpatialDwellMap);
MatrixBase_size = size(SpatialDwell.SpatialDwellMap);

ndata = size(wk_x,1);
if rem(ndata,2) == 0
    wk_x_first = wk_x(1:(ndata/2));
    wk_x_second = wk_x((ndata/2)+1:ndata);
    wk_y_first = wk_y(1:(ndata/2));
    wk_y_second = wk_y((ndata/2)+1:ndata);
else
    wk_x_first = wk_x(1:((1+ndata)/2));
    wk_x_second = wk_x( (1+ndata)/2+1:ndata);
    wk_y_first = wk_y(1:((1+ndata)/2));
    wk_y_second = wk_y( (1+ndata)/2+1:ndata);
end 

%trajectoryを前後半にわけると、matrixサイズが異なる可能性がたかいため、
%1: edgeだけのmatrixを作成し、
%2: 前半（後半）のmatrixにedgeのmatrixを足したmatrixを作成
%3:　(2のmatrix) - (1のmatrix)ででるはず。edgeを含まない場合、マイナスとなるのでそこは0で置換する。
MatrixEdge_x = [max(wk_x),min(wk_x)];
MatrixEdge_y = [max(wk_y),min(wk_y)];
[MatrixEdge.SpatialDwellMap, MatrixEdge.mapset_base] = general.mapDATA_v3(MatrixEdge_x,MatrixEdge_y,[],2,SpatialDwell.config.BinSize_Pixel);

wk_x_first2 = [wk_x_first;max(wk_x);min(wk_x)];
wk_y_first2 = [wk_y_first;max(wk_y);min(wk_y)];
[FirstHalf.SpatialDwellMap, FirstHalf.mapset_base2] = general.mapDATA_v3(wk_x_first2,wk_y_first2 ,[],2,SpatialDwell.config.BinSize_Pixel);
FirstHalf.SpatialDwellMap = FirstHalf.SpatialDwellMap -MatrixEdge.SpatialDwellMap;
wk_x_second2 = [wk_x_second;max(wk_x);min(wk_x)];
wk_y_second2 = [wk_y_second;max(wk_y);min(wk_y)];
[SecondHalf.SpatialDwellMap, Second.mapset_base2] = general.mapDATA_v3(wk_x_second2,wk_y_second2 ,[],2,SpatialDwell.config.BinSize_Pixel);
SecondHalf.SpatialDwellMap = SecondHalf.SpatialDwellMap -MatrixEdge.SpatialDwellMap;

FirstHalf.SpatialDwellMap = FirstHalf.SpatialDwellMap * 1/fps;
SecondHalf.SpatialDwellMap = SecondHalf.SpatialDwellMap * 1/fps;
FirstHalf.Unit_SpatialDwellMap = 'sec';
SecondHalf.Unit_SpatialDwellMap = 'sec';

%Smoothing Filter
FirstHalf.config.gaussfilter.sigma = gaussfilter_sigma; 
SecondHalf.config.gaussfilter.sigma = gaussfilter_sigma; 
FirstHalf.config.gaussfilter.filter = gaussfilter_filter; 
SecondHalf.config.gaussfilter.filter = gaussfilter_filter;
FirstHalf_SpatialDwell_g =  imgaussfilt(FirstHalf.SpatialDwellMap,FirstHalf.config.gaussfilter.sigma ,'FilterSize',FirstHalf.config.gaussfilter.filter);%Igarashi-san-> boxer カーネル使ってる.
SecondHalf_SpatialDwell_g = imgaussfilt(SecondHalf.SpatialDwellMap,SecondHalf.config.gaussfilter.sigma ,'FilterSize',SecondHalf.config.gaussfilter.filter);%Igarashi-san-> boxer カーネル使ってる.
FirstHalf.config.StayTimeCutFff = config_StayTimeCutFff; %sec
SecondHalf.config.StayTimeCutFff = config_StayTimeCutFff; %sec
FirstHalf_SpatialDwell_g(find(SpatialDwell_g < SpatialDwell.config.StayTimeCutFff)) = NaN; %cutoff: stay time
SecondHalf_SpatialDwell_g(find(SpatialDwell_g < SpatialDwell.config.StayTimeCutFff)) = NaN; %cutoff: stay time
FirstHalf.SpatialDwellMap_Smooth = FirstHalf_SpatialDwell_g;
SecondHalf.SpatialDwellMap_Smooth = SecondHalf_SpatialDwell_g;
FirstHalf.Unit_SpatialDwellMap_Smooth = 'sec';
SecondHalf.Unit_SpatialDwellMap_Smooth = 'sec';

if ~downsampling
    save(fullfile(dir_matsave,'Processed_DLC','Dwell_Spatial.mat'),'SpatialDwell','FirstHalf','SecondHalf');
else
    save(fullfile(dir_matsave,'Processed_DLC','Dwell_Spatial_DownSampling.mat'),'SpatialDwell','FirstHalf','SecondHalf');
end

%% FIGURE- all data
SpatialDwell.config.Figure = draw_fig;
if ~downsampling
    if SpatialDwell.config.Figure
        close all
        switch TrialEnviroment
            case 'Corridor'
                aspct = [80,8,1];
                w = 300*3;
                TILE= [4,1]; 
            case 'EightMaze'
                aspct = [1,1,1];
                w = 300*1;
                TILE= [1,4];
            case'SquareBox'
                aspct = [1,1,1];
                w = 300*1;
                TILE= [1,4];
        end
        figure('Name','SpatialDwell map','Position',[0 0 1250 w])
        tiledlayout(TILE(1),TILE(2),'TileSpacing','Compact','Padding','Compact');    
        
        %% accumulated moved-distance
        nexttile 
        time_vector = DistanceMoved(:,1);
        totalTime = time_vector(end)/60;
        DM_cumulative = [];%unit = meter
        DM = DistanceMoved(:,2)/100; %for changeing unit from cm to meter
        for i = 1 : numel(time_vector)
            if i == 1
                DM_cumulative(i,1) = DM(i);
            else
                DM_cumulative(i,1) = nansum(DM(1:i));
            end
        end
        DM_cumulative(isnan(DM)) = NaN;
        plot(time_vector/60,DM_cumulative,'LineWidth',1.5);
        box off
        set(gca,'TickDir','out');
        ylabel('Distance (m)')
        xlabel('Time (minutes)')
        xlim([0 totalTime])
        pbaspect([1,1,1])    
        subtitle('Accumulated distance','FontSize',10,'FontWeight','bold')
        title(dir_figsave_behavior,'FontSize', 6,'FontName','Arial')
        
        %% trajectory
        nexttile   
        hold on
        %plot(Body_Center(:,1),Body_Center(:,2))
        scatter(Body_Center(:,1),Body_Center(:,2),5,VELOCITY,'filled','MarkerFaceAlpha',.5)
        colormap(turbo)
        c = colorbar;
        ylabel(c, 'cm/s')
        
        set(gca, 'YDir','reverse')
        xlim([min(Body_Center(:,1)),max(Body_Center(:,1))])
        ylim([min(Body_Center(:,2)),max(Body_Center(:,2))])
        set(gca,'TickDir','out');
        box off
        xlabel('pixel');ylabel('pixel')
        pbaspect(aspct)
        subtitle('Trajectory','FontSize',10,'FontWeight','bold')
        
    
    %% dwell map
    for q = 1 : 2
        switch q
            case 1
                imdata = SpatialDwell.SpatialDwellMap;
                text = 'Raw data';
            case 2
                imdata = SpatialDwell.SpatialDwellMap_Smooth;
                text = 'Gaussian';
        end
        nexttile
        imagesc(imdata); pbaspect(aspct)
        xlabel('bin');ylabel('bin')
        c = colorbar;
        ylabel(c, 'sec')
        subtitle(text,'FontSize',10,'FontWeight','bold')
        set(gca,'TickDir','out');
        box off
        
    end

    %% save
    SAVEDIR = [dir_figsave_behavior,'/DLC_DwellMaps/'];
    mkdir(SAVEDIR)
    exportgraphics(gcf,[SAVEDIR,'/SpatialDwellMap.tiff'],'Resolution',300)  
    set(gca,'TickDir','out');
    %close
    end
    
    %% FIGURE- half data
    SpatialDwell.config.Figure = draw_fig;
    if SpatialDwell.config.Figure
        close all  
        switch TrialEnviroment
            case 'Corridor'
                aspct = [80,8,1];
                w = 1350;
                h = 300;
            case 'EightMaze'
                aspct = [1,1,1];
                w = 1250;
                h = 600;
            case'SquareBox'
                aspct = [1,1,1];
                w = 1250;
                h = 600;
        end
        figure('Name','SpatialDwell map','Position',[200 400 w h])
        tiledlayout(2,3,'TileSpacing','Compact','Padding','Compact');    
        %% trajectory
        for plt = 1 : 2
            switch plt
                case 1
                    p_data = [wk_x_first,wk_y_first];
                    tp= 1; 
                    name = 'First half';
                    V = VELOCITY(1:length(p_data));
                case 2
                    p_data = [wk_x_second,wk_y_second];
                    tp= 4;
                    name = 'Second half';
                    V = VELOCITY(length(V)+1:end);
            end
            nexttile(tp,[1,1])
            %plot(p_data(:,1),p_data(:,2))
            scatter(p_data(:,1),p_data(:,2),5,V,'filled','MarkerFaceAlpha',.5)
            colormap(turbo)
            c = colorbar;
            ylabel(c, 'cm/s')
        
            set(gca, 'YDir','reverse')
            pbaspect(aspct)
            xlim([min(Body_Center(:,1)),max(Body_Center(:,1))])
            ylim([min(Body_Center(:,2)),max(Body_Center(:,2))])
            set(gca,'TickDir','out');
            box off
            xlabel('pixel');ylabel('pixel')
            subtitle('Trajectory','FontSize',10,'FontWeight','bold')
            title(name)
        end
 
        %% dwell map
        for plt = 1 : 2
            switch plt
                case 1
                    p_data = FirstHalf;
                    tp= [2,3];
                    name = 'First half';
                case 2
                    p_data = SecondHalf;
                    tp= [5,6];
                    name = 'Second half';
            end
            for q = 1 : 2
                switch q
                    case 1
                        imdata = p_data.SpatialDwellMap;
                        text = 'Raw data';
                    case 2
                        imdata = p_data.SpatialDwellMap_Smooth;
                        text = 'Gaussian';
                end

                nexttile(tp(q),[1,1])
                imagesc(imdata); pbaspect(aspct)
                xlabel('bin');ylabel('bin')
                c = colorbar;
                ylabel(c, 'sec')
                subtitle(text,'FontSize',10,'FontWeight','bold')
                set(gca,'TickDir','out');
                box off
                title(name)
            end
        end
        %% save
        SAVEDIR = [dir_figsave_behavior,'/DLC_DwellMaps/'];
        mkdir(SAVEDIR)
        exportgraphics(gcf,[SAVEDIR,'/SpatialDwellMap_half.tiff'],'Resolution',600)  
        set(gca,'TickDir','out');
        %close
    end
end
close all


end