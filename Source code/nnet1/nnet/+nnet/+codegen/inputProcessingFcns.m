function fcns = inputProcessingFcns(net)

% Copyright 2012-2015 The MathWorks, Inc.

fcns = {};
for i=1:net.numInputs
  fcns = [fcns net.inputs{i}.processFcns];
end
fcns = unique(fcns);
  