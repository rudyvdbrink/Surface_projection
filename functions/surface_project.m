function file = surface_project(fname,hemi,fillholes,makefig,surface)
% data = surface_project(file,hemi,fillholes,makefig,surface)
%
%   Input: 
%       - file is a string denoting a nifti .nii file, including its full 
%         path
%       - hemi is a string that indicates which hemisphere should be
%         projected to the surface, and can be either 'L' (left, defautlt)
%         or 'R' (right)
%       - fillholes is a logical variable that determines if empty vertices
%         are interprolated across (1) or not (0, default). if fillholes is
%         selected, projected values on the medial wall are also set to 
%         zero
%       - makefig determines if a plot of the surface projection is made 
%         (1) or not (0, default)
%       - surface is the surface used for plotting, and can be:
%           'flat'
%           'midthickness'
%           'inflated' (default)
%           'very_inflated'
%           'sphere'
%   Output:
%       - data is a gifti object that contains vertex-wise values of the
%         projected file
%
% RL van den Brink, 2018
% github.com/rudyvdbrink

%% check input

warning('off','all')
if ~exist(fname,'file')
    error(['File ' fname ' not found']) 
end

if ~exist('hemi','var')
    hemi = 'L';
end

if ~exist('fillholes','var')
    fillholes = 0;
end

if ~exist('makefig','var')
    makefig = 0;
end

if ~exist('surface','var')
    surface = 'inflated';
end

if isempty(hemi)
    hemi = 'L';
end

if isempty(makefig)
    makefig = 0;
end

if isempty(surface)
    surface = 'inflated';
end

if isempty(hemi)
    surface = 'L';
end


%% path definitions

%     -------CHANGE THIS------
wb         = 'C:\DATA\Programs\workbench\'; %workbench folder
wb_command = [wb 'bin_windows64\wb_command']; %command for workbench (this should refer to the wb_command.exe file, without the ".exe" extension
ftdir      =  'C:\DATA\Programs\fieldtrip-20170809'; %folder with fieldtrip, I used the version of 2017 08 09

homedir = mfilename('fullpath'); %folder where this function is stored plus its file name
rootdir = homedir(1:end-25); %folder with everything for surface projection
gdir    = [rootdir 'support_files\']; %folder where the suraces are stored
addpath(genpath(rootdir));

%% run surface projection

filename = tempname; %define a temporary file name 
method =  '-enclosing'; %define the projection method (enclosing works best)

%map the volumetric image to the surface
system([wb_command ' -volume-to-surface-mapping ' fname ' ' [gdir 'S1200.' hemi '.midthickness_MSMAll.32k_fs_LR.surf.gii'] ' ' [filename '.func.gii'] ' ' method]);

%get the surface-level data and delete temporary files
file = gifti([filename '.func.gii']);
delete([filename '*'])

%% fill holes if requested

if fillholes
    file = fill_holes(file,gdir,ftdir,hemi);
else
    file.cdata(isnan(file.cdata)) = 0;
end

%% make figure if requested

if makefig
    dat = file.cdata;
    nidx = dat == 0;
    dat(nidx) = 1000;
    dat(~nidx) = zscore(dat(~nidx));
    clim = [-3 3];
    cmap = [inferno(180); 1 1 1];
    
    gname = [gdir 'S1200.' hemi '.' surface '_MSMAll.32k_fs_LR.surf.gii'];
    g = gifti(gname); %surface
    if strcmpi(hemi,'L')
        cortsurfl(g,dat,cmap,clim,surface);
    else
        cortsurfr(g,dat,cmap,clim,surface);
    end
end


end

%% supporting function

function dat = fill_holes(dat,gdir,ftdir,hemi)
% usage: dat = fill_holes(dat,gdir,ftdir,hemi);
%
% interpolates across areas with values 0
%
%    - dat is a gifti structure that resulted from volume to surface 
%      mapping using the hcp workbench software
%    - gdir if the folder with the gifti toolbox
%    - ftdir is the folder with fieldtrip
%    - hemi is a string that determines which hemisphere we're working on
%      (either 'L' or 'R')
%
% null indeces along the midline ventricles are used for the interpolation
% so leave them untouched (i.e. setting to nan will result in nans for the
% bordering interpolated regions). 
%
% fill_holes removes values from the midline after interpolation

%% get the cortical surface

addpath(genpath('C:\DATA\Programs\gifti-1.6')) %gifti toolbox
gname = [gdir 'S1200.' hemi '.midthickness_MSMAll.32k_fs_LR.surf.gii'];
g = gifti(gname); %surface

%% get the atlas (for null indices)

addpath(genpath(ftdir)); %add fieldtrip to path
atlas = [gdir 'Glasser_atlas.dlabel.nii']; %define Glasser atlas file
atlas = ft_read_cifti(atlas);
if strcmpi(hemi,'L')
    atlas.indexmax = atlas.indexmax(1:length(atlas.indexmax)/2); %only save values of the left hemisphere
else
    atlas.indexmax = atlas.indexmax(length(atlas.indexmax)/2+1:end); %only save values of the right hemisphere
end
rmpath(genpath(ftdir)); %remove fieldtrip again because of annoying conflicting function name warnings

%% get points to fill

outdat = dat;
dat = dat.cdata;
nullvals = isnan(atlas.indexmax);
idx = dat==0; %the indces of holes to fill
dat = double(dat);

%% interpolate the grid points

X = g.vertices(1:length(dat),1);
Y = g.vertices(1:length(dat),2);
Z = g.vertices(1:length(dat),3);
V = dat;

X = double(X);
Y = double(Y);
Z = double(Z);

Xq = X(idx);
Yq = Y(idx);
Zq = Z(idx);

X(idx) = [];
Y(idx) = [];
Z(idx) = [];
V(idx) = [];

Vq = griddata(X,Y,Z,V,Xq,Yq,Zq,'linear'); % interpolates to find Vq, the values
   
dat(idx) = Vq;
dat(isnan(dat)) = 0;

dat = single(dat);
dat(nullvals) = 0;

outdat.cdata = dat;
dat = outdat;

end
