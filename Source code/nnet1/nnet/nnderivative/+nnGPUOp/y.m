function [Y,Af] = y(net,data,hints)

% Copyright 2012-2013 The MathWorks, Inc.

TS = data.TS;
Q = data.Q;
Pd = data.Pd;
Pc = data.Pc;
Ai = data.Ai;
Y = cell(net.numOutputs,TS);

if (Q*TS == 0)
  Af = data.Ai;
  for i=1:numel(Af), Af{i} = gather(Af{i}); end
  if TS > 0
    for i=1:net.numOutputs
      ii = hints.output2layer(i);
      Y(i,:) = {zeros(net.outputs{ii}.size,0)};
    end
  end
  return;
end

doDelayedInputs = isempty(Pd);
doProcessInputs = isempty(Pc) && isempty(Pd);
Ac = [Ai cell(net.numLayers,TS)];
Z = cell(1,hints.maxZ);

% Expand biases not associated with weights, so N will be right size
for i=1:net.numLayers
  if net.biasConnect(i) && (hints.layers{i}.numZ == 1)
    net.b{i} = repmat(net.b{i},1,Q);
  end
end

% Simulate Forward in Time
for ts = 1:TS
  
  % Layers
  for i = hints.layerOrder
    Z(:) = {[]};
    
    % Biases and Weights
    if net.biasConnect(i)
      Z{1} = net.b{i};
    end
    for j = 1:net.numInputs
      if net.inputConnect(i,j)
        if doDelayedInputs
          p_ts = (net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
          if numel(p_ts) == 1
            pd = Pc{j,p_ts};
          else
            pd = cat(1,Pc{j,p_ts});
          end
        else
          pd = Pd{i,j,ts};
        end
        Z{hints.iwzInd(i,j)} = net.IW{i,j} * pd;
      end
    end
    for j = 1:net.numLayers
      if net.layerConnect(i,j)
        a_ts = (net.numLayerDelays+ts)-net.layerWeights{i,j}.delays;
        if numel(a_ts) == 1
          ad = Ac{j,a_ts};
        else
          ad = cat(1,Ac{j,a_ts});
        end
        Z{hints.lwzInd(i,j)} = net.LW{i,j} * ad;
      end
    end
    
    % Net Input and Transfer Function
    numZ = hints.layers{i}.numZ;
    if hints.layers{i}.transferFcns.isArrayFcn
      % Array Netsum and Transfer Fcn
      if (numZ == 0)
        z0 = gpuArray(zeros(net.layers{i}.size,Q));
        [~,ac] = arrayfun(hints.layers{i}.transferFcns.apply{1},z0);
      elseif (numZ == 1) && (hints.layers{i}.isPurelin)
        n = Z{1};
        ac = n;
      else
        stopZ = numZ;
        while (stopZ > 4)
          Z{stopZ-3} = arrayfun(hints.purelinFcns.apply{4},Z{(stopZ-3):stopZ});
          stopZ = stopZ - 3;
        end
        if (stopZ == 1) && (hints.layers{i}.isPurelin)
          n = Z{1};
          ac = n;
        else
          [~,ac] = arrayfun(hints.layers{i}.transferFcns.apply{stopZ},Z{1:stopZ});
        end
      end
    else
      % Array Netsum using Purelin, then regular Transfer Fcn
      stopZ = numZ;
      while (stopZ > 4)
        Z{stopZ-3} = arrayfun(hints.purelinFcns.apply{4},Z{(stopZ-3):stopZ});
        stopZ = stopZ - 3;
      end
      if (stopZ == 1)
        n = Z{1};
      else
        n = arrayfun(hints.purelinFcns.apply{stopZ},Z{1:stopZ});
      end
      if (hints.layers{i}.isPurelin)
        ac = n;
      else
        ac = hints.layers{i}.transferFcns.apply(n);
      end
    end
    Ac{i,net.numLayerDelays+ts} = ac;

    % Output
    if net.outputConnect(i)
      
      % Output Processing
      yi = ac;
      ii = hints.layer2output(i);
      numFcns = hints.outputs{ii}.numFcns;
      for j = numFcns:-1:1
        settings = net.outputs{i}.processSettings{j}.onGPU;
        yi = arrayfun(hints.outputs{ii}.processFcns{j}.reverse,yi,settings{:});
      end
      Y{ii,ts} = yi;
    end
  end
  
  % Deallocate old timesteps
  tsDrop = ts-net.numLayerDelays;
  if (tsDrop >= 1)
    Ac(:,tsDrop) = {[]};
  end
end

% Final Input and Layer States
if nargout > 1
  a_ts = TS+(1:net.numLayerDelays);
  Af = Ac(:,a_ts);
end

if hints.isGPUArray
  % return gpuArray
  Y = Y{1};
else
  % Gather data
  for i=1:numel(Y), Y{i} = gather(Y{i}); end
  if nargout > 1
    for i=1:numel(Af), Af{i} = gather(Af{i}); end
  end
end
