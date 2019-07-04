function [best,tr,val_fail] = trackBestNetwork(best,tr,val_fail,net,perf,vperf,epoch)

% Copyright 2010-2014 The MathWorks, Inc.

validationDataExists = ~isempty(tr.valInd);
if validationDataExists
    [best,tr,val_fail] = trackByValidationPerformance(best,tr,val_fail,net,perf,vperf,epoch);
else
    [best,tr] = trackByTrainingPerformance(best,tr,net,perf,epoch);
end
end

function [best,tr,val_fail] = trackByValidationPerformance(best,tr,val_fail,net,perf,vperf,epoch)

% If validation performance improves, update best network
% and clear validation failure count.
if (vperf < best.vperf)
    best.net = net;
    best.vperf = vperf;
    tr.best_epoch = epoch;
    val_fail = 0;
    
    % If validation performance got worse, increase failure count.
elseif (vperf > best.vperf)
    val_fail = val_fail + 1;
end

% If performance improved, update best performance
if (perf < best.perf)
    best.perf = perf;
end
end

function [best,tr] = trackByTrainingPerformance(best,tr,net,perf,epoch)

% Use regular performance to track best network
if (perf < best.perf)
    best.net = net;
    best.perf = perf;
    tr.best_epoch = epoch;
end
end
