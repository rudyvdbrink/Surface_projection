function [r, p, r_null, maps_null] = correlate_surface(surface1,surface2,npermutes,hemi,tail,mode,opts)
% [r, p, r_null, maps_null] = correlate_surface(s1,s2,np,hemi,tail,mode,opts)
% 
% Spatially correlate two maps (s1 and s2), and compute a p-value for this
% correlation based on spherically rotated surrogate (null) maps, computed
% with the spin-test method described by Alexander-Bloch et al (2018). 
% Input s2 is used to generate the null maps.  
%   
%   Input: 
%       - s1: vector of input vertex-wise data (can be produced with
%         the surface_project or surface_project_raw functions).
%       - s2:  vector of input vertex-wise data (can be produced with
%         the surface_project or surface_project_raw functions).
%       - np: the number of null maps that are created (default, 1000)
%       - hemi: is a string that indicates from which hemisphere the data 
%         in s1 and s2 orginate, and can be 'L' (left, defautlt), or 'R' 
%         (right).
%       - tail: test one-tailed (specify 'right' or 'left') or two-tailed 
%         (specify 'both'). default is two-tailed
%         if there is no a priori expectation, then use 'tail' = 'both'
%         if the a priori expectation is that r > 0, then use 'tail' = 
%         'right'. if the a priori expectation is that r < 0, then use 
%         'tail' = 'left' 
%       - mode: run the correltation at the vertex-level ('vertex', 
%         default) or at the glasser atlas parcel level ('glasser). 
%       - opts: cell array with options for the correlation. the default is
%         opts = {'type', 's'} (which runs spearman correlation)
%
%   Output:
%       - r: the correlation coefficient between s1 and s2.
%       - p: the p-value of the correlation, taking spatial
%         auto-correlation into account.
%       - r_null: the null distribution of correlation coefficients
%       - maps_null: vertex by np matrix of spherically rotated null maps
%
% Reference:
% Alexander-Bloch, AF, Shou, H, Liu, S, Satterthwaite, TD, Glahn, DC,
% Shinohara, RT, Vandekar, SN, Raznahan, A, (2018) On testing for spatial
% correspondence between maps of human brain structure and function.
% Neuroimage 178, 540-551. doi:10.1016/j.neuroimage.2018.05.070
%
% RL van den Brink, 2020
% github.com/rudyvdbrink

%% check the input

if ~exist('npermutes','var')
    npermutes = 1000;
end

if isempty(npermutes)
    npermutes = 1000;
end

if ~exist('hemi','var')
    hemi = 'L';
end

if isempty(hemi)
    hemi = 'L';
end

if ~exist('tail','var')
    tail = 'both';
end

if isempty(tail)
    tail = 'both';
end

if ~exist('mode','var')
    mode = 'vertex';
end

if isempty(mode)
    mode = 'vertex';
end

if ~exist('opts','var')
    opts = {'type', 's'};
end

if isempty(opts)
    opts = {'type', 's'};
end

if sum(size(surface1) == size(surface2)) ~= 2
    error('Mismatch in input data size')
end

nidx = logical(isnan(surface1)+isnan(surface2)); %indices of nan in the vertices
if sum(nidx) == 0
    error('Medial wall must be set to nan')
end
    
%% get true correlation coefficient

if strcmpi(mode,'vertex')
    r = corr(surface1(~nidx), surface2(~nidx),opts{:});
elseif strcmpi(mode,'glasser')
    g1 = glasserize_surface(surface1,hemi)';
    g2 = glasserize_surface(surface2,hemi)';
    gnidx = logical(isnan(g1)+isnan(g2)); %indices of nan in the glasser parcels
    r = corr(g1(~gnidx), g2(~gnidx),opts{:});
end

%% produce null surfaces

%if npermutes is large this can take a while
maps_null = sphere_rotate(surface2,npermutes,hemi,1);

%% get null correlations

%initialize
r_null = zeros(npermutes,1);
fprintf('Permuting:\t')

%run correlation on the vertex-level
if strcmpi(mode,'vertex')
    
    %permute
    for permi = 1:npermutes
        nnidx = isnan(maps_null(:,permi)); %indices of nan in the vertices
        r_null(permi) = corr(surface1(~nnidx), maps_null(~nnidx,permi), opts{:});
        if mod(permi,npermutes/10) == 0; fprintf([num2str((permi/npermutes)*100) '%%\t']); end
    end

%run correlation on the parcel-level    
elseif strcmpi(mode,'glasser')
    
    %permute
    for permi = 1:npermutes        
        g2 = glasserize_surface(maps_null(:,permi),hemi)'; %get parcel-wise median of null map
        gnnidx = logical(isnan(g1)+isnan(g2)); %indices of nan in the glasser parcels
        r_null(permi) = corr(g1(~gnnidx), g2(~gnnidx),opts{:}); %correlate
        if mod(permi,npermutes/10) == 0; fprintf([num2str((permi/npermutes)*100) '%%\t']); end
    end
    
end

fprintf('Done!\n')

%% get p-value

%calculate p-value
if strcmpi(tail,'both')    
    p = 1-sum(abs(r)>abs(r_null))/npermutes;
elseif strcmpi(tail,'right')
    p = 1-sum(r>r_null)/npermutes;
elseif strcmpi(tail,'left')
    p = 1-sum(r<r_null)/npermutes;
end



end