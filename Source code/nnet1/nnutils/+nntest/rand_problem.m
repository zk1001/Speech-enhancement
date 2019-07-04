function [net,x,xi,ai,t,ew,masks,seed] = rand_problem(net,seed)
%RAND_PROBLEM Random network/data problem
%
% Recommended syntax:
%
%   [net,x,xi,ai,t,ew,masks,seed] = nntest.rand_problem(seed)
%
% This returns the network and problem generated with nntest.rand_net,
% nntest.rand_problem and training, validation and test masks.
%
% Alternately a different network from nntest.rand_net(seed) can be
% be used to help with debugging problems.
%
%   [net,x,xi,ai,t,ew,masks,seed] = rand_problem(net,seed)

% Copyright 2010-2013 The MathWorks, Inc.

if nargin < 1, error(message('nnet:Args:NotEnough')); end

% Seed & Network
if (nargin == 1)
  seed = net;
  net = nntest.rand_net(seed);
end

% Data
[x,t,ew] = nntest.rand_data(seed);

% Configure
net = configure(net,x,t);

% Prepare Data
[x,xi,ai,t,ew] = preparets(net,x,t,{},ew);
if rand < 0.01
  for i=1:numel(ai)
    ind = find(~isfinite(ai{i}));
    ai{i}(ind) = rands(1,numel(ind));
  end
end

% Masks
[S,Q,TS] = nnsize(t);
[trainMask,valMask,testMask] = nntest.randMasks(S,Q,TS);
masks = {trainMask, valMask, testMask};
