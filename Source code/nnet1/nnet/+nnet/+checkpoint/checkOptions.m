function err = checkOptions(options)
%NNET.CHECKPOINT.CHECKOPTIONS Checks that checkpoint training options are
% valid
%
% err = checkOptions(options) takes a structure with these fields:
%
%   checkpoint.CheckpointFile, file name and/or path for checkpoint saves.
%   checkpoint.CheckpointDelay, minimum delay between saves.
%
% It returns either an empty string or and error message string.

% Copyright 2013-2015 The MathWorks, Inc.

% Check CheckpointFile option
if ~isempty(options.CheckpointFile)
  err = nntype.string('check',options.CheckpointFile);
  if ~isempty(err)
    err = strrep(err,'VALUE','Option ''CheckpointVariable''');
    return
  end
  [place,~,ext] = fileparts(options.CheckpointFile);
  if ~isempty(place)
    if ~exist(place,'dir')
      err = ['Checkpoint directory does not exist: ' place];
      return;
    end
  end
  if ~isempty(ext)
    if ~strcmp(ext,'.mat')
      err = ['Checkpoint file does not have ''.mat'' extension: ' ext];
      return
    end
  end
end

% Check CheckpointTime option
if ~isempty(options.CheckpointDelay)
  err = nntype.strict_pos_int_scalar('check',options.CheckpointDelay);
  if ~isempty(err)
    err = strrep(err,'VALUE','Option ''CheckpointTime''');
    return
  end
end

err = '';
