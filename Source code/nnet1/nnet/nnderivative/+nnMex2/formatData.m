function data = formatData(data1,hints)

% Simulation Data
data.X = double(cell2mat(data1.X));
data.Xi = double(cell2mat(data1.Xi));
data.Pc = double(cell2mat(data1.Pc));
data.Pd = [];
data.Ai = double(cell2mat(data1.Ai));

data.Q = data1.Q;
data.TS = data1.TS;

% Performance Data
if isfield(data1,'T')
  data.T = double(cell2mat(data1.T));
  data.EW = double(cell2mat(data1.EW));
  if isfield (data1,'train')
    data.masks = double(cell2mat([data1.train.mask data1.val.mask data1.test.mask]));
    data.trainMask = double(cell2mat(data1.train.mask));
  end
end
