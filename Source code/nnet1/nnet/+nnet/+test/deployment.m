function ok = deployment(net,x,xi,ai,seed)
%DEPLOYMENT Test neural network deployment
%
% Syntax
%
%   ok = nntest.sim(seed)
%   ok = nntest.sim(net,x,xi,ai,t,ew,masks,seed)
%
% Tests randomly generated problems from a seed, or specific problems.

% Copyright 2013 The MathWorks, Inc.

  % Run one test
  if nargin == 1
    seed = net;
    [net,x,xi,ai] = nntest.rand_problem(seed);
  end
  
  %if nargin == 1, clc, end
  disp(' ')
  disp(['========== NNET.TEST.DEPLOYMENT(' num2str(seed) ') Testing...'])
  disp(' ')
  if nargin == 1, nntest.disp_problem(net,x,xi,ai,seed); disp(' '); end
  
  diagram = view(net);

  ok = testDeployment(net,x,xi,ai,seed);
  
  diagram.setVisible(false)
  diagram.dispose

  if ok
    result = 'PASSED';
  else
    net.name = ['INACCURATE - ' net.name];
    view(net)
    result = 'FAILED';
  end
  disp(' ')
  disp(['========== NNET.TEST.DEPLOYMENT(' num2str(seed) ') *** ' result ' ***'])
  disp(' ')
end


function ok = testDeployment(net,X,Xi,Ai,seed)
  import nnet.codegen.*;
  
  ok  = true;
  
  [discontinuity,ignore] = nnet.test.discontinuities(net,X,Xi,Ai);
  if ~isempty(discontinuity) %& 1 == 0
    disp(['Skipping random network ' num2str(seed) ' due to discontinuities.']);
    for i=1:numel(discontinuity), disp(discontinuity{i}); end
    return
  elseif ~isempty(ignore)
    disp(['Skipping Random network ' num2str(seed) ' due to IGNORE known issue.'])
    for i=1:numel(ignore), disp(ignore{i}); end
    return
  elseif ~isempty(nnMex.netCheck(net))
    disp(['Skipping Random network ' num2str(seed) ' due to unsupported module.'])
    return
  end
  % Prune network and data of zero sized inputs, layers and outputs
  [net,pi,pl,po] = prune(net);
  [X,Xi,Ai] = prunedata(net,pi,pl,po,X,Xi,Ai);
  
  % Simulate only 1 timestep if no network inputs
  % As dynamic matrix algorithms will assume 1 timestep
  if (net.numInputs == 0)
    X = cell(0,1);
  end
  
  % TS
  TS = size(X,2);
  if ~isempty(X)
    Q = size(X{1},2);
  elseif ~isempty(Xi)
    Q = size(Xi{1},2);
  elseif ~isempty(Ai)
    Q = size(Ai{1},2);
  else
    Q = 0;
  end
  
  % Accuracy
  accuracy = 1e-10 * sqrt(TS);
  
  % Test Assertion
  isStatic = ((net.numInputDelays + net.numLayerDelays) == 0);    
  if isStatic && (net.numInputs == 0) && (Q > 0)
    disp('Not a good test.');
    ok = false;
    return
  end
  
  % Baseline outputs for comparison
  [Y1,Xf1,Af1] = net(X,Xi,Ai,nnSimple);
  
  % Static
  if isStatic
    
    % Test Static genFunction, Matrix
    genFunction(net,'neural_function','MatrixOnly','yes','showLinks','no');
    while isempty(which('neural_function')), end
    clear neural_function
    codeGenCompliance = mlint('neural_function','-codegen');
    if ~isempty(codeGenCompliance)
      disp('genFunctionMatrixStatic code fails CODEGEN compliance.');
      mlint('neural_function','-codegen')
      ok = false;
      return
    end
    outputArgs = commaList(numberedStrings('y',net.numOutputs));
    if net.numOutputs > 0
      returnStr = ['[' outputArgs '] = '];
    else
      returnStr = '';
    end
    for ts=1:TS
      x = X(:,ts);
      eval([returnStr 'neural_function(x{:});']);
      y2 = eval(['cat(' commaList([{'1'},outputArgs]) ');']);
      diff = relativeDifference(Y1(:,ts),y2);
      if diff > accuracy
        disp('genFunctionMatrixStatic failed.');
        ok = false;
        return
      end
    end
    delete neural_function.m
    clear neural_function

    % Test Static, genFunction, Cell
    genFunction(net,'neural_function','MatrixOnly','no','showLinks','no');
    while isempty(which('neural_function')), end
    clear neural_function
    codeGenCompliance = mlint('neural_function');
    if ~isempty(codeGenCompliance)
      disp('genFunctionCell code fails MATLAB compliance.');
      mlint('neural_function')
      ok = false;
      return
    end
    Y2 = neural_function(X);
    diff = relativeDifference(Y1,Y2);
    if diff > accuracy
      disp('genFunctionCell failed.');
      ok = false;
      return
    end
    if (net.numInputs == 1) && (net.numOutputs == 1) &&  size(X,2) > 0
      Y2 = neural_function(cell2mat(X));
      diff = relativeDifference(Y1,Y2);
      if diff > accuracy
        disp('genFunctionCell failed.');
        ok = false;
        return
      end
    end
    delete neural_function.m
    clear neural_function

  else

    % Test Dynamic, genFunction, Matrix
    % Compatible MATLAB Compiler, Codegen
    genFunction(net,'neural_function','MatrixOnly','yes','showLinks','no');
    while isempty(which('neural_function')), end
    clear neural_function
    codeGenCompliance = mlint('neural_function','-codegen');
    if ~isempty(codeGenCompliance)
      disp('genFunction dynamic matrix code fails CODEGEN compliance.');
      mlint('neural_function','-codegen')
      ok = false;
      return
    end
    yArgs = numberedStrings('y',net.numOutputs);
    xfArgs = numberedStrings('xf',net.numInputs);
    afArgs = numberedStrings('af',net.numLayers);
    xfArgs = xfArgs(inputDelayInd(net));
    afArgs = afArgs(layerDelayInd(net));
    outputArgs = commaList([yArgs xfArgs afArgs]);
    for q=1:Q
      if (TS > 0)
        x = seq2con(getsamples(X,q));
      else
        x = nndata(nn.input_sizes(net),0);
      end
      xi = seq2con(getsamples(Xi(inputDelayInd(net),:),q));
      ai = seq2con(getsamples(Ai(layerDelayInd(net),:),q));
      eval(['[' outputArgs '] = neural_function(x{:},xi{:},ai{:});']);
      yAll2 = eval(['cat(' commaList([{'1'} yArgs]) ')']);
      yAll1 = cell2mat(getsamples(Y1,q));
      diff = relativeDifference(yAll1,yAll2);
      if diff > accuracy
        disp('genFunction failed.');
        ok = false;
        return
      end
      xfAll2 = eval(['cat(' commaList([{num2str(1)} xfArgs]) ')']);
      xfAll1 = cell2mat(getsamples(Xf1(inputDelayInd(net),:),q));
      diff = relativeDifference(xfAll1,xfAll2);
      if diff > accuracy
        disp('genFunction failed.');
        ok = false;
        return
      end
      afAll2 = eval(['cat(' commaList([{num2str(1)} afArgs]) ')']);
      afAll1 = cell2mat(getsamples(Af1(layerDelayInd(net),:),q));
      diff = relativeDifference(afAll1,afAll2);
      if diff > accuracy
        disp('genFunction failed.');
        ok = false;
        return
      end
    end
    delete neural_function.m
    clear neural_function

    % Test Dynamic, genFunction, Cell
    genFunction(net,'neural_function','MatrixOnly','no','showLinks','no');
    while isempty(which('neural_function')), end
    clear neural_function
    codeGenCompliance = mlint('neural_function');
    if ~isempty(codeGenCompliance)
      disp('genFunctionCell dynamic code fails MATLAB compliance.');
      mlint('neural_function')
      ok = false;
      return
    end
    [Y2,Xf2,Af2] = neural_function(X,Xi,Ai);
    diff = relativeDifference(Y1,Y2);
    if diff > accuracy
      disp('genFunctionCell dynamic failed');
      ok = false;
      return
    end
    diff = relativeDifference(Xf1,Xf2);
    if diff > accuracy
      disp('genFunctionCell dynamic failed')
      ok = false;
      return
    end
    diff = relativeDifference(Af1,Af2);
    if diff > accuracy
      disp('genFunctionCell dynamic failed')
      ok = false;
      return
    end
      
    delete neural_function.m
    clear neural_function
    
  end
end

function ind = inputDelayInd(net)
  ind = false(1,net.numInputs);
  for i=1:net.numInputs
    for j=1:net.numLayers
      if net.inputConnect(j,i) && (max(net.inputWeights{j,i}.delays) > 0)
        ind(i) = true;
        break;
      end
    end
  end
  ind = find(ind);
end

function ind = layerDelayInd(net)
  ind = false(1,net.numInputs);
  for i=1:net.numLayers
    for j=1:net.numLayers
      if net.layerConnect(j,i) && (max(net.layerWeights{j,i}.delays) > 0)
        ind(i) = true;
        break;
      end
    end
  end
  ind = find(ind);
end

function diff = relativeDifference(a,b)
  if iscell(a), a = cell2mat(a); end
  if iscell(b), b = cell2mat(b); end
  if isempty(a) && isempty(b)
    diff = 0;
  elseif all(a(:)==0)
    diff = sqrt(sum((a(:)-b(:)).^2));
  else
    diff = sqrt(sum((a(:)-b(:)).^2)) / sqrt(sum(a(:).^2));
  end
end
