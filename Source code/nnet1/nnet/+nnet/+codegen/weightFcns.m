function fcns = weightFcns(net,netInputFcn)

% Copyright 2012-2015 The MathWorks, Inc.

if nargin < 2, netInputFcn = ''; end

fcns = {};
for i=1:net.numLayers
  if isempty(netInputFcn) || strcmp(net.layers{i}.netInputFcn,netInputFcn)
    for j=1:net.numInputs
      if net.inputConnect(i,j)
        fcns{end+1} = net.inputWeights{i,j}.weightFcn;
      end
    end
    for j=1:net.numLayers
      if net.layerConnect(i,j)
        fcns{end+1} = net.layerWeights{i,j}.weightFcn;
      end
    end
  end
end
fcns = unique(fcns);
