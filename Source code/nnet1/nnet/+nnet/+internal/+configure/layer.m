function net = layer(net,i,dimensions,outputFlag)
%NNET.INTERNAL.CONFIGURE.LAYER

% Copyright 2010-2015 The MathWorks, Inc.

  if nargin < 4, outputFlag = false; end

  % Calculate new sizes
  newSize = prod(dimensions);
  oldSize = net.layers{i}.size;
  sizeChange = newSize ~= oldSize;
  range = repmat(feval(net.layers{i}.transferFcn,'outputRange'),newSize,1);

  % Set size properties
  net.layers{i}.size = newSize;
  net.layers{i}.range = range;
  net.layers{i}.dimensions = dimensions;

  % Configure network elements to match new sizes
  net = iConfigureOutput(net,i,range,dimensions,sizeChange,outputFlag);
  net = iConfigureNetworkTopologyValues(net,i);
  net = iConfigureFollowingLayerWeights(net,i,range);
  net = iConfigureBias(net,i);
  net = iConfigurePreceedingInputWeights(net,i,range);
  net = iConfigurePreceedingLayerWeights(net,i,range);
end

function net = iConfigureOutput(net,i,range,dimensions,sizeChange,outputFlag)
  if ~outputFlag && net.outputConnect(i) && sizeChange
    net = nnet.internal.configure.output(net,i,range,dimensions,false);
  end
end

function net = iConfigureNetworkTopologyValues(net,i)
  if isempty(net.layers{i}.topologyFcn)
    net.layers{i}.positions = [];
    net.layers{i}.distances = [];
  else
    net.layers{i}.positions = feval(net.layers{i}.topologyFcn,...
      net.layers{i}.dimensions);
    if isempty(net.layers{i}.distanceFcn)
      net.layers{i}.distances = [];
    else
      net.layers{i}.distances = feval(net.layers{i}.distanceFcn,net.layers{i}.positions);
    end
  end
end

function net = iConfigureFollowingLayerWeights(net,i,range)
  for j=find(net.layerConnect(:,i))'
    net = nnet.internal.configure.layerWeight(net,j,i,range);
  end
end

function net = iConfigureBias(net,i)
  if net.biasConnect(i)
    net.biases{i}.size = net.layers{i}.size;
    if size(net.b{i},1) ~= net.layers{i}.size
      net.b{i} = zeros(net.biases{i}.size,1);
    end
  end
end

function net = iConfigurePreceedingInputWeights(net,i,range)
  for j = find(net.inputConnect(i,:))
    net = nnet.internal.configure.inputWeight(net,i,j,range);
  end
end

function net = iConfigurePreceedingLayerWeights(net,i,range)
  for j = find(net.layerConnect(i,:))
    net = nnet.internal.configure.layerWeight(net,i,j,range);
  end
end