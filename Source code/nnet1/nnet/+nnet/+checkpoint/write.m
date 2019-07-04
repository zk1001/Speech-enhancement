function [CheckpointTime,CheckpointCount] = write(archNet,calcLib,bestCalcNet,tr,options,CheckpointTime,CheckpointCount)

% Copyright 2013-2015 The MathWorks, Inc.

[place,name] = fileparts(options.CheckpointFile);

% (-- Testing Support: Intentional Error in Training at Epoch 3 --)
if (tr.num_epochs == 3) && nnet.test.flags('CheckpointTrainFailAtEpoch3')
  error('nnet:test:CheckpointTrainFailAtEpoch3','Intentional training error at epoch 3.');
end

% (-- Testing Support: Intentional Delay of 2 seconds per epoch --)
if nnet.test.flags('DelayTrainEpoch2Seconds')
  pause(2);
end

newTime = clock;
if isempty(options.CheckpointFile)
  return;
elseif (tr.num_epochs == 0)
  stage = 'First';
elseif ~isempty(tr.stop)
  stage = 'Final';
elseif etime(newTime,CheckpointTime) > options.CheckpointDelay
  stage = 'Write';
else
  return;
end

% Initialize/Update Checkpoint Time and Count
CheckpointTime = newTime;
if strcmp(stage,'First')
  CheckpointCount = 1;
else
  CheckpointCount = CheckpointCount + 1;
end

% Confirm Checkpoint at Command Line
t = datestr(CheckpointTime);
n = num2str(CheckpointCount);
disp([t ' ' stage ' Checkpoint #' n ': ' options.CheckpointFile]);

% Update architectural net (Network object) from calcNet weights and biases
net = network(archNet);
if ~isempty(calcLib)
  wb = calcLib.getwb(bestCalcNet);
  archNet = setwb(net,wb);
end

% Checkpoint Data
checkpoint.file = options.CheckpointFile;
checkpoint.time = CheckpointTime;
checkpoint.number = CheckpointCount;
checkpoint.stage = stage;
checkpoint.net = archNet;
checkpoint.tr = nnet.trainingRecord.finalize(tr); %#ok<STRNU>


% Save to CheckpointFile using cache for failure
% protection during file writes.
CacheFile = fullfile(place,[name '_TempCache.mat']);


try
  
  % (-- Testing Support: Intentional Error during Save At Epoch 0 --)
  if (tr.num_epochs == 0) && nnet.test.flags('CheckpointWriteFailAtEpoch0')
    error('nnet:test:CheckpointWriteFailAtEpoch0','Intentional checkpoint write failure at epoch 0.');
  end
  
  % (-- Testing Support: Intentional Error during Save after Epoch 3 --)
  if (tr.num_epochs >= 3) && nnet.test.flags('CheckpointWriteFailAfterEpoch3')
    error('nnet:test:CheckpointWriteFailAfterEpoch3','Intentional checkpoint write failure after epoch 3.');
  end
  
  % First save to CacheFile
  save(CacheFile,'checkpoint');
  
  % Them rename CacheFile to Checkpoint file
  movefile(CacheFile,options.CheckpointFile,'f');
  
catch err
  
  % Failure on first epoch ==> Error
  if strcmp(stage,'First')
    disp('*** Checkpoint Failure: Cannot Create File! ***')
    rethrow(err)
    
  % Failure on subsequent epochs ==> Warning
  else
    disp('*** Checkpoint Warning: Cannot Update File! ***')
    warning(err.identifier,err.message)
  end
end
