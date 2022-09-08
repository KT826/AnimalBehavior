function [PostProcessing,dlc_cutoff,dlc_cutoff_smoothing] = DLCPostProcessing(dlc,cutoff_thr,cutoff_parts,SmoothingFilter_name,SmoothingFilter_bin,draw_fig,figsavedir,path_Video,make_new_video)

global fps

%%  Post-processing of DLC exports
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%1) Removing low-confidence tracking
%2) Smoothing with a median filter (width of frames  corresponding 250ms) 
% based on "Shamash,...& Branco et.al., 2021 Nature Neuroscience
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

%1)Removing low-confidence tracking
%PostProcessing.cutoff_thr = 0.7;
%PostProcessing.cutoff_parts = {'body';'miniscope';'ear_L';'ear_R';'tail_base'};
PostProcessing.cutoff_thr = cutoff_thr;
PostProcessing.cutoff_parts = cutoff_parts;

dlc_cutoff = dlc;
for p = 1 : numel(PostProcessing.cutoff_parts)
    eval(['lh = dlc_cutoff.',PostProcessing.cutoff_parts{p},'_lh;']);
    idxcut = find(lh<PostProcessing.cutoff_thr);
    eval(['dlc_cutoff.',PostProcessing.cutoff_parts{p},'_x(idxcut) = NaN;']);
    eval(['dlc_cutoff.',PostProcessing.cutoff_parts{p},'_y(idxcut) = NaN;']);
    clear lh idxcut p
end

%2)Smoothing with a median filter (frames of 250ms)
dlc_cutoff_smoothing = [];
%v = VideoReader(path_Video);
%fps = v.FrameRate; clear v
PostProcessing.SmoothingFilter_name = SmoothingFilter_name; %'movmedian'
PostProcessing.SmoothingFilter_bin = SmoothingFilter_bin; %250/(1000/fps); %frame. 250ms


for p = 1 : numel(PostProcessing.cutoff_parts)
    eval(['x = dlc_cutoff.',PostProcessing.cutoff_parts{p},'_x;']);
    eval(['y = dlc_cutoff.',PostProcessing.cutoff_parts{p},'_y;']);
    x_smooth = smoothdata(x,PostProcessing.SmoothingFilter_name,PostProcessing.SmoothingFilter_bin);
    y_smooth = smoothdata(y,PostProcessing.SmoothingFilter_name,PostProcessing.SmoothingFilter_bin);
    eval([PostProcessing.cutoff_parts{p},'_x = x_smooth;']);
    eval([PostProcessing.cutoff_parts{p},'_y = y_smooth;']);
    eval([PostProcessing.cutoff_parts{p},'_x = table(',PostProcessing.cutoff_parts{p},'_x);']);
    eval([PostProcessing.cutoff_parts{p},'_y = table(',PostProcessing.cutoff_parts{p},'_y);']);
    eval(['dlc_cutoff_smoothing = [dlc_cutoff_smoothing,',PostProcessing.cutoff_parts{p},'_x,',PostProcessing.cutoff_parts{p},'_y];']);
    clear body_* ear_* tail_base_* miniscope_* x* y* p
end

%summary
PostProcessing.summary = [];
PostProcessing.figure = draw_fig;%true;
close all
for p = 1 : numel(PostProcessing.cutoff_parts)
    eval(['x_cutoff = dlc_cutoff.',PostProcessing.cutoff_parts{p},'_x;']);
    CutoffFramePercentage = sum(isnan(x_cutoff))/numel(x_cutoff);
    eval(['PostProcessing.summary.CutoffFramePercentage_',PostProcessing.cutoff_parts{p},'=' num2str(CutoffFramePercentage),';'])
    clear x_cutoff CutoffFramePercentage p    
end

%% figure
if PostProcessing.figure == true        
    f = transpose(1:1:size(dlc,1));
    figsavesubdir = [figsavedir,'/DLC_SmoothedBodyCoordination/'];
    mkdir(figsavesubdir)
    for p = 1 : numel(PostProcessing.cutoff_parts)
        eval(['x = dlc.',PostProcessing.cutoff_parts{p},'_x;']);
        eval(['x_cutoff_smoothing = dlc_cutoff_smoothing.',PostProcessing.cutoff_parts{p},'_x;']);
        eval(['y = dlc.',PostProcessing.cutoff_parts{p},'_y;']);
        eval(['y_cutoff_smoothing = dlc_cutoff_smoothing.',PostProcessing.cutoff_parts{p},'_y;']);
        eval(['lh = dlc.',PostProcessing.cutoff_parts{p},'_lh;']);
        figure('Name',['DLC_PostProcessing_',PostProcessing.cutoff_parts{p}],'Position',[0 0 1800 700])
        tiledlayout(3,1,'TileSpacing','Compact','Padding','Compact');
        
         
        for q = 1 : 2
            switch q 
                case 1
                    ydata = x;
                    ydata_smooth = x_cutoff_smoothing;
                    SUBTITLE = 'x';
                case 2
                    ydata = y;
                    ydata_smooth = y_cutoff_smoothing;
                    SUBTITLE = 'y';
            end
            nexttile
            plot(f,ydata,'r-','LineWidth',1)
            hold on
            plot(f,ydata_smooth,'b-','LineWidth',0.5)
            newchr = strrep(PostProcessing.cutoff_parts{p},'_',' ');
            title([newchr])
            
            txt = ['{\color{red}Raw data; }', '{\color{blue}Cutoff&Smoothing}'];
            subtitle([SUBTITLE, ' (',txt,')'])
            
            xlim([0 numel(f)]);
            ylim([0 max(ydata)*1.05]);box off       
            set(gca,'TickDir','out');
        end
        
        nexttile
        plot(f,lh,'k-')
        hold on
        plot([1,f(end)+100],[PostProcessing.cutoff_thr ,PostProcessing.cutoff_thr],'--m')
        xlim([0 numel(f)]);ylim([0 1.05]);box off
        set(gca,'TickDir','out');
        txt = ['{\color{black}likelihood; }', '{\color{magenta}Cutoff threshold}'];
        subtitle(txt)
        
        figsavenama= [figsavesubdir,'/',PostProcessing.cutoff_parts{p},'.tiff'];
        
        exportgraphics(gcf,figsavenama,'Resolution',300)    
        
        clear newchr p lh x* y* figsavenama
        close all
    end
    clear figsamedir f
end

%% make mp4 movie
PostProcessing.movie= make_new_video.TF; %ture of false


if PostProcessing.movie == true      
    v = VideoReader(path_Video);
    fps = v.FrameRate;
    ds = make_new_video.dawnsampling;
    switch (fps/ds) == floor(fps/ds) %if framerate/downsampling is not integer, downsamopling is changed to 1 (= no downsampling)
        case 0
            ds = 1;
    end
    
    
    COL = colormap(cool(numel(PostProcessing.cutoff_parts))); close
    newvideo = VideoWriter([figsavedir,'/Movie_smoothingDLC.mp4'],'MPEG-4');
    newvideo.FrameRate = fps/ds;
    newvideo.Quality = 100;
    open(newvideo)

    for f = 1 : ds : v.NumFrames
        frame = read(v,f);
        for bp = 1 : numel(PostProcessing.cutoff_parts) %insert ROI
            eval(['x = dlc_cutoff_smoothing.',PostProcessing.cutoff_parts{bp},'_x(',num2str(f),');'])
            eval(['y = dlc_cutoff_smoothing.',PostProcessing.cutoff_parts{bp},'_y(',num2str(f),');'])
            if ~isnan(x)
                frame = insertShape(frame,'FilledCircle',[x,y,10],'Color',COL(bp,:)*255,'Opacity',0.8);
            end
        end
        %frame number
        frame = insertText(frame,[0,0],['frame#' num2str(f)],'Font','Century Gothic','FontSize',25,'TextColor','black','BoxColor','y','BoxOpacity',0);
        writeVideo(newvideo,frame)
        clear frame
    end
close(newvideo);
end

