function checkpointFile = expandFile(checkpointFile)

% Copyright 2013-2015 The MathWorks, Inc.

if ~isempty(checkpointFile)
  [place,name,ext] = fileparts(checkpointFile);
  if isempty(place), place = pwd; end
  if isempty(name), name = 'CheckpointFile'; end
  if isempty(ext), ext = '.mat'; end
  checkpointFile = fullfile(place,[name ext]);
end