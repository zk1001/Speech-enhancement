function settings = updateSettings(settings)

% NNT 7.0 Backward Compatibility
if ~isfield(settings,'xoffset')
  settings = struct(settings);
  settings.xoffset = settings.xmin;
  settings.gain = settings.yrange ./ settings.xrange;
  
  fix = find((abs(settings.gain)>1e14) | ~isfinite(settings.xrange) | (settings.xrange == 0));
  settings.gain(fix) = 1;
  settings.xoffset(fix) = settings.ymin;
end
