function net = input(net,i,x)
%NNET.INTERNAL.CONFIGURE.INPUT

% Copyright 2010-2015 The MathWorks, Inc.

% Input Data
if nargin < 3
  if ~isempty(net.inputs{i}.exampleInput)
    % NNET 6.0 Compatibility
    x = net.inputs{i}.exampleInput;
  else
    x = net.inputs{i}.range;
  end
else
  if ~isempty(net.inputs{i}.exampleInput)
    % NNET 6.0 Compatibility
    net.inputs{i}.exampleInput = nnet.array.safeGather(x);
  end
end

% Configure Size
net.inputs{i}.size = size(x,1);
net.inputs{i}.range = nnet.array.safeGather(minmax(x));

% Configure Processing
numProcess = length(net.inputs{i}.processFcns);
processFcns = net.inputs{i}.processFcns;
processParams = net.inputs{i}.processParams;
net.inputs{i}.processSettings = cell(1,numProcess);
for j=1:numProcess
  [x,config] = feval(processFcns{j},x,processParams{j});
  net.inputs{i}.processSettings{j} = config;
end

% Configure Size
net.inputs{i}.processedSize = size(x,1);
net.inputs{i}.processedRange = nnet.array.safeGather(minmax(x));

% Configure Dependent Weights
layerToInd = find(net.inputConnect(:,i))';
for j = layerToInd
  net = nnet.internal.configure.inputWeight(net,j,i,x);
end
