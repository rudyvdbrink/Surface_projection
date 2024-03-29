function  [dat, ldat, rdat, vdat] = glasserize_cifti(fname,makefig,surface)
% data = glasserize_cifti(file,makefig,surface) gets the data in 'file'
% and computes the parcel-wise median in the Glasser atlas. This currently
% only works for the HCP myelin map that is supplied with this repository, 
% because the imported cifti structure contains fields that are dependant 
% on the filename. 
%
% No z-scoring is applied to the data, and the color range for figures is 1
% to 1.8.
%   
%   Input: 
%       - file is a string denoting a cifti .nii file, including its full 
%         path
%       - makefig determines if a plot of the surface projection is made 
%         (1) or not (0, default)
%       - surface is the surface used for plotting, and can be:
%           'flat'
%           'midthickness'
%           'inflated' (default)
%           'very_inflated'
%           'sphere'
%   Output:
%       - dat is a 1 x 360 vector of values, the first 180 values are the
%         parcels in the left hemisphere, the last 180 values are the right
%         hemisphere
%       - ldat is a 1 x 180 vector of values of parcels in the left
%         hemisphere only
%       - rdat is a 1 x 180 vector of values of parcels in the right
%         hemisphere only
%       - vdat is the orgininal vertex-wise data
%
% RL van den Brink, 2018
% github.com/rudyvdbrink

%% check input

warning('off','all')
if ~exist(fname,'file')
    error(['File ' fname ' not found']) 
end

if ~exist('makefig','var')
    makefig = 0;
end

if ~exist('surface','var')
    surface = 'inflated';
end

if isempty(makefig)
    makefig = 0;
end

if isempty(surface)
    surface = 'inflated';
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
c     = ft_read_cifti(fname); %load the data
f     = fields(c); %get field names of the data structure, which depend on the file name
vdat  = eval(['c.' f{end}]); %get the vertex-level data
rmpath(genpath(ftdir)); %remove fieldtrip again because of annoying conflicting function name warnings

%% get values for left hemisphere

dat = atlas.brainstructure == 1;
dat = atlas.indexmax(dat);
nidx = isnan(dat);
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
    file_ri = nonzeros(vdat(idx));
    ldat(rj) = nanmedian(file_ri);
end

%% plot mapped file (if requested)

if makefig     
    %make an empty surface
    file_mapped = atlas;
    file_mapped.indexmax = zeros(size(file_mapped.indexmax));
    
    %fill in the atlas with z-scored values
    for rj = 1:length(ris)
        ri = ris(rj);
        idx = dat == ri;
        file_mapped.indexmax(idx) = ldat(rj);
    end
    
    file_mapped.indexmax(nidx) = nan; %set medial wall to nan   
    
    % get cortical surface (for plotting)
    gname = [gdir 'S1200.L.' surface '_MSMAll.32k_fs_LR.surf.gii'];
    g = gifti(gname); %surface
    
    dat = file_mapped.brainstructure == 1; %indices of left hemisphere
    dat = file_mapped.indexmax(dat); %select left hemisphere
    dat(nidx) = 1000; %set null vertices to high value
    clim = [min(ldat) max(ldat)]; %define color limit
    cmap = [inferno(180); 1 1 1];    
    cortsurfl(g,dat,cmap,clim,surface)
end




%% get values for right hemisphere

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

offset = sum(atlas.brainstructure == 2); %accounts for the fact that the loaded surface is only one hemisphere
%get the value of each brain region
for rj = 1:length(ris)
    ri = ris(rj); %get value of current parcel
    idx = find(dat == ri)-offset; %find vertices of the current parcel (in the right hemsiphere)
    file_ri = nonzeros(vdat(idx)); %get data of the current parcel
    rdat(rj) = nanmedian(file_ri); %take the median, while excluding empty vertices
end

%% plot mapped file (if requested)

if makefig
    %define empty surface
    file_mapped.indexmax = nan(size(file_mapped.indexmax));
    
    %fill in the atlas with z-scored values
    for rj = 1:length(ris)
        ri = ris(rj);
        idx = dat == ri;
        file_mapped.indexmax(idx) = rdat(rj);
    end
        
    % get cortical surface (for plotting)
    gname = [gdir 'S1200.R.' surface '_MSMAll.32k_fs_LR.surf.gii'];
    g = gifti(gname); %surface    
    
    dat = file_mapped.brainstructure == 2; %indices of right hemisphere
    dat = file_mapped.indexmax(dat); %select right hemisphere
    dat(isnan(dat)) = 1000; %set null vertices to high value
    clim = [min(rdat) max(rdat)]; %define color limit
    cmap = [inferno(180); 1 1 1];
    cortsurfr(g,dat,cmap,clim,surface)
end

%concatinate hemispheres
dat = [ldat rdat];

