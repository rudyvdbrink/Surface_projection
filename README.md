# Surface projection
 
This repository contains matlab code to project volumetric nifti images in 2mm isotropic MNI space (example in folder 'volumetric') to the HCP MMP surface, and extract values of each parcel in the Glasser atlas (see example.m for syntax). 

In order for this code to run on your system, you need:

 - An installed version of the human connectome workbench software (https://www.humanconnectome.org/software/get-connectome-workbench)
 - Fieldtrip (http://www.fieldtriptoolbox.org/)
 - To edit the relevant lines in the functions so that these packages are found by matlab (lines 55-57 in glasserize_nifti.m, and lines xxxx in glasserize_cifti.m)

To do:
 - help function surface_project
 - update glasserize_nifti with surface_project call
 - make figure
 - make a list of glasser labels
 - Include link to the HCP files
 - Update this readme file (lines to modify)
 
