function [archNet,tr] = trainNetwork(archNet,rawData,calcLib,calcNet,tr,localFcns)

% Copyright 2010-2014 The MathWorks, Inc.

localFcns = fcns2struct(localFcns);
isParallel = isa(calcLib,'Composite');
feedback = nnet.train.defaultFeedbackHandler;

% Ensure warnings return to original state
ws = warning;
warningCleaner = onCleanup( @() warning(ws) );

if isParallel
    [archNet,tr] = trainNetworkOnSPMDWorkers(archNet,rawData,calcLib,calcNet,tr,feedback,localFcns);
else
    [archNet,tr] = trainNetworkInMainThread(archNet,rawData,calcLib,calcNet,tr,feedback,localFcns);
end
end

function [archNet,tr] = trainNetworkInMainThread(archNet,rawData,calcLib,calcNet,tr,feedback,localFcns)

% INITIALIZE TRAINING

% Avoid NullPointer warnings in GPU calls
warning('off','parallel:gpu:kernel:NullPointer');

% Setup training algorithm context on main thread
worker = localFcns.initializeTraining(archNet,calcLib,calcNet,tr);

% Initialize feedback
feedback.start(false,rawData,archNet,worker.tr,calcLib.options,worker.status);

% TRAINING LOOP

while (true)
    [worker,calcNet] = localFcns.updateTrainingState(worker,calcNet);
    stop = ~isempty(worker.tr.stop);
    feedback.update(archNet,worker.tr, ...
        calcLib.options,rawData,calcLib,calcNet,worker.best.net,worker.status,worker.statusValues);
    
    % Stop
    if stop
        % Return original architecture with trained weights and bias values
        WB = calcLib.getwb(calcNet);
        archNet = setwb(archNet,WB);
        % Return training record
        tr = worker.tr;
        break
    end
    
    % Training iteration
    worker.epoch = worker.epoch + 1;
    [worker,calcNet] = localFcns.trainingIteration(worker,calcLib,calcNet);
end
end

function [archNet,tr] = trainNetworkOnSPMDWorkers(archNet,rawData,calcLib,calcNet,tr,feedback,localFcns)

% IMPLEMENTATION NOTES:
%
% This function performs identical calculations as the above
% trainNetworkInMainThread, except that its use of SPMD parallelism
% results in some additional complexity.
%
% - Training initialization occurs in an SPMD block
% - The training loop has two levels: an outer MATLAB loop, with an
%   an inner SPMD loop. The more iterations that occur within the SPMD
%   loop, the more efficient training is.
% - State checks, most feedback and training iterations occur in the
%   inner SPMD loop.
% - Because not all feedback can occur in an SPMD block (i.e. nntraintool
%   and checkpoint saves), the SPMD-loop periodically breaks to allow
%   the outside-SPMD block to handle that feedback, then resumes.
%
% This dual loop (an inner-SPMD loop inside the main training loop)
% requires values to be copied to and from the main worker as the
% inner-SPMD loop is entered and exited.
%
% While not required by SPMD, all values shared across SPMD workers
% are explicitly placed into Composites.  This convention helps analyze
% the code more easily, as all passing of values into and out of SPMD
% blocks are done in a consistent explicit manner.
%
% Where a variable is used both on the main SPMD thread and the regular
% MATLAB, the two versions use the naming convention "varC" and "var"
% for Composite and non-Composite versions.

% INITIALIZE TRAINING

localFcnsC = copyAcrossComposite(localFcns);
spmd
    % Avoid NullPointer warnings in GPU calls
    warning('off','parallel:gpu:kernel:NullPointer');
    
    % Get index of main worker from calcLib object.
    mainWorkerIndC = calcLib.mainWorkerInd;
    
    % Initialize training algorithm on all workers
    workerC = localFcnsC.initializeTraining(archNet,calcLib,calcNet,tr);
    
    % stateUpdateNeeded is used to ensure state updates occur exactly once,
    % and only once, before each training iteration.
    % - Initially stateUpdateNeeded is set to true.
    % - It is set to false after each state update.
    % - It is set to true after each training iteration.
    stateUpdateNeeded = true;
    
    % Save values from main worker needed outside SPMD
    if calcLib.isMainWorker
        mainC.tr = workerC.tr;
        mainC.options = calcLib.options;
        mainC.status = workerC.status;
    end
end

% Initialize feedback (using values got from main worker)
mainWorkerInd = mainWorkerIndC{1};
main = mainC{mainWorkerInd};
feedback.start(true,rawData,archNet,main.tr,main.options,main.status);

% TRAINING LOOP

% Outer training loop
feedbackC = Composite;
userStopC = copyAcrossComposite(false);
userCancelC = copyAcrossComposite(false);
while (true)
    
    % Copy feedback and user stop/cancel states to main worker
    feedbackC{mainWorkerInd} = feedback;
    [userStop,userCancel] = nntraintool('check');
    userStopC{mainWorkerInd} = userStop;
    userCancelC{mainWorkerInd} =  userCancel;
    
    % Inner SPMD loop
    % Continues until training stops or outside-SPMD feedback is needed
    spmd
        spmdStop = false;
        while (true)
            
            % Training State
            if stateUpdateNeeded
                if calcLib.isMainWorker
                    nntraintool('setStopCancel',userStopC,userCancelC);
                    [workerC,calcNet] = localFcnsC.updateTrainingState(workerC,calcNet);
                    workerC.outsideFeedbackNeeded = feedbackC.updateInsideSPMD( ...
                        archNet,workerC.tr,calcLib.options,[],calcLib,calcNet,workerC.best.net,workerC.status,workerC.statusValues);
                    workerC.stop = ~isempty(workerC.tr.stop);
                    spmdStop = workerC.stop || workerC.outsideFeedbackNeeded;
                end
                stateUpdateNeeded = false; %#ok<NASGU>
                
                % Exit SPMD loop for training stop or outside-SPMD feedback
                if (labBroadcast(calcLib.mainWorkerInd,spmdStop))
                    break;
                end
            end
            
            % Training Iteration
            if calcLib.isMainWorker,
                workerC.epoch = workerC.epoch + 1;
            end
            [workerC,calcNet] = localFcnsC.trainingIteration(workerC,calcLib,calcNet);
            stateUpdateNeeded = true;
        end
        
        % Save values from main worker needed outside SPMD
        if calcLib.isMainWorker
            mainC.stop = ~isempty(workerC.tr.stop);
            mainC.epoch = workerC.epoch;
            mainC.tr = workerC.tr;
            mainC.options = calcLib.options;
            mainC.best.net = workerC.best.net;
            mainC.status = workerC.status;
            mainC.statusValues = workerC.statusValues;
            mainC.WB = workerC.WB;
        end
    end
    
    % Update feedback (using values got from main worker)
    main = mainC{mainWorkerInd};
    feedback = feedbackC{mainWorkerInd};
    feedback.updateOutsideSPMD(archNet,main.tr, ...
        main.options,rawData,[],[],main.best.net,main.status,main.statusValues);
    
    % Stop
    if main.stop
        % Return original architecture with trained weights and bias values
        spmd, WB = calcLib.getwb(calcNet); end
        archNet = setwb(archNet,WB{1});
        % Return training record
        tr = main.tr;
        break
    end
end
end

function c = copyAcrossComposite(x)
c = Composite();
c(:) = {x};
end

function s = fcns2struct(f)
s = struct;
for i=1:numel(f)
    fi = f{i};
    s.(func2str(fi)) = fi;
end
end
