# Surface projection
 
This repository contains matlab code to:
 - Project 3D volumetric nifti images in 2mm isotropic MNI space (see example file in folder 'volumetric') to the HCP MMP surface
 - Extract values of each parcel in the Glasser atlas 
 - Create null maps by spherical rotation
 - Test spatial correlation between maps and compute p-values      that take into account spatial autocorrelation in the maps 

See example.m for syntax. 

This code will not run out of the box. You'll need: 

 - An installed version of the human connectome workbench software (https://www.humanconnectome.org/software/get-connectome-workbench)
 - Fieldtrip (http://www.fieldtriptoolbox.org/)
 - To edit the relevant lines in the "functions/pathfindr();" so that these packages are found by matlab (lines 21, 25, and possibly line 23 depending on your OS)


<p align="center">
    <img src="https://raw.githubusercontent.com/rudyvdbrink/Surface_projection/master/overview.png" width="600"\>
</p>

Code to compute and plot parcel-wise median values of a T1 / T2 contrast (myelin map) is also provided. The myelin map as well as the surface files are from the HCP S1200 release (https://www.humanconnectome.org/study/hcp-young-adult/document/1200-subjects-data-release). The file 'mvals.csv' also contains the parcel-wise median values of the myelin map.  

Labels to atlas parcels can be found in Glasser_labels.csv.

List of functions:

 - glasserize_nifti: produce parcel-wise median values for a volumetric nifti (.nii) file
 - glasserize_cifti: produce parcel-wise median values for a surface file
 - glasserize_surface: produce parcel-wise median values for a surface vector
 - surface_project: project a volumetric file to the cortical surface, and return spatially z-scored vertex-wise values 
 - surface_project_raw: project a volumetric file to the cortical surface, and return the raw vertex-wise values
 - correlate_surface: correlate two surface vectors while controlling for spatial autocorrelation
 - sphere_rotate: produce spherically rotated surrogate maps 
 - cortsurfl: plot data onto the cortical surface of the left hemisphere
 - cortsurfr: plot data onto the cortical surface of the right hemisphere
 - pathfindr: function to set paths
 - inferno: the inferno color map
