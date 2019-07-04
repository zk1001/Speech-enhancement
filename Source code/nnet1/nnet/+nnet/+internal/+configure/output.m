function net = output(net,i,t,dimensions,layerFlag)
%NNET.INTERNAL.CONFIGURE.OUTPUT

% Copyright 2010-2015 The MathWorks, Inc.

  % Default arguments
  if nargin < 3
    t = net.layers{i}.range;
  end
  if nargin < 5
    layerFlag = false;
  end

  % NNET 6.0 Compatibility
  if ~isempty(net.outputs{i}.exampleOutput)
    if (nargin < 3)
      t = net.outputs{i}.exampleOutput;
    else
      net.outputs{i}.exampleOutput = nnet.array.safeGather(t);
    end
  end

  % Configure Size
  newSize = size(t,1);
  net.outputs{i}.size = newSize;
  net.outputs{i}.range = nnet.array.safeGather(minmax(t));

  % Configure Processing
  [net,t] = iConfigureProcessingFunctions(net,i,t);
  
  % Size
  newProcessedSize = size(t,1);
  net.outputs{i}.processedSize = newProcessedSize;
  net.outputs{i}.processedRange = nnet.array.safeGather(minmax(t));
  
  % Layer
  if nargin < 4
    dimensions = newProcessedSize;
  end
  net = iConfigureLayer(net,i,newProcessedSize,dimensions,t,layerFlag);
end

function [net,t] = iConfigureProcessingFunctions(net,i,t)
  numProcess = length(net.outputs{i}.processFcns);
  net.outputs{i}.processSettings = cell(1,numProcess);
  for j=1:numProcess
    processFcns = net.outputs{i}.processFcns{j};
    processParams = net.outputs{i}.processParams{j};
    [t,config] = feval(processFcns,t,processParams);
    net.outputs{i}.processSettings{j} = config;
  end
end

function net = iConfigureLayer(net,i,newProcessedSize,dimensions,t,layerFlag)
  oldLayerSize = net.layers{i}.size;
  oldLayerDim = net.layers{i}.dimensions;
  if ~layerFlag && ((oldLayerSize ~= newProcessedSize) || ((nargin>3) && any(oldLayerDim ~= dimensions)))

    % If transfer function is SOFTMAX and layer is size 1
    % Then convert SOFTMAX to LOGSIG (because SOFTMAX won't work)
    if strcmp(net.layers{i}.transferFcn,'softmax') && (size(t,1)==1)
      net.layers{i}.transferFcn = 'logsig';
    end

    net = nnet.internal.configure.layer(net,i,dimensions,true);
  end
end
