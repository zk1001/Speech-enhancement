function a = apply(n,param)
%TANSIG2.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  a = 2*param.beta ./ (param.beta + exp(-2*n*param.alpha)) - 1;
end
