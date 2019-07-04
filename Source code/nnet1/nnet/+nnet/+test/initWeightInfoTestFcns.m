function info = initWeightInfoTestFcns

% Copyright 2013-2015 The MathWorks, Inc.

if nnet.test.flags('initWeightInfoTestEnableAll')
  info = nnfcnWeightInit('testing','Testing',7.0,...
    true,true,true, true,true,true,true,true);
else
  info = nnfcnWeightInit('testing','Testing',7.0,...
    false,false,false, false,false,false,false,false);
end
  
  
end