function flag = isInputDelayed(net,i)

% Copyright 2012-2015 The MathWorks, Inc.

for j=1:net.numLayers
  if net.inputConnect(j,i)
    if any(net.inputWeights{j,i}.delays > 0)
      flag = true;
      return
    end
  end
end
flag = false;
