function fcns = netInputFcns(net)

% Copyright 2012-2015 The MathWorks, Inc.

fcns = {};
for i=1:net.numLayers
  fcns{end+1} = net.layers{i}.netInputFcn;
end
fcns = unique(fcns);
