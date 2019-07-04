function settings = updateSettings(settings)

% NNT 7.0 Backward Compatibility
if ~isfield(settings,'xoffset')
  settings = struct(settings);
  settings.xoffset = settings.xmean;
  settings.gain = settings.ystd ./ settings.xstd;
  
  fix = find((abs(settings.gain)>1e14) | ~isfinite(settings.xmean) ...
    | ~isfinite(settings.xstd) | (settings.xstd == 0));
  settings.xoffset(fix) = settings.ymean;
  settings.gain(fix) = 1;
end
