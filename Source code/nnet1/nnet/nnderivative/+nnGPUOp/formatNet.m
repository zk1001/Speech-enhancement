function net = formatNet(net,hints)

% Copyright 2012 The MathWorks, Inc.

net = nnet.codegen.weedProcessSteps(net);

for i=1:net.numLayers
  if net.biasConnect(i)
    net.b{i} = gpuArray(net.b{i});
  end
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      net.IW{i,j} = gpuArray(net.IW{i,j});
    end
  end
  for j=1:net.numLayers
    if net.layerConnect(i,j)
      net.LW{i,j} = gpuArray(net.LW{i,j});
    end
  end
end

% Outputs
for i=1:net.numLayers
  if net.outputConnect(i)
    
    % Process Settings
    numFcns = numel(net.outputs{i}.processFcns);
    for j=1:numFcns
      % Only MAPMINMAX supported
      settings = net.outputs{i}.processSettings{j};
      net.outputs{i}.processSettings{j}.onGPU = { ...
        gpuArray(settings.xoffset), ...
        gpuArray(settings.gain), ...
        gpuArray(settings.ymin)};
    end
    
    % Normalization
    if isempty(net.performFcn) || ~isfield(net.performParam,'normalization')
      errNorm = 1;
    else
      switch (net.performParam.normalization)
        case 'standard'
          errNorm = 2 ./ (net.outputs{i}.range(:,2)-net.outputs{i}.range(:,1));
        case 'percent'
          errNorm = 1 ./ (net.outputs{i}.range(:,2)-net.outputs{i}.range(:,1));
        otherwise
          errNorm = 1;
      end
    end
    errNorm(~isfinite(errNorm)) = 1;
    if all(errNorm == 1), errNorm = 1; end
    net.outputs{i}.errNorm = gpuArray(errNorm);
  end
end