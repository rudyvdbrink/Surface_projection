function null = sphere_rotate(indata,n,hemi,prog)
% null = sphere_rotate(indata,n,hemi)
%
% Produces a null map using spherical rotation of the cortical surface. 
%
%   Input: 
%       - indata is a vector of  vertex-level data points, and must have 
%         the medial wall set to NaN.
%       - n determines the number of null maps that are created (default = 
%         1)
%       - hemi is a string that indicates which hemisphere should be
%         projected to the surface, and can be either 'L' (left, defautlt)
%         or 'R' (right)
%       - prog sets progress watcher on (1) or off (0, default).
%
%   Output:
%       - null is a vector or matrix of n null maps, with a length the same
%         as indata 
%
% RL van den Brink, 2020
% github.com/rudyvdbrink


%% check input
if ~exist('indata','var')
    error('Provide at least one input');
end

if ~exist('n','var')
    n = 1;
end

if isempty(n)
    n = 1;
end

if ~exist('hemi','var')
    hemi = 'L';
end

if isempty(hemi)
    hemi = 'L';
end

if ~exist('prog','var')
    prog = 0;
end

if isempty(prog)
    prog = 'L';
end

%% seed random number generator

rng('shuffle')

%% get spherical surface

gname = ['S1200.' hemi '.sphere_MSMAll.32k_fs_LR.surf.gii'];
g     = gifti(gname); %surface    

%% check data size and assumptions

if length(indata) ~= length(g.vertices)
    error('Data length does not match number of surface vertices')
end    

if sum(isnan(indata)) == 0
    error('Medial wall must be set to nan')
end

%% rotate

%initialize
null = nan(length(indata),n); 

%random angles of rotation
x = rand(n,1)*(2*pi);
y = rand(n,1)*(2*pi);
z = rand(n,1)*(2*pi);

%unrotated spherical vertices
Xq = double(g.vertices(1:length(indata),1));
Yq = double(g.vertices(1:length(indata),2));
Zq = double(g.vertices(1:length(indata),3));

if prog
    fprintf('Creating null maps: ');
end

%loop over number of rotations
for ri = 1:n
    g_null = g; %the (pre) rotated sphere
    R = makehgtform('yrotate',x(ri),'xrotate',y(ri),'zrotate',z(ri)); %the rotation matrix
    R = R(1:3,1:3); %trim to 3D
    g_null.vertices = g_null.vertices * R; %rotate
    
    %rotated spherical vertices
    X = double(g_null.vertices(1:length(indata),1));
    Y = double(g_null.vertices(1:length(indata),2));
    Z = double(g_null.vertices(1:length(indata),3));
    
    %get rotated data points on our original surface points
    null(:,ri) = griddata(X,Y,Z,double(indata),Xq,Yq,Zq,'nearest'); 
    
    %display progress if needed
    if prog && mod(ri,n/10) == 0
         fprintf([num2str((ri/n)*100) '%%\t']);
    end
end

if prog
    fprintf('Done!\n')
end
%set medial wall to nan
null(isnan(indata),:) = nan;

end