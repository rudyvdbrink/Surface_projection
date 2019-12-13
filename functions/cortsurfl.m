function cortsurfl(g,dat,cmap,clim,surface)
% CORTSURFL(gl,ldat,clim,surface) plots the data in ldat onto the cortical 
% surface of the left hemisphere. 
%
% See also CORTSURFR
%
% RL van den Brink, 2019


%% plot surfaces

dat(dat>=clim(2) & dat < 999) = clim(2)-0.1; %set values outside the color range to the max

figure

if ~strcmpi(surface,'flat')
    subplot(1,2,1)
end

trisurf(g.faces,g.vertices(:,1),g.vertices(:,2),g.vertices(:,3),dat,'edgealpha',0)

colormap(cmap)
axis vis3d
axis square
axis off
set(gca,'clim',clim)
material dull
lighting flat
set(gcf,'color','w')

if sum(strcmpi(surface,{'inflated' 'very_inflated' 'midthickness'}))
    view([270 0])
    xlim([-100 50])
    zlim([-70 80])
    ylim([-105 70])
    camlight left
elseif strcmpi(surface,'flat')
    view([270 90])
elseif strcmpi(surface,'sphere')
    view([-230 0])
    camlight left
end


if ~strcmpi(surface,'flat')
    subplot(1,2,2)
    trisurf(g.faces,g.vertices(:,1),g.vertices(:,2),g.vertices(:,3),dat,'edgealpha',0)
    
    colormap(cmap)
    axis vis3d
    axis square
    axis off
    set(gca,'clim',clim)
    material dull
    lighting flat
    set(gcf,'color','w')
    
    if sum(strcmpi(surface,{'inflated' 'very_inflated' 'midthickness'}))
        view([90 0])
        xlim([-100 50])
        zlim([-70 80])
        ylim([-105 70])
        camlight left
    elseif strcmpi(surface,'sphere')
        view([0 0])
        camlight right
    end
end


