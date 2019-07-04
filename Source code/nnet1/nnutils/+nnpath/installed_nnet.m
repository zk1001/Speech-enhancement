function paths = installed_nnet(nnet_root)

% Copyright 2013 The MathWorks, Inc.

if nargin < 1, nnet_root = nnpath.nnet_root; end

% /toolbox/nnet/*
nnet_toolbox = fullfile(nnet_root,'toolbox','nnet');
paths = toolboxDirs(nnet_toolbox);

% /TOOLS
tools_path = fullfile(nnpath.nnet_root,'TOOLS');
if exist(tools_path,'dir')
  tools_paths = toolboxDirs(tools_path);
  paths = [paths; tools_paths(:)];
end

% /COMPILED
compiled_path = fullfile(nnpath.nnet_root,'COMPILED');
if exist(compiled_path,'dir')
  compiled_paths = toolboxDirs(compiled_path);
  paths = [paths; compiled_paths(:)];
end

% /NEW
new_path = fullfile(nnpath.nnet_root,'NEW');
if exist(compiled_path,'dir')
  new_paths = toolboxDirs(new_path);
  paths = [paths; new_paths(:)];
end

function paths = toolboxDirs(root,paths)

if nargin < 2, paths = {}; end
paths = [paths; {root}];
files = dir(root);
for i=1:length(files)
  if (files(i).isdir) && (files(i).name(1) ~= '.')
    name = files(i).name;
    if name(1) == '@', continue, end
    if name(1) == '+', continue, end
    if strcmpi(name,'nnresource'), continue, end
    if strcmpi(name,'private'), continue, end
    if strcmpi(name,'demosearch'), continue, end
    if strcmpi(name,'html'),continue,  end
    if strcmpi(name,'ja'), continue, end
    if strcmpi(name,'cvs'), continue, end
    paths = toolboxDirs([root filesep name],paths);
  end
end
paths = sort(paths);
