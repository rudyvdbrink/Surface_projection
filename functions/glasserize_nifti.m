function [dat, ldat, rdat] = glasserize_nifti(fname,makefig,surface)
% data = glasserize_nifti(file,makefig,surface) projects the data in 'file'
% to HCP surface space and computes the parcel-wise median in the Glasser
% atlas. 
%   
%   Input: 
%       - filename is a string denoting a nifti .nii file, including its 
%         full path
%       - makefig determines if a plot of the surface projection is made 
%         (1) or not (0, default)
%       - surface is the surface used for plotting, and can be:
%           'flat'
%           'midthickness'
%           'inflated' (default)
%           'very_inflated'
%           'sphere'
%   Output:
%       - dat is a 1 x 360 vector of values, the first 180 values are the
%         parcels in the left hemisphere, the last 180 values are the right
%         hemisphere
%       - ldat is a 1 x 180 vector of values of parcels in the left
%         hemisphere only
%       - rdat is a 1 x 180 vector of values of parcels in the left
%         hemisphere only
%
% RL van den Brink, 2018

%% check input

warning('off','all')
if ~exist(fname,'file')
    error(['File ' fname ' not found']) 
end

if ~exist('makefig','var')
    makefig = 0;
end

if ~exist('surface','var')
    surface = 'inflated';
end

if isempty(surface)
    surface = 'inflated';
end

%% path definitions

%     -------CHANGE THIS------
wb         = 'C:\DATA\Programs\workbench\'; %workbench folder
wb_command = [wb 'bin_windows64\wb_command']; %command for workbench (this should refer to the wb_command.exe file, without the ".exe" extension
ftdir      =  'C:\DATA\Programs\fieldtrip-20170809'; %folder with fieldtrip, I used the version of 2017 08 09

homedir = mfilename('fullpath'); %folder where this function is stored plus its file name
rootdir = homedir(1:end-26); %folder with everything for surface projection
gdir    = [rootdir 'support_files\']; %folder where the suraces are stored
addpath(genpath(rootdir));

%% get glasser atlas

addpath(genpath(ftdir)); %add fieldtrip to path
atlas = [gdir 'Glasser_atlas.dlabel.nii']; %define Glasser atlas file
atlas = ft_read_cifti(atlas);
rmpath(genpath(ftdir)); %remove fieldtrip again because of annoying conflicting function name warnings

%% project left hemisphere to surface

filename = tempname; %define a temporary file name 
method =  '-enclosing'; %define the projection method (enclosing works best)

%map the volumetric image to the surface
system([wb_command ' -volume-to-surface-mapping ' fname ' ' [gdir 'S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii'] ' ' [filename '.func.gii'] ' ' method]);

%get the surface-level data and delete temporary files
file = gifti([filename '.func.gii']);
delete([filename '*'])

%% map data to atlas
dat = atlas.brainstructure == 1; %find vertices in the left hemisphere
dat = atlas.indexmax(dat); %select those vertices in the atlas
nidx = isnan(dat); %find indeces of null vertices (on the medial wall)
dat(nidx) = 0; %set null indices to zero

%define ROIs
ris = nonzeros(unique(dat));

%initialize
ldat = zeros(1,length(ris));

%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj); %get value of current parcel
    idx = dat == ri; %find vertices of the current parcel
    file_ri = nonzeros(file.cdata(idx)); %get data of the current parcel
    ldat(rj) = nanmedian(file_ri); %take the median, while excluding empty vertices
end

%zscore (across parcels)
ldat = zscore(ldat);

%% plot mapped file (if requested)

if makefig     
    %make an empty surface
    file_mapped = atlas;
    file_mapped.indexmax = zeros(size(file_mapped.indexmax));
    
    %fill in the atlas with z-scored values
    for rj = 1:length(ris)
        ri = ris(rj);
        idx = dat == ri;
        file_mapped.indexmax(idx) = ldat(rj);
    end
    
    file_mapped.indexmax(nidx) = nan; %set medial wall to nan   
    
    % get cortical surface (for plotting)
    gname = [gdir 'S1200.L.' surface '_MSMAll.32k_fs_LR.surf.gii'];
    g = gifti(gname); %surface
    
    dat = file_mapped.brainstructure == 1; %indices of left hemisphere
    dat = file_mapped.indexmax(dat); %select left hemisphere
    dat(nidx) = 1000; %set null vertices to high value
    clim = [-4 4]; %define color limit
    cmap = [inferno(180); 1 1 1];
    
    cortsurfl(g,dat,cmap,clim)
end








%% project right hemisphere to surface

%map the volumetric image to the surface
system([wb_command ' -volume-to-surface-mapping ' fname ' ' [gdir 'S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii'] ' ' [filename '.func.gii'] ' ' method]);

%get the surface-level data and delete temporary files
file = gifti([filename '.func.gii']);
delete([filename '*'])

%% map gene to atlas

dat = atlas.indexmax;
dat(atlas.brainstructure~=2) = 0;
nidx = isnan(dat);
dat(nidx) = 0;

file_mapped = atlas;
file_mapped.indexmax = zeros(size(file_mapped.indexmax));

%define ROIs
ris = nonzeros(unique(dat));

%initialize
rdat = zeros(1,length(ris));

offset = sum(atlas.brainstructure == 2); %accounts for the fact that the loaded surface is only one hemisphere
%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj); %get value of current parcel
    idx = find(dat == ri)-offset; %find vertices of the current parcel (in the right hemsiphere)
    file_ri = nonzeros(file.cdata(idx)); %get data of the current parcel
    rdat(rj) = nanmedian(file_ri); %take the median, while excluding empty vertices
end

%zscore across space
rdat = zscore(rdat);

%% plot mapped file (if requested)

if makefig
    %define empty surface
    file_mapped.indexmax = nan(size(file_mapped.indexmax));
    
    %fill in the atlas with z-scored values
    for rj = 1:length(ris)
        ri = ris(rj);
        idx = dat == ri;
        file_mapped.indexmax(idx) = rdat(rj);
    end
        
    % get cortical surface (for plotting)
    gname = [gdir 'S1200.R.' surface '_MSMAll.32k_fs_LR.surf.gii'];
    g = gifti(gname); %surface    
    
    dat = file_mapped.brainstructure == 2; %indices of right hemisphere
    dat = file_mapped.indexmax(dat); %select right hemisphere
    dat(isnan(dat)) = 1000; %set null vertices to high value
    clim = [-4 4]; %define color limit
    cmap = [inferno(180); 1 1 1];
    cortsurfr(g,dat,cmap,clim)
end

%concatinate left and right hemispheres
dat = [ldat rdat];


end

