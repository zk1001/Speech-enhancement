function x = perc_out(x,net)
%NN_PERCENT_OUTPUTS

% Copyright 2007-2010 The MathWorks, Inc.

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
    % TODO - Vectorize?
    xij = x{xi}(j,:);
    rMin = range(j,1);
    rMax = range(j,2);
    multiplier = 1 / (rMax - rMin);
    offset = (rMax + rMin) / 2;
    x{xi}(j,:) = (xij - offset) * multiplier;
  end
end
