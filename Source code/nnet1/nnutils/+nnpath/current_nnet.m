function paths = current_nnet

% Copyright 2013 The MathWorks, Inc.

nnet_root = nnpath.nnet_root;
nnet_toolbox = nnpath.nnet_toolbox;
nnet_NEW = fullfile(nnet_root,'NEW');
nnet_COMPILED = fullfile(nnet_root,'COMPILED');
nnet_TOOLS = fullfile(nnet_root,'TOOLS');
Phil = fullfile(fileparts(nnet_root),fullfile('Phil','NNT'));

p = path;
separators = [0 find(p == pathsep) (length(p)+1)];
numPaths = length(separators)-1;
paths = {};
for i=1:numPaths
  pi = p((separators(i)+1):(separators(i+1)-1));
  if nnstring.starts(pi,nnet_toolbox) || ...
    nnstring.starts(pi,nnet_NEW) || ...
    nnstring.starts(pi,nnet_COMPILED) || ...
    nnstring.starts(pi,nnet_TOOLS) || ...
    nnstring.starts(pi,Phil)
    paths = [paths; {pi}];
  end
end

paths = sort(paths);