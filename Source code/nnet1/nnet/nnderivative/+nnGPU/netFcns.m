function fcns = netFcns

% Copyright 2012-2015 The MathWorks, Inc.

fcns.inputProcessFcns = {
  %'fixunknowns'
  'mapminmax'
  %'mapstd'
  %'processpca'
  %'removeconstantrows'
  %'removerows'
  };

fcns.weightFcns = {
  %'convwf'
  'dotprod'
  %'negdist'
  %'normprod'
  %'scalprod'
  %'nntest.dotprod2'
  %'nntest.dotprod3'
  };

fcns.netInputFcns = {
  %'netprod'
  'netsum'
  %'nntest.netsum2'
  };

fcns.transferFcns = {
  %'compet'
  'hardlim'
  'hardlims'
  'logsig'
  'netinv'
  'poslin'
  'purelin'
  'radbas'
  %'radbasn'
  'satlin'
  'satlins'
  %'softmax'
  'tansig'
  'tribas'
  'elliotsig'
  'elliot2sig'
  };

fcns.outputProcessFcns = {
  %'lvqoutputs'
  'mapminmax'
  %'mapstd'
  %'processpca'
  %'removeconstantrows'
  %'removerows'
  };

fcns.performFcns = {
  'mae'
  'mse'
  'sae'
  'sse'
  'crossentropy'
  'msesparse'
  };
