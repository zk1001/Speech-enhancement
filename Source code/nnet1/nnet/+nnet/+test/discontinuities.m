function [discont,ignore] = discontinuities(net,X,Xi,Ai)
%DERIV Test network subfunction derivatives.

% Copyright 2010-2012 The MathWorks, Inc.

% Network and Data Problem
if nargin == 1
  seed = net;
  setdemorandstream(seed);
  [net,X,Xi,Ai] = nntest.rand_problem(seed);
  MASK = MASKS{1};
end

discont = {};
ignore = {};

net = struct(net);
fcns = nn7.netHints(net,struct);
layerOrder = nn.layer_order(net);
layer2output = cumsum(net.outputConnect);
NID = net.numInputDelays;
NLD = net.numLayerDelays;

Q = nnfast.numsamples(X);
TS = nnfast.numtimesteps(X);
P = cell(net.numInputs,NID+1);
A = cell(net.numLayers,NLD+1);
BZ = cell(net.numLayers,1);
sizeZ = zeros(net.numLayers,1);
Y = cell(net.numOutputs,TS);

A(:,1:NLD) = Ai;

Q1s = ones(1,Q);
for i = layerOrder
  if net.biasConnect(i)
    BZ{i} = net.b{i}(:,Q1s);
  end
  sizeZ(i) = sum([net.biasConnect(i) net.inputConnect(i,:) net.layerConnect(i,:)]);
end

showTime = (TS > 1) || (net.numInputDelays > 1) || (net.numLayerDelays > 1);

for ts = 1:net.numInputDelays
  
  for i = 1:net.numInputs
    object = ['inputs{' num2str(i) '}'];
    pi = Xi{i,ts};
    for j=1:length(fcns.inputs(i).process)
      processFcn = fcns.inputs(i).process(j);
      % IGNORE KNOWN PROBLEMS
      % KNOWN PROBLEM: Extremely large gain on mapminmax
      if strcmp(processFcn.mfunction,'mapminmax') && (max_abs_element(processFcn.settings.gain) > 1e12)
        ignore{end+1} = [upper(processFcn.mfunction) ' gain greater than 1e12.'];
      end
      nextpi = processFcn.apply(pi,processFcn.settings);
      pi = nextpi;
    end
    P{i,ts} = pi;
  end
  
end

for ts = 1:TS
    
  for i = 1:net.numInputs
    object = ['inputs{' num2str(i) '}'];
    pi = X{i,ts};
    for j=1:length(fcns.inputs(i).process)
      processFcn = fcns.inputs(i).process(j);
      nextpi = processFcn.apply(pi,processFcn.settings);
      pi = nextpi;
    end
    P{i,1+NID} = pi;
  end
  
  for i=layerOrder

    S = net.layers{i}.size;
        
    Z = cell(1,sizeZ(i));
    zind = 1;

    if net.biasConnect(i)
      Z{zind} = BZ{i};
      zind = zind + 1;
    end

    % Input Weights
    for j=1:net.numInputs
      if net.inputConnect(i,j)
        object = ['inputWeights{' num2str(i) ',' num2str(j) '}'];
        weightFcn = fcns.inputWeights(i,j).weight;
        info = feval(weightFcn.mfunction,'info');
        
        w = net.IW{i,j};
        d = net.inputWeights{i,j}.delays;
        p = cat(1,P{j,NID+1-d});
        z = weightFcn.apply(w,p,weightFcn.param);
        R = net.inputs{j}.processedSize * numel(d);
        
        % discontinuity
        if any(feval([weightFcn.mfunction '.discontinuity'],w,p,weightFcn.param))
          discont{end+1} = [upper(weightFcn.mfunction) ' weight function discontinuity.'];
        end
                      
        % IGNORE KNOWN PROBLEMS
        % KNOWN PROBLEM: Extremely large W or P
        if (max_abs_element(w) > 1e28) || (max_abs_element(p) > 1e28)
          ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e28.'];
        end
        % KNOWN PROBLEM: DIST and NEGDIST with extremely large W or P
        if any(strcmp(weightFcn.mfunction,{'dist','negdist'}))
          if (max_abs_element(w) > 1e15) || (max_abs_element(p) > 1e15)
            ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e15.'];
          end
        end
        % KNOWN PROBLEM: NORMPROD with extremely small max p
        if strcmp(weightFcn.mfunction,'normprod') && any(any(max(abs(p),[],1) < 1e-6))
          ignore{end+1} = 'NORMPROD maximum input value less than 1e-6.';
        end
        
        Z{zind} = z;
        zind = zind + 1;
      end
    end

    for j=1:net.numLayers
      if net.layerConnect(i,j)
        object = ['layerWeights{' num2str(i) ',' num2str(j) '}'];
        weightFcn = fcns.layerWeights(i,j).weight;
        info = feval(weightFcn.mfunction,'info');
        w = net.LW{i,j};
        d = net.layerWeights{i,j}.delays;
        p = cat(1,A{j,NLD+1-d});
        z = weightFcn.apply(w,p,weightFcn.param);
        R = net.layers{j}.size * numel(d);
        
        % discontinuity
        if any(feval([weightFcn.mfunction '.discontinuity'],w,p,weightFcn.param))
          discont{end+1} = [upper(weightFcn.mfunction) ' weight function discontinuity.'];
        end
                
        % IGNORE KNOWN PROBLEMS
        % KNOWN PROBLEM: Extremely large W or P
        if (max_abs_element(w) > 1e28) || (max_abs_element(p) > 1e28)
          ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e28.'];
        end
        % KNOWN PROBLEM: DIST and NEGDIST with extremely large W or P
        if any(strcmp(weightFcn.mfunction,{'dist','negdist'}))
          if (max_abs_element(w) > 1e15) || (max_abs_element(p) > 1e15)
            ignore{end+1} = [upper(weightFcn.mfunction) ' inputs or weights greater than 1e15.'];
          end
        end
        % KNOWN PROBLEM: NORMPROD with extremely small p
        if strcmp(weightFcn.mfunction,'normprod') && any(any(max(abs(p),[],1) < 1e-6))
          ignore{end+1} = 'NORMPROD maximum input value less than 1e-6.';
        end
        
        Z{zind} = z;
        zind = zind + 1;
      end
    end

    % Net Input Function
    object = ['layers{' num2str(i) '}'];
    netFcn = fcns.layers(i).netInput;
    n = netFcn.apply(Z,net.layers{i}.size,Q,netFcn.param);
    if isempty(Z), n = zeros(net.layers{i}.size,Q) + n; end

    % Transfer Function
    transferFcn = fcns.layers(i).transfer;
    a = transferFcn.apply(n,transferFcn.param);
    A{i,1+NLD} = a;
    
    % discontinuity
    if any(feval([transferFcn.mfunction '.discontinuity'],n,transferFcn.param))
      discont{end+1} = [upper(transferFcn.mfunction) ' transfer function discontinuity.'];
    end
    
    % known instabilities
    if strcmp(transferFcn.mfunction,'radbasn')
      if any(any(bsxfun(@minus,-n.*n,max(-n.*n,[],1)) < -700))
        ignore{end+1} = 'RADBASN has too large of a span between net input elements.';
      end
    end
  
    if net.outputConnect(i)
      ii = layer2output(i);
      object = ['outputs{' num2str(ii) '}'];
      yi = A{i,1+NLD};
      for j=length(fcns.outputs(ii).process):-1:1

        % Output Processing Function - Reverse
        processFcn = fcns.outputs(ii).process(j);
        nextyi = processFcn.reverse(yi,processFcn.settings);
        yi = nextyi;
      end
      Y{ii,ts} = yi;
    end
  end
  
  % Shift input states
  P = [P(:,2:end) cell(net.numInputs,1)];
  A = [A(:,2:end) cell(net.numLayers,1)];
  
end % ts

function x = max_abs_element(x)
if isempty(x)
  x = 0;
else
  while(numel(x) > 1)
    x = max(abs(x));
  end
end
