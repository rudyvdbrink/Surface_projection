clear
close all
clc

%% path definition

homedir = mfilename('fullpath'); %folder where this function is stored plus its file name
homedir = homedir(1:end-7); %just the folder where this function is stored 
addpath(genpath(homedir))

%% project a volumetric file to the cortical surface, and plot it

fname = [homedir 'volumetric\CHRNB3.nii']; %define file name
[dat, ldat, rdat] = glasserize_nifti(fname,1,'inflated'); %surface project and plot


