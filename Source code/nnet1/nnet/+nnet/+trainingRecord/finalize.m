function tr = finalize(tr)

% Copyright 2013-2015 The MathWorks, Inc.

% Clip buffers off end of state records
stateNames = tr.states;
len = tr.num_epochs+1;
ind = 1:len;
tr.epoch = tr.epoch(ind);
for i=1:length(stateNames)
  stateName = stateNames{i};
  tr.(stateName) = tr.(stateName)(ind);
end

% Set best performances
if isfield(tr,'best_epoch')
  if isfield(tr,'perf')
    tr.best_perf = tr.perf(tr.best_epoch+1);
  end
  if isfield(tr,'vperf')
    tr.best_vperf = tr.vperf(tr.best_epoch+1);
  end
  if isfield(tr,'tperf')
    tr.best_tperf = tr.tperf(tr.best_epoch+1);
  end
end