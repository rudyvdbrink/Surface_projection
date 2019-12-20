# Surface projection
 
This repository contains matlab code to project 3D volumetric nifti images in 2mm isotropic MNI space (see example file in folder 'volumetric') to the HCP MMP surface, and extract values of each parcel in the Glasser atlas (see example.m for syntax). 

This code will not run out of the box. You'll need: 

 - An installed version of the human connectome workbench software (https://www.humanconnectome.org/software/get-connectome-workbench)
 - Fieldtrip (http://www.fieldtriptoolbox.org/)
 - To edit the relevant lines in the functions so that these packages are found by matlab (lines 58-60 in glasserize_nifti.m, line 65 in glasserize_cifti.m, and lines 72-74 in surface_project.m)

This code will enable you to do do the following:

<p align="center">
    <img src="https://raw.githubusercontent.com/rudyvdbrink/Surface_projection/master/overview.png" width="600"\>
</p>

Code to compute and plot parcel-wise median values of a T1 / T2 contrast (myelin map) is also provided. The myelin map as well as the surface files are from the HCP S1200 release (https://www.humanconnectome.org/study/hcp-young-adult/document/1200-subjects-data-release) 

Labels to atlas parcels can be found in Glasser_labels.csv.
