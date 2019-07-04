function [y,settings] = create(x,param)
%REMOVECONSTANTROWS.CREATE Create settings for processing values

% Copyright 2012-2015 The MathWorks, Inc.

  % Get info from X which may be MATLAB array or gpuArray
  R = size(x,1);
  settings.max_range = param.max_range;
  settings.keep = 1:R;
  if isempty(x)
    minx=nan(size(x,1),1);
    maxx=nan(size(x,1),1);
  else
    minx = nnet.array.safeGather(min(x,[],2));
    maxx = nnet.array.safeGather(max(x,[],2));
  end
  rangex = (maxx - minx);
  midx = (maxx + minx) / 2;
  rowsWithRangesTooSmall = (rangex <= settings.max_range)';
  settings.remove = find(rowsWithRangesTooSmall);
  settings.keep(settings.remove) = [];
  settings.value = midx(settings.remove,:);
  settings.xrows = R;
  settings.yrows = settings.xrows - length(settings.remove);
  settings.constants = settings.value;
  
  % Check whether processing has any effect
  settings.no_change = isempty(settings.remove);

  % Apply
  y = removeconstantrows.apply(x,settings);
end
