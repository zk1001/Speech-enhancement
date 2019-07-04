function [y,settings] = create(x,param)
%REMOVEROWS.CREATE Create settings for processing values

% Copyright 2012-2015 The MathWorks, Inc.

  % Check parameters
  R = size(x,1);
  if  any(param.ind > R)
    error(message('nnet:NNData:XRowIndexTooLarge'));
  end

  % Settings
  settings.name = 'removerows';
  settings.xrows = R;
  settings.yrows = R-length(param.ind);
  settings.remove_ind = param.ind;
  settings.keep_ind = 1:R;
  settings.keep_ind(settings.remove_ind) = [];
  
  % Check whether processing has any effect
  settings.no_change = isempty(settings.remove_ind);

  % Apply
  y = removerows.apply(x,settings);
end
