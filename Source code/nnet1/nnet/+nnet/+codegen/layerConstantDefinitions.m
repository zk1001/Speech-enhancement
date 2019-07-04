function code = layerConstantDefinitions(net,i,prefix)

% Copyright 2012-2015 The MathWorks, Inc.

import nnet.codegen.*;

if nargin < 3, prefix = ''; end
code = {};
if net.biasConnect(i)
  code{end+1} = [prefix biasName(i) ' = ' mat2str(net.b{i},20) ';'];
end
for j=1:net.numInputs
  if net.inputConnect(i,j)
    code{end+1} = [prefix inputWeightName(i,j) ' = ' mat2str(net.IW{i,j},20) ';'];
  end
end
for j=1:net.numLayers
  if net.layerConnect(i,j)
    code{end+1} = [prefix layerWeightName(i,j) ' = ' mat2str(net.LW{i,j},20) ';'];
  end
end
