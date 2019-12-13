function [file_ri_all, vertexdat] = glasserize_nifti(file,makefig,surface)
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
%           'inflated'
%           'very_inflated'
%           'sphere'


%% check input
warning('off','all')
if ~exist(file,'file')
    error(['File ' file ' not found']) 
end

if ~exist('makefig','var')
    makefig = 0;
end

if ~exist('surface','var')
    surface = 'inflated';
end

%% path definitions

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
system([wb_command ' -volume-to-surface-mapping ' file ' ' [gdir 'S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii'] ' ' [filename '.func.gii'] ' ' method]);

%get the surface-level data and delete temporary files
file = gifti([filename '.func.gii']);
delete([filename '*'])

%% map data to atlas
dat = atlas.brainstructure == 1; %find vertices in the left hemisphere
dat = atlas.indexmax(dat); %select those vertices in the atlas
nidx = isnan(dat); %find indeces of null vertices (on the medial wall)
dat(nidx) = 0; %set null indices to zero

file_mapped = atlas;
file_mapped.indexmax = zeros(size(file_mapped.indexmax));

%define ROIs
ris = nonzeros(unique(dat));

%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj);
    idx = dat == ri;
    file_ri = nonzeros(file.cdata(idx));
    file_ri_all_l(rj) = nanmedian(file_ri);
end

%zscore
file_ri_all_l = zscore(file_ri_all_l);

%fill in the atlas with z-scored values
for rj = 1:length(ris)
    ri = ris(rj);
    idx = dat == ri;
    file_mapped.indexmax(idx) = file_ri_all_l(rj);
end

file_mapped.indexmax(isnan(atlas.indexmax)) = nan;

%% plot mapped file

if makefig    
    % get cortical surface
    gname = [gdir 'S1200.L.' surface '_MSMAll.32k_fs_LR.surf.gii'];
    g = gifti(gname); %surface    
    
    dat = file_mapped.brainstructure == 1;
    dat = file_mapped.indexmax(dat);
    dat(isnan(dat)) = 1000;
    clim = [-4 4];
    cmap = [hot(180); 1 1 1];
    cortsurfl(g,dat,cmap,clim)
end






%% get cortical surface

gdir = 'C:\DATA\Gene_clustring\hcp\HCP_S1200_GroupAvg_v1\';
gname = [gdir 'S1200.R.inflated_MSMAll.32k_fs_LR.surf.gii'];
g = gifti(gname); %surface

%% Right hemisphere

%write out a temporary nifti file
filename = tempname;
method =  '-enclosing';

file = tmp;
%map the volumetric image to the surface
system([wb_command ' -volume-to-surface-mapping ' file ' ' [gdir 'S1200.R.midthickness_MSMAll.32k_fs_LR.surf.gii'] ' ' [filename '.func.gii'] ' ' method]);

%get the surface-level data of this sample location and delete
%temporary files
file = gifti([filename '.func.gii']);
delete([filename '*'])

% a = fix_holes(file.cdata);
vertexdat = [vertexdat file.cdata];


%% map gene to atlas


% dat = atlas.brainstructure == 2;

dat = atlas.indexmax;
dat(atlas.brainstructure~=2) = 0;
% dat = atlas.indexmax(dat);
dat(isnan(dat)) = 0;

file_mapped = atlas;
file_mapped.indexmax = zeros(size(file_mapped.indexmax));

ris = nonzeros(unique(dat));
% length(ris)

offset = sum(atlas.brainstructure == 2); %accounts for the fact that the loaded nifti (gene data) is only one hemisphere
%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj);
    idx = find(dat == ri)-offset;
    file_ri = nonzeros(file.cdata(idx));
    file_ri_all_r(rj) = nanmedian(file_ri);
end

%zscore
file_ri_all_r = zscore(file_ri_all_r);

%fill in the atlas with z-scored values
for rj = 1:length(ris)
    ri = ris(rj);
    idx = dat == ri;
    file_mapped.indexmax(idx) = file_ri_all_r(rj);
end

file_mapped.indexmax(isnan(atlas.indexmax)) = nan;

file_ri_all = [file_ri_all_l file_ri_all_r];



%% plot mapped gene for a sec

if makefig
    dat = file_mapped.brainstructure == 2;
    dat = file_mapped.indexmax(dat);
    dat(isnan(dat)) = 1000;
    clim = [-4 4];    
    cmap = [hot(180); 1 1 1];   
    cortsurfr(g,dat,cmap,clim)
end
%     text(-0, -170, -60 , lab{gi,1},'fontsize',25)
%     set(gcf,'pos',[10 10 1024 786])
%     saveas(gcf,[figdir num2str(gi) '_' lab{gi}],'png');
%     close

