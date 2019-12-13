function cortsurfl(g,dat,cmap,clim,surface)
% CORTSURFL(gl,ldat,clim,surface) plots the data in ldat onto the cortical 
% surface of the left hemisphere. 
%
% See also CORTSURFR
%
% RL van den Brink, 2019

%% set areas to exclude from plotting, zscore, and define color range

% dat(isnan(dat)) = 1000; %set nans to a large value
% dat(dat<999) = zscore(dat(dat<999)); %zscore the real data
% clim = [-3 3]; %set color limit
dat(dat>=clim(2) & dat < 999) = clim(2)-0.1; %set values outside the color range to the max
% cmap = [inferno(64); 1 1 1]; %define colormap

%% plot surfaces

figure

subplot(1,2,1)
trisurf(g.faces,g.vertices(:,1),g.vertices(:,2),g.vertices(:,3),dat,'edgealpha',0)

view([270 0])
colormap(cmap)
axis vis3d
axis square
axis off
xlim([-100 50])
zlim([-70 80])
ylim([-105 70])
set(gca,'clim',clim)
material dull
lighting flat
set(gcf,'color','w')
camlight left


subplot(1,2,2)
trisurf(g.faces,g.vertices(:,1),g.vertices(:,2),g.vertices(:,3),dat,'edgealpha',0)

view([90 0])
colormap(cmap)
axis vis3d
axis square
axis off
xlim([-100 50])
zlim([-70 80])
ylim([-105 70])
set(gca,'clim',clim)
material dull
lighting flat
set(gcf,'color','w')
camlight left
