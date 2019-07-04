function net = weedProcessSteps(net)
% weedProcessSteps   Remove processing steps that result in no changes

% Copyright 2012-2015 The MathWorks, Inc.

for i=1:net.numInputs
  for j=numel(net.inputs{i}.processFcns):-1:1
    if net.inputs{i}.processSettings{j}.no_change
      net.inputs{i}.processFcns(j) = [];
      net.inputs{i}.processParams(j) = [];
      net.inputs{i}.processSettings(j) = [];
    end
  end
end

for i=1:net.numLayers
  if net.outputConnect(i)
    for j=numel(net.outputs{i}.processFcns):-1:1
      if net.outputs{i}.processSettings{j}.no_change
        net.outputs{i}.processFcns(j) = [];
        net.outputs{i}.processParams(j) = [];
        net.outputs{i}.processSettings(j) = [];
      end
    end
  end
end
