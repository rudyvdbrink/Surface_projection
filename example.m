clear
close all
clc

%% path definition

homedir = mfilename('fullpath'); %folder where this function is stored plus its file name
homedir = homedir(1:end-7); %just the folder where this function is stored 
addpath(genpath(homedir))

%% project the left hemisphere of a volumetric file on an inflated surface, and plot it vertex-wise

fname = [homedir 'volumetric\CHRNB3.nii']; %define file name
surface_project(fname,'L',1,1,'inflated');

%% project a volumetric file on a very inflated surface, and plot it parcel-wise, and get the data into working memory

[dat, ldat, rdat] = glasserize_nifti(fname,1,'very_inflated'); %surface project and plot

%% plot the myelin map on a sphere parcel-wise

fname = [homedir 'support_files\S1200.MyelinMap.dscalar.nii'];
glasserize_cifti(fname,1,'sphere');

%% plot the myelin map on an inflated surface parcel-wise

glasserize_cifti(fname,1,'inflated');

%% correlate the myelin map with the example map, and compute p-value corrected for spatial auto correlation with spherical rotation

fname = [homedir 'support_files\S1200.MyelinMap.dscalar.nii']; %define file name
[~,~,~,surface1] = glasserize_cifti(fname); %get the vertex-wise values of the myelin map
surface1 = surface1(1:size(surface1)/2); %select the left hemisphere

%surface_project_raw does the same as surface_project, but no spatial
%normalization is applied
fname = [homedir 'volumetric\CHRNB3.nii']; %define file name
surface2 = surface_project_raw(fname,'L',1); %get the map to correlate with the myelin map (also left hemisphere)
surface2 = surface2.cdata; %select just the data, so get rid of the gifti info

%set options:
npermutes = 1000; %number of null maps to create
hemi      = 'L'; %which hemisphere
tail      = 'left'; %test one-tailed
mode      = 'vertex'; %run correlation at the vertex level
opts      = {'type', 's'}; %use spearman's rho

%run the correlation (this can take a few minutes)
[r, p, r_null] = correlate_surface(surface1,surface2,npermutes,hemi,tail,mode,opts);
