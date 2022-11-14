function AngularHeadVelocityDwell(AHV,figsavedir,FPS)
%% Histogram 
close all
figure('Name','AHV Dwell map','Position',[0 0 800 400])
tiledlayout(1,1,'TileSpacing','Compact','Padding','Compact');

h = histogram(AHV,'FaceColor','k','FaceAlpha',0.1);
hold on
plot([min(AHV),min(AHV)],[0,max(h.Values)],'--r')
hold on
plot([prctile(AHV,95),prctile(AHV,95)],[0,max(h.Values)],'-b','LineWidth',1)

hold on
plot([max(AHV),max(AHV)],[0,max(h.Values)],'--r')
hold on
plot([prctile(AHV,5),prctile(AHV,5)],[0,max(h.Values)],'-b','LineWidth',1)

ylabel(['Count (',num2str(FPS),' fps)'])
xlabel('AHV (degree/sec)')
box off
set(gca,'TickDir','out'); % The only other option is 'in'
legend('Hist','Min/Max AHV','5%/95% AHV')
title('Histogram of AHV')

SAVEDIR = [figsavedir,'/DLC_DwellMaps/'];
exportgraphics(gcf,[SAVEDIR,'/HeadDirection_AHV_DwellMap.tiff'],'Resolution',300)  
close all
end