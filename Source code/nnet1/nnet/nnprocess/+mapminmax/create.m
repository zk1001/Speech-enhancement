function [y,settings] = create(x,param)
%MAPMINMAX.CREATE Create settings for processing values

% Copyright 2012-2015 The MathWorks, Inc.

  % Get info from X which may be MATLAB array or gpuArray
  xrows = size(x,1);
  if isempty(x)
    xmin = nan(xrows,1);
    xmax = nan(xrows,1);
  else
    xmin = nnet.array.safeGather(min(x,[],2));
    xmax = nnet.array.safeGather(max(x,[],2));
  end
  
  % xmin and xmax will be [-inf inf] for unknown ranges
  xmin(isnan(xmin)) = -inf;
  xmax(isnan(xmax)) = inf;

  settings.name = 'mapminmax';
  settings.xrows = xrows;
  settings.xmax = xmax;
  settings.xmin = xmin;
  settings.xrange = xmax - xmin;
  settings.yrows = settings.xrows;
  settings.ymax = param.ymax;
  settings.ymin = param.ymin;
  settings.yrange = settings.ymax - settings.ymin;

  % Convert from settings values to safe processing values
  xoffset = settings.xmin;
  gain = settings.yrange ./ settings.xrange;
  fix = find((abs(gain)>1e14) | ~isfinite(settings.xrange) | (settings.xrange == 0));
  gain(fix) = 1;
  xoffset(fix) = settings.ymin;
  settings.gain = gain;
  settings.xoffset = xoffset;

  % Check whether processing has any effect
  settings.no_change = (settings.xrows == 0) || ...
    (all(gain == 1) && all(xmin == 0));

  % Apply
  y = mapminmax.apply(x,settings);
end
