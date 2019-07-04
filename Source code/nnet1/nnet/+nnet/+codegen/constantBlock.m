function code = constantBlock(net)

% Copyright 2012-2015 The MathWorks, Inc.

import nnet.codegen.*;
blocks = {};
for i=1:net.numInputs
  block = inputConstantDefinitions(net,i);
  block = encloseText(['% Input ' num2str(i)],block,{},true);
  blocks{end+1} = block;
end
for i=1:net.numLayers
  block = layerConstantDefinitions(net,i);
  block = encloseText(['% Layer ' num2str(i)],block,{},true);
  blocks{end+1} = block;
end
for i=1:net.numOutputs
  block = outputConstantDefinitions(net,i);
  block = encloseText(['% Output ' num2str(i)],block,{},true);
  blocks{end+1} = block;
end
code = combineTextBlocks(blocks);
