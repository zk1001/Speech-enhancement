function x = norm_deriv(x,net)

% Copyright 2007-2012 The MathWorks, Inc.

isMatrix = ~iscell(x);
if isMatrix, x = {x}; end

outputInd = find(net.outputConnect);
numOutputs = length(outputInd);
if size(x,1) == numOutputs
  xInd = 1:numOutputs;
else
  xInd = outputInd;
end

for ii = 1:numOutputs
  i = outputInd(ii);
  xi = xInd(ii);
  range = net.outputs{i}.range;
  for j=1:size(range,1)
    xij = x{xi}(j,:);
    rMin = range(j,1);
    rMax = range(j,2);
    multiplier = 2 / (rMax - rMin);
    x{xi}(j,:) = xij * multiplier;
  end
end

if isMatrix, x = x{1}; end
