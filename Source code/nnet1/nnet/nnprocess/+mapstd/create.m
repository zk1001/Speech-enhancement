function [y,settings] = create(x,param)
%MAPSTD.CREATE Create settings for processing values

% Copyright 2012-2015 The MathWorks, Inc.
  
  % Get info from X which may be MATLAB array or gpuArray
  xrows = size(x,1);
  settings.xmean = zeros(xrows,1);
  settings.xstd = zeros(xrows,1);
  for i=1:xrows
    xi = nnet.array.safeGather(x(i,:));
    xi = xi(isfinite(xi));
    if isempty(xi)
      xi_mean = 0;
      xi_std = 1;
    else
      xi_mean = mean(xi,2);
      xi_std = std(xi,0,2);
    end
    settings.xmean(i) = xi_mean;
    settings.xstd(i) = xi_std;
  end
  
  % Assert: xstd & xmean will be NaN for infinite or unknown ranges
  settings.xrows = xrows;
  settings.yrows = xrows;
  settings.ymean = param.ymean;
  settings.ystd = param.ystd;

  % Convert from settings values to safe processing values
  % and check whether safe values result in x<->y change.
  xoffset = settings.xmean;
  xstd = settings.xstd;
  gain = settings.ystd ./ xstd;
  fix = find((abs(gain)>1e14) | ~isfinite(settings.xmean) | ~isfinite(settings.xstd) | (settings.xstd == 0));
  gain(fix) = 1;
  xoffset(fix) = settings.ymean;
  settings.gain = gain;
  settings.xoffset = xoffset;

  % Check whether processing has any effect
  settings.no_change = (settings.xrows == 0) || ...
    all(gain == 1) && all(xoffset == settings.ymean);

  % Apply
  y = mapstd.apply(x,settings);
end
