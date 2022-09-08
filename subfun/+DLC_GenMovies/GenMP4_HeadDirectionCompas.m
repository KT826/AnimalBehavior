function GenMP4_HeadDirectionCompas(HD,VEL, time,dir_figsave,downsampling)
global fps


%% if HD has been input as degree, chenges to radian
if max(HD)> 180
    HD = deg2rad(HD);
end

%% normalize VEL for polarplot visibility
VEL = VEL./max(VEL);
rlim_range = [0 prctile(VEL,90)];

%%
clear F
figure('Position',[50 50 300 280])
k = 0;
for i = 1 : downsampling: size(HD,1)
    pax = polarplot([HD(i),HD(i)],[0,VEL(i)],'LineWidth',3,'Color','b');
    
    if k  == 0
        set(gca,'Color','w')
        thetaticks([])%thetaticks(0:90:360)
        rticks([])
        rlim([rlim_range])
    end
    title(['Frame#',num2str(i)], ['Time#',num2str(time(i),4)])
    
    k = k + 1;
    F(k) = getframe(1);
    cla
end 


newvideo = VideoWriter([dir_figsave,'/HeadDirectionCompas.mp4'],'MPEG-4');
newvideo.FrameRate = fps/downsampling;
newvideo.Quality = 100;
open(newvideo)
writeVideo(newvideo,F);
close(newvideo);
end
