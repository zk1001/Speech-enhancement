function [y,settings] = create(x,param)
%LVQOUTPUT.CREATE Create settings for processing values

% Copyright 2012-2015 The MathWorks, Inc.

  % Get info from X which may be MATLAB array or gpuArray
  % The class ratios are used by INITLVQ.
  settings.no_change = true;
  settings.xrows = size(x,1);
  settings.yrows = size(x,1);
  settings.classRatios = nnet.array.safeGather(sum(compet(x),2));

  y = x;
end
