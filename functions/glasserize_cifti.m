function  [dat, ldat, rdat] = glasserize_cifti(file)


addpath(genpath('C:\DATA\Programs\fieldtrip-20170809'))
atlas = 'C:\DATA\Gene_clustring\hcp\HCP_S1200_GroupAvg_v1\Q1-Q6_RelatedValidation210.CorticalAreas_dil_Final_Final_Areas_Group_Colors.32k_fs_LR.dlabel.nii';
atlas = ft_read_cifti(atlas);

gdir = 'C:\DATA\Gene_clustring\hcp\HCP_S1200_GroupAvg_v1\';

% g = [gdir 'S1200.L.flat.32k_fs_LR.surf.gii'];
% g = [gdir 'S1200.L.midthickness_MSMAll.32k_fs_LR.surf.gii'];
g = [gdir 'S1200.L.inflated_MSMAll.32k_fs_LR.surf.gii'];
% g = [gdir 'S1200.L.very_inflated_MSMAll.32k_fs_LR.surf.gii'];
% g = [gdir 'S1200.L.sphere.32k_fs_LR.surf.gii'];


g = gifti(g); %surface
c = ft_read_cifti(file); %data

%% get values for left hemisphere

dat = atlas.brainstructure == 1;
dat = atlas.indexmax(dat);
dat(isnan(dat)) = 0;

file_mapped = atlas;
file_mapped.indexmax = zeros(size(file_mapped.indexmax));

ris = nonzeros(unique(dat));


%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj);
    idx = dat == ri;
    file_ri = nonzeros(c.smoothedmyelinmap_bc_msmall(idx));
    file_ri_all(rj) = nanmedian(file_ri);
end

ldat = file_ri_all;


%% get values for right hemisphere


dat = atlas.brainstructure == 2;
dat = atlas.indexmax(dat);
dat(isnan(dat)) = 0;

file_mapped = atlas;
file_mapped.indexmax = zeros(size(file_mapped.indexmax));

ris = nonzeros(unique(dat));

file_ri_all = [];
%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj);
    idx = dat == ri;
    file_ri = nonzeros(c.smoothedmyelinmap_bc_msmall(idx));
    file_ri_all(rj) = nanmedian(file_ri);
end

rdat = file_ri_all;

dat = [ldat rdat];


% %%
% dat = c.brainstructure == 1; 
% dat = c.smoothedmyelinmap_bc_msmall(dat); 
% m = max(dat); dat(isnan(dat)) = 1000; 
% clim = [0 m+0.1];
% cortsurf(g,dat,[hot(64); 1 1 1],clim)