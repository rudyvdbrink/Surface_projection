# Surface projection
 
This repository contains matlab code to project volumetric nifti images in 2mm isotropic MNI space (example in folder 'volumetric') to the HCP MMP surface, and extract values of each parcel in the Glasser atlas (see example.m for syntax). 

This code will not run out of the box. You'll need: 

 - An installed version of the human connectome workbench software (https://www.humanconnectome.org/software/get-connectome-workbench)
 - Fieldtrip (http://www.fieldtriptoolbox.org/)
 - To edit the relevant lines in the functions so that these packages are found by matlab (lines 58-60 in glasserize_nifti.m, line 65 in glasserize_cifti.m, and lines 70-72 in surface_project.m)

This code will allow you to do do the following:

<p align="center">
    <img src="https://ruudvandenbrink.files.wordpress.com/2019/12/overview.png" width="450"\>
</p>
<p align="center">
    The receptor maps
</p>


Code to plot and compute parcel-wise median values of a T1 / T2 contrast (myelin) is also provided. 


To do:
 - make a list of glasser labels
 - Include link to the HCP files
 - Update this readme file (lines to modify)
 
