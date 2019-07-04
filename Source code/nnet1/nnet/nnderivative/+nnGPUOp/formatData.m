function data = formatData(data,hints)

% Copyright 2012 The MathWorks, Inc.

for i=1:numel(data.X)
  data.X{i} = gpuArray(data.X{i});
end

for i=1:numel(data.Xi)
  data.Xi{i} = gpuArray(data.Xi{i});
end

for i=1:numel(data.Pc)
  data.Pc{i} = gpuArray(data.Pc{i});
end

data.Pt = cell(size(data.Pc));
for i=1:numel(data.Pt)
  data.Pt{i} = data.Pc{i}';
end

for i=1:numel(data.Pd)
  data.Pd{i} = gpuArray(data.Pd{i});
end

for i=1:numel(data.Ai)
  data.Ai{i} = gpuArray(data.Ai{i});
end

if isfield(data,'T')
  for i=1:numel(data.T)
    data.T{i} = gpuArray(data.T{i});
  end
end

if isfield(data,'EW')
  for i=1:numel(data.EW)
    data.EW{i} = gpuArray(data.EW{i});
  end
end

if isfield(data,'train')
  for i=1:numel(data.train.mask)
    data.train.mask{i} = gpuArray(data.train.mask{i});
  end
end

if isfield(data,'val')
  for i=1:numel(data.train.mask)
    data.val.mask{i} = gpuArray(data.val.mask{i});
  end
end

if isfield(data,'test')
  for i=1:numel(data.train.mask)
    data.test.mask{i} = gpuArray(data.test.mask{i});
  end
end

