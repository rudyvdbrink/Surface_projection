function  dat = glasserize_surface(indata, hemi)
% data = glasserize_surface(indata, hemi) computes glasser atlas parcel-
% wise median values from the vertex-wise data indata. 
%   
%   Input: 
%       - indata: vector of input vertex-wise data (can be produced with
%         the surface_project or surface_project_raw functions).
%       - hemi is a string that indicates which hemisphere should be
%         used to the surface, and can be 'L' (left, defautlt), or 'R' 
%         (right), or 'both'. If hemi = 'both', indata must be the
%         vertex-wise data of both hemispheres concatinated, with the first
%         50% of voxels being the left hemisphere.
%
%   Output:
%       - data: the n x 1 data vecotor of parcel-wise median values. n
%         depends on the selected hemisphere option: if hemi = 'L' or 'R',
%         n = 180, if hemi = 'both', n = 360 (in the latter case, the first
%         180 values are the left hemisphere, the last 180 values are the
%         right hemisphere).
%
% RL van den Brink, 2018
% github.com/rudyvdbrink

%% check input

warning('off','all')

if ~exist('indata','var')
    error('Provide at least one input argument')
end

if ~exist('hemi','var')
    hemi = 'L';
end

if isempty(hemi)
    hemi = 'L';
end

%% path definitions

homedir = mfilename('fullpath'); %folder where this function is stored plus its file name
rootdir = homedir(1:end-26); %folder with everything for surface projection
gdir    = pathfindr('gdir'); %folder where the suraces are stored
addpath(genpath(rootdir));
ftdir =  pathfindr('ftdir'); %folder with fieldtrip, I used the version of 2017 08 09

%% get glasser atlas and load the data

addpath(genpath(ftdir)); %add fieldtrip to path
atlas = [gdir 'Glasser_atlas.dlabel.nii']; %define Glasser atlas file
atlas = ft_read_cifti(atlas); %load the atlas
rmpath(genpath(ftdir)); %remove fieldtrip again because of annoying conflicting function name warnings

%% data assumption check

if strcmpi(hemi, 'both')
    if length(indata) ~= length(atlas.indexmax)
        error('Wrong input data size for selected hemisphere option')
    end
elseif strcmpi(hemi,'L')
    if length(indata) ~= length(atlas.indexmax) / 2
        error('Wrong input data size for selected hemisphere option')
    end
end

%% get values for left hemisphere

if strcmpi(hemi,'L') || strcmpi(hemi,'both')
    
    dat = atlas.brainstructure == 1;
    dat = atlas.indexmax(dat);
    nidx = isnan(dat); %indices of the medial wall
    dat(nidx) = 0;
    
    file_mapped = atlas;
    file_mapped.indexmax = zeros(size(file_mapped.indexmax));
    
    ris = nonzeros(unique(dat));
    
    %initialize
    ldat = zeros(1,length(ris));
    
    %get the value of each brain region
    for rj = 1:length(ris)
        ri = ris(rj);
        idx = dat == ri;
        file_ri = nonzeros(indata(idx));
        ldat(rj) = nanmedian(file_ri);
    end
    
end

%% get values for right hemisphere

if strcmpi(hemi,'R') || strcmpi(hemi,'both')
    
    dat = atlas.indexmax;
    dat(atlas.brainstructure~=2) = 0;
    nidx = isnan(dat);
    dat(nidx) = 0;
    
    file_mapped = atlas;
    file_mapped.indexmax = zeros(size(file_mapped.indexmax));
    
    %define ROIs
    ris = nonzeros(unique(dat));
    
    %initialize
    rdat = zeros(1,length(ris));
    
    if length(indata) == length(atlas.indexmax)/2
        offset = sum(atlas.brainstructure == 2); %accounts for the fact that the loaded surface is only one hemisphere
    elseif length(indata) == length(atlas.indexmax)
        offset = 0;
    end
    
    %get the value of each brain region
    for rj = 1:length(ris)
        ri = ris(rj); %get value of current parcel
        idx = find(dat == ri)-offset; %find vertices of the current parcel (in the right hemsiphere)
        file_ri = nonzeros(indata(idx)); %get data of the current parcel
        rdat(rj) = nanmedian(file_ri); %take the median, while excluding empty vertices
    end    
end

%% produce the output

if strcmpi(hemi,'both')
    %concatinate hemispheres
    dat = [ldat rdat];
elseif strcmpi(hemi,'L')
    dat = ldat;
elseif strcmpi(hemi,'R')
    dat = rdat;
end

