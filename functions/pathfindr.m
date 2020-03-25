function path = pathfindr(inpath)
% path = pathfindr(inpath)
%
% Finds a requested path. 
%
%   Valid requests for inpath are: 
%       - 'wbdir': folder where the connectome workbench software is
%         installed
%       - 'wbcommand': folder (within workbench folder) that contains the
%         wb_command.exe
%       - 'ftdir': folder with Fieldtrip
%       - 'gdir': folder that contains all surface files
%   
%   Output:
%       - string variable with the requested path

%% get the path

switch inpath
    case 'wbdir'
        path = 'C:\DATA\Programs\workbench\'; %workbench folder
    case 'wbcommand'
        path = 'bin_windows64'; %folder name (within workbench folder) that contains wb_command.exe
    case 'ftdir'
        path = 'C:\DATA\Programs\fieldtrip-20170809\'; %folder with fieldtrip, I used the version of 2017 08 09
    case 'gdir'
        homedir = mfilename('fullpath'); %folder where this function is stored plus its file name
        rootdir = homedir(1:end-19); %folder with everything for surface projection
        path    = [rootdir 'support_files\']; %folder where the suraces are stored        
end

if ~exist('path','var')
    error(['Unrecognized path request "' inpath '"'])
end

