function fcns = outputProcessingFcns(net)

% Copyright 2012-2015 The MathWorks, Inc.

fcns = {};
for i=1:net.numLayers
  if net.outputConnect(i)
    fcns = [fcns net.outputs{i}.processFcns];
  end
end
fcns = unique(fcns);
