function problem = netCheck(net,hints,usesGradient,usesJacobian)

% Copyright 2012-2013 The MathWorks, Inc.

if nargin < 4, usesJacobian = false; end
if nargin < 3, usesGradient = false; end

fcns = nnMex.netFcns;

if usesGradient || usesJacobian
  fcns.netInputFcns = setdiff(fcns.netInputFcns,'netprod');
end

for i=1:net.numInputs
  for j=1:numel(net.inputs{i}.processFcns)
    f = net.inputs{i}.processFcns{j};
    nc = net.inputs{i}.processSettings{j}.no_change;
    if isempty(nnstring.match(f,fcns.inputProcessFcns)) && ~nc
      problem = ['Input processing function ' upper(f) ' is not supported with NNGPU.'];
      return;
    end
  end
end

for i=1:net.numLayers
  for j=1:net.numInputs
    if net.inputConnect(i,j)
      f = net.inputWeights{i,j}.weightFcn;
      if isempty(nnstring.match(f,fcns.weightFcns))
        problem = ['Weight function ' upper(f) ' is not supported with NNMEX.'];
        return;
      end
    end
  end

  for j=1:net.numLayers
    if net.layerConnect(i,j)
      f = net.layerWeights{i,j}.weightFcn;
      if isempty(nnstring.match(f,fcns.weightFcns))
        problem = ['Weight function ' upper(f) ' is not supported with NNMEX.'];
        return;
      end
    end
  end

  f = net.layers{i}.netInputFcn;
  if isempty(nnstring.match(f,fcns.netInputFcns))
    problem = ['Net input function ' upper(f) ' is not supported with NNMEX.'];
    return;
  end

  f = net.layers{i}.transferFcn;
  if isempty(nnstring.match(f,fcns.transferFcns))
    problem = ['Transfer function ' upper(f) ' is not supported with NNMEX.'];
    return;
  end

  if net.outputConnect(i)
    for j=1:numel(net.outputs{i}.processFcns)
      f = net.outputs{i}.processFcns{j};
      nc = net.outputs{i}.processSettings{j}.no_change;
      if isempty(nnstring.match(f,fcns.outputProcessFcns)) && ~nc
        problem = ['Output processing function ' upper(f) ' is not supported with NNMEX.'];
        return;
      end
    end
  end
end

f = net.performFcn;
if isempty(nnstring.match(f,fcns.performFcns)) && (usesGradient || usesJacobian)
  problem = ['Performance function ' upper(f) ' is not supported with NNMEX.'];
  return;
end

problem = '';
