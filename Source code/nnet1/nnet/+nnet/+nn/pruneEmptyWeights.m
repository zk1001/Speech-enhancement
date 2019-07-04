function net = pruneEmptyWeights(net)
% Remove empty weights from network structure, leaves numLayerDelays alone

for i=1:net.numLayers
  if net.biasConnect(i) && isempty(net.b{i});
    net.biasConnect(i) = false;
    net.biases{i} = [];
    net.b{i} = [];
  end
  for j=1:net.numInputs
    if net.inputConnect(i,j) && isempty(net.IW{i,j})
      net.inputConnect(i,j) = false;
      net.inputWeights{i,j} = [];
      net.IW{i,j} = [];
    end
  end
  for j=1:net.numLayers
    if net.layerConnect(i,j) && isempty(net.LW{i,j})
      net.layerConnect(i,j) = false;
      net.layerWeights{i,j} = [];
      net.LW{i,j} = [];
    end
  end
end
