function [file_ri_all, vertexdat] = glasserize_nifti(file,makefig)
% data = glasserise_nifti(file,makefig,surface)
% filename is a string denoting a nifti file

warning('off','all')
if ~exist(file,'file')
    error(['File ' file ' not found']) 
end

if ~exist('makefig','var')
    makefig = 0;
end

tmp = file;

%% path definitions

addpath('C:\DATA\Gene_clustring\')
addpath(genpath('C:\DATA\Programs\gifti-1.6')) %gifti toolbox
wb = 'C:\DATA\Programs\workbench\'; %workbench folder
wb_command = [wb 'bin_windows64\wb_command']; %command for workbench

gdir = 'C:\DATA\Gene_clustring\hcp\HCP_S1200_GroupAvg_v1\';
gname = [gdir 'S1200.L.inflated_MSMAll.32k_fs_LR.surf.gii'];


%% get glasser atlas

addpath(genpath('C:\DATA\Programs\fieldtrip-20170809'))
atlas = 'C:\DATA\Gene_clustring\glasser_atlas\Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii';
atlas = ft_read_cifti(atlas);
rmpath(genpath('C:\DATA\Programs\fieldtrip-20170809'));



%% get cortical surface

gdir = 'C:\DATA\Gene_clustring\hcp\HCP_S1200_GroupAvg_v1\';
gname = [gdir 'S1200.L.inflated_MSMAll.32k_fs_LR.surf.gii'];
g = gifti(gname); %surface
% clc

%% left hemisphere

%write out a temporary nifti file
filename = tempname;
method =  '-enclosing';


%map the volumetric image to the surface
system([wb_command ' -volume-to-surface-mapping ' file ' ' [gdir 'S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii'] ' ' [filename '.func.gii'] ' ' method]);

%get the surface-level data of this sample location and delete
%temporary files
file = gifti([filename '.func.gii']);
delete([filename '*'])


vertexdat = file.cdata;


%% map gene to atlas
dat = atlas.brainstructure == 1;
dat = atlas.indexmax(dat);
nidx = isnan(dat);
vertexdat(nidx) = nan;
dat(isnan(dat)) = 0;

file_mapped = atlas;
file_mapped.indexmax = zeros(size(file_mapped.indexmax));

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

%% plot mapped gene for a sec

if makefig
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

