function wb = getwb(net,hints)

% Copyright 2012 The MathWorks, Inc.

wb  = zeros(hints.learnWB.wbLen,1);

for i=1:hints.numLayers
  if hints.learnWB.bInclude(i)
    wb(hints.learnWB.bInd{i}) = gather(net.b{i});
  end
  for j=1:hints.numInputs
    if hints.learnWB.iwInclude(i,j)
      wb(hints.learnWB.iwInd{i,j}) = gather(net.IW{i,j});
    end
  end
  for j=1:hints.numLayers
    if hints.learnWB.lwInclude(i,j)
      wb(hints.learnWB.lwInd{i,j}) = gather(net.LW{i,j});
    end
  end
end

