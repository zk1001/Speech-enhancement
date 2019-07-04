function net = setwb(net,wb,hints)

% Copyright 2012 The MathWorks, Inc.

wb = gpuArray(wb);

for i=1:hints.numLayers
  layerSize = net.layers{i}.size;
  if hints.learnWB.bInclude(i)
    net.b{i} = reshape(wb(hints.learnWB.bInd{i}),layerSize,1);
  end
  for j=1:hints.numInputs
    if hints.learnWB.iwInclude(i,j)
      net.IW{i,j} = reshape(wb(hints.learnWB.iwInd{i,j}),layerSize,[]);
    end
  end
  for j=1:hints.numLayers
    if hints.learnWB.lwInclude(i,j)
      net.LW{i,j} = reshape(wb(hints.learnWB.lwInd{i,j}),layerSize,[]);
    end
  end
end
