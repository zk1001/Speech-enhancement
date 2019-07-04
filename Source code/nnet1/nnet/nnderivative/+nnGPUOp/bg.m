function [gWB,Perfs,PerfN] = bg(net,Pc,Pt,Ai,T,EW,masks,Q,TS,hints)

% Copyright 2013-2015 The MathWorks, Inc.

numMasks = numel(masks);
if (Q*TS == 0)
  gWB = zeros(hints.learnWB.wbLen,1);
  Perfs = zeros(1,numMasks);
  PerfN = zeros(1,numMasks);
  return;
end
Perfs = gpuArray(zeros(1,numMasks));
PerfN = gpuArray(zeros(1,numMasks));

EWts = size(EW,2) ~= 1;
EWii = size(EW,1) ~= 1;
dB = cell(net.numLayers,1);
dIW = cell(net.numLayers,net.numInputs);
dLW = cell(net.numLayers,net.numLayers);
N = cell(net.numLayers,TS);
Ac = [Ai cell(net.numLayers,TS)];
Z = cell(net.numLayers,hints.maxZ,TS);
dA = cell(net.numLayers,TS);

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
    
    % Biases and Weights
    if net.biasConnect(i)
      Z{i,1,ts} = net.b{i};
    end
    for j = 1:net.numInputs
      if net.inputConnect(i,j)
        p_ts = (net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
        if numel(p_ts) == 1
          pd = Pc{j,p_ts};
        else
          pd = cat(1,Pc{j,p_ts});
        end
        Z{i,hints.iwzInd(i,j),ts} = net.IW{i,j} * pd;
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
        Z{i,hints.lwzInd(i,j),ts} = net.LW{i,j} * ad;
      end
    end
    
    % Net Input and Transfer Function
    numZ = hints.layers{i}.numZ;
    if hints.layers{i}.transferFcns.isArrayFcn
      % Array Netsum and Transfer Fcn
      if (numZ == 0)
        z0 = gpuArray(zeros(net.layers{i}.size,Q));
        [n,ac] = arrayfun(hints.layers{i}.transferFcns.apply{1},z0);
      elseif (numZ == 1) && (hints.layers{i}.isPurelin)
        n = Z{i,1,ts};
        ac = n;
      else
        stopZ = numZ;
        while (stopZ > 4)
          Z{i,stopZ-3,ts} = arrayfun(hints.purelinFcns.apply{4},Z{i,(stopZ-3):stopZ,ts});
          stopZ = stopZ - 3;
        end
        [n,ac] = arrayfun(hints.layers{i}.transferFcns.apply{stopZ},Z{i,1:stopZ,ts});
      end
    else
      % Array Netsum using Purelin, then regular Transfer Fcn
      stopZ = numZ;
      while (stopZ > 4)
        Z{stopZ-3} = arrayfun(hints.purelinFcns.apply{4},Z{i,(stopZ-3):stopZ});
        stopZ = stopZ - 3;
      end
      if (stopZ == 1)
        n = Z{1};
      else
        n = arrayfun(hints.purelinFcns.apply{stopZ},Z{i,1:stopZ});
      end
      if (hints.layers{i}.isPurelin)
        ac = n;
      else
        ac = hints.layers{i}.transferFcns.apply(n);
      end
    end
    N{i,ts} = n;
    Ac{i,net.numLayerDelays+ts} = ac;
  end
end

% Gradient Backward in Time
for ts = TS:-1:1
  for i = fliplr(hints.layerOrder)
   
    % Output
    if net.outputConnect(i)
      
      % Output Processing
      yi = Ac{i,net.numLayerDelays+ts};
      ii = hints.layer2output(i);
      numFcns = hints.outputs{ii}.numFcns;
      for j = numFcns:-1:1
        settings = net.outputs{i}.processSettings{j}.onGPU;
        yi = arrayfun(hints.outputs{ii}.processFcns{j}.reverse,yi,settings{:});
      end
      
      % Performance
      en = net.outputs{i}.errNorm;
      ew = EW{(EWii*(ii-1))+1,EWts*(ts-1)+1};
      ti = T{ii,ts};
      mask1 = masks{1}{ii,ts};
      S = size(ti,1);
      if (numMasks == 1)
        [perfs1,N1,dy] = arrayfun(hints.performFcns.perf_dy_1mask,ti,yi,en,ew,mask1,S);
      else
        mask2 = masks{2}{ii,ts};
        mask3 = masks{3}{ii,ts};
        [perfs1,perfs2,perfs3,N1,N2,N3,dy] = arrayfun(hints.performFcns.perf_dy_3masks,ti,yi,en,ew,mask1,mask2,mask3,S);
        Perfs(2) = Perfs(2) + sum(sum(perfs2));
        PerfN(2) = PerfN(2) + sum(sum(N2));
        Perfs(3) = Perfs(3) + sum(sum(perfs3));
        PerfN(3) = PerfN(3) + sum(sum(N3));
      end
      Perfs(1) = Perfs(1) + sum(sum(perfs1));
      PerfN(1) = PerfN(1) + sum(sum(N1));
      if sum(sum(perfs1)) < 0, keyboard, end
        
      % Backprop Output Processing
      for j = 1:numFcns
        settings = net.outputs{i}.processSettings{j}.onGPU;
        dy = arrayfun(hints.outputs{ii}.processFcns{j}.backpropReverse,dy,settings{:});
      end
      if isempty(dA{i,ts})
        dA{i,ts} = dy;
      else
        dA{i,ts} = dA{i,ts} + dy;
      end
    end
    
    % Transfer Function
    numZ = hints.layers{i}.numZ;
    if (numZ > 0) && ~isempty(dA{i,ts})
      if hints.layers{i}.isPurelin
        dn = dA{i,ts};
      elseif hints.layers{i}.transferFcns.isArrayFcn
        dn = arrayfun(hints.layers{i}.transferFcns.backprop,dA{i,ts},N{i,ts},Ac{i,net.numLayerDelays+ts});
      else
        dn = hints.layers{i}.transferFcns.backprop(dA{i,ts},N{i,ts},Ac{i,net.numLayerDelays+ts});
      end
      dA(i,ts) = {[]};
      
      % Net Input and Layer Weights
      for j = net.numLayers:-1:1
        if net.layerConnect(i,j)
          
          a_ts = (net.numLayerDelays+ts)-net.layerWeights{i,j}.delays;
          if numel(a_ts) == 1
            ad = Ac{j,a_ts};
          else
            ad = cat(1,Ac{j,a_ts});
          end
          if hints.learnWB.lwInclude(i,j)
            dlw = dn * ad';
            if isempty(dLW{i,j}), dLW{i,j} = dlw; else dLW{i,j} = dLW{i,j} + dlw; end
          end

          dad = net.LW{i,j}' * dn;
          delays = ts-net.layerWeights{i,j}.delays;
          numDelays = numel(delays);
          if numDelays == 1
            if (delays > 0)
              if isempty(dA{j,delays})
                dA{j,delays} = dad;
              else
                dA{j,delays} = dA{j,delays} + dad;
              end
            end
          else
            wsize = size(dad,1)/numDelays;
            for k=1:numDelays
              ts_k = delays(k);
              if (ts_k > 0)
                if isempty(dA{j,ts_k})
                  dA{j,ts_k} = dad((wsize*(k-1))+(1:wsize),:);
                else
                  dA{j,ts_k} = dA{j,ts_k} + dad((wsize*(k-1))+(1:wsize),:);
                end
              end
            end
          end
        end
      end

      % Net Input and Input Weights
      for j = net.numInputs:-1:1
        if net.inputConnect(i,j)
          
          if hints.learnWB.iwInclude(i,j)
            p_ts = (net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
            if numel(p_ts) == 1
              pdt = Pt{j,p_ts};
            else
              pdt = cat(2,Pt{j,p_ts});
            end
            diw = dn * pdt;
            if isempty(dIW{i,j}), dIW{i,j} = diw; else dIW{i,j} = dIW{i,j} + diw; end
          end
        end
      end

      % Net Input and Bias
      if hints.learnWB.bInclude(i)
        db = sum(dn,2);
        if isempty(dB{i}), dB{i} = db; else dB{i} = dB{i} + db; end
      end
    end
  end
end

% Combine Weights and Biases
gWB = hints.gWB;
for i=1:net.numLayers
  if hints.learnWB.bInclude(i)
    if ~isempty(dB{i})
      gWB(hints.learnWB.bInd{i}) = dB{i};
    else
      gWB(hints.learnWB.bInd{i}) = 0;
    end
  end
  for j=1:net.numInputs
    if hints.learnWB.iwInclude(i,j)
      if ~isempty(dIW{i,j})
        gWB(hints.learnWB.iwInd{i,j}) = dIW{i,j};
      else
        gWB(hints.learnWB.iwInd{i,j}) = 0;
      end
    end
  end
  for j=1:net.numLayers
    if hints.learnWB.lwInclude(i,j)
      if ~isempty(dLW{i,j})
        gWB(hints.learnWB.lwInd{i,j}) = dLW{i,j};
      else
        gWB(hints.learnWB.lwInd{i,j}) = 0;
      end
    end
  end
end

gWB = gather(gWB);
Perfs = gather(Perfs);
PerfN = gather(PerfN);
end
