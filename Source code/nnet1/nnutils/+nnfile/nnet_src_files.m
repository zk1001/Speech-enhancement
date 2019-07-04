function paths = nnet_src_files(root,paths)

% Copyright 2010-2012 The MathWorks, Inc.

if nargin < 1, root = nnpath.nnet_root; end
if nargin < 2, paths = {}; end

subroot = fullfile(root,'java','src','com','mathworks','toolbox','nnet');
paths = subfunction(subroot,paths);
paths = sort(paths);

function paths = subfunction(root,paths)

files = dir(root);
for i=1:length(files)
  name = files(i).name;
  if name(1) == '.', continue, end
  if files(i).isdir
    if strcmpi(name,'cvs'), continue, end
    paths = subfunction([root filesep name],paths);
  else
    if nnstring.ends(name,'.asv'), continue, end
    paths = [paths; {[root filesep name]}];
  end
end
