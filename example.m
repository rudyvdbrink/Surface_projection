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

