function [netc,xic,aic] = closeloop(neto,xio,aio)
%CLOSELOOP Convert neural network open feedback to closed feedback loops.
%
%  <a href="matlab:doc closeloop">closeloop</a>(NET) takes a network and transforms any outputs marked
%  as open loop (i.e. NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackMode">feedbackMode</a> = 'open') to closed
%  loop.
%
%  This is done by replacing the input associated with the open loop
%  output (i.e. the input whose index is NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackInput">feedbackInput</a>)
%  with an interal layer weight connection.
%
%  Here a NARX network is designed. The NARX network has a standard input
%  and an open loop feedback output to an associated feedback input.
%
%    [X,T] = <a href="matlab:doc simplenarx_dataset">simplenarx_dataset</a>;
%    net = <a href="matlab:doc narxnet">narxnet</a>(1:2,1:2,10);
%    [Xs,Xi,Ai,Ts] = <a href="matlab:doc preparets">preparets</a>(net,X,{},T);
%    net = <a href="matlab:doc train">train</a>(net,Xs,Ts,Xi,Ai);
%    <a href="matlab:doc view">view</a>(net)
%    Y = net(Xs,Xi,Ai)
%
%  Now the network is converted to closed loop form and simulated.
%
%    netc = <a href="matlab:doc closeloop">closeloop</a>(net);
%    <a href="matlab:doc view">view</a>(netc)
%    [Xc,Xic,Aic,Tc] = <a href="matlab:doc preparets">preparets</a>(netc,X,{},T);
%    Y = net(Xc,Xic,Aic)
%
%  The function <a href="matlab:doc openloop">openloop</a> reverses this transformation.
%
%    neto = <a href="matlab:doc openloop">openloop</a>(netc);
%    view(neto)
%
%  Converting Delay States
%
%  [NET,Xi,Ai] = openloop(NET,Xi,Ai) converts a open-loop network and its
%  current input delay states Xi and layer delay states Ai to closed-loop form.
%
%  For examples on using <a href="matlab:doc closeloop">closeloop</a> and <a href="matlab:doc openloop">openloop</a> to implement multistep
%  prediction, see <a href="matlab:doc narxnet">narxnet</a> and<a href="matlab:doc narnet">narnet</a>.
%
% See also OPENLOOP, NARXNET, NARNET.

% Copyright 2010-2013 The MathWorks, Inc.

% Check original network for zero delay loops
[~,zeroDelayLoop] = nn.layer_order(neto);
if zeroDelayLoop, error(message('nnet:NNet:ZeroDelayLoop')); end

% Close all open loops
netc = neto;
for i=find(netc.outputConnect)
  if strcmp(netc.outputs{i}.feedbackMode,'open')
    j = netc.outputs{i}.feedbackInput;
    
    k = find(netc.inputConnect(:,j) & netc.layerConnect(:,i),1);
    if ~isempty(k)
      msg = ['Layer ' num2str(k) ' has both open and closed-loop connections from the same output layer.'];
      error('nnet:closeloop:OpenAndClosedLoop',msg);
    end
    numLayerDelaysI = 0;
    for k=1:netc.numLayers
      if netc.layerConnect(k,i)
        numLayerDelaysI = max(numLayerDelaysI,max(netc.layerWeights{k,i}.delays));
      end
    end
    numInputDelaysJ = 0;
    for k=1:netc.numLayers
      if netc.inputConnect(k,j)
        numInputDelaysJ = max(numInputDelaysJ,max(netc.inputWeights{k,j}.delays));
      end
    end
    if (numLayerDelaysI > 0) && (numInputDelaysJ > 0)
      msg = ['Layer ' num2str(i) ' has delay states to another layer and from its feedback input.'];
      error('nnet:closeloop:LayerAndInputDelays',msg);
    end
    
    netc.outputs{i}.feedbackMode = 'closed';
  end
end

% Check closed-loop network for zero delay loops
[~,zeroDelayLoop] = nn.layer_order(netc);
if zeroDelayLoop, error(message('nnet:NNet:ZeroDelayLoop')); end

% Return if no delay state arguments
if (nargin == 1)
  if (nargout > 1)
    error('nnet:arguments:TooManyOutputArguments','Too many output arguments.');
  end
  return
elseif (nargout <= 1)
  return;
end

% Two output arguments not allowed (only 1 or 3) because
% closing the loop typically creates layer states Aic.
if (nargout == 2)
  error('nnet:arguments:NotEnoughOutputArguments','Not enough output arguments.');
end

% Default Aio input argument
if (nargin < 3)
  if (neto.numLayerDelays > 0)
    error('nnet:arguments:NotEnoughInputArguments','Not enough input arguments.');
  else
    aio = cell(neto.numLayers,0);
  end
end

% Number of samples
if ~isempty(xio)
  Q = size(xio{1},2);
elseif ~isempty(aio)
  Q = size(aio{1},2);
else
  Q = 0;
end

% Check Xio size
if ~iscell(xio) || ~ismatrix(xio) || any(size(xio) ~= [neto.numInputs neto.numInputDelays])
  msg = ['Xi is not a ' num2str(neto.numInputs) '-by-' num2str(neto.numInputDelays) ' cell array.'];
  error('nnet:data:XiNotCorrectDimensions',msg);
end
for i=1:neto.numInputs
  for j=1:neto.numInputDelays
    xi = xio{i,j};
    if ~isnumeric(xi) || ~ismatrix(xi) || any(size(xi) ~= [neto.inputs{i}.size Q])
      msg = ['Xi{' num2str(i) ',' num2str(j) '} is not a ' num2str(neto.inputs{i}.size) '-by-' num2str(Q) ' numeric array.'];
      error('nnet:data:IncorrectDimensions',msg);
    end
  end
end

% Check Aio size
if ~iscell(aio) || ~ismatrix(aio) || any(size(aio) ~= [neto.numLayers neto.numLayerDelays])
  msg = ['Ai is not a ' num2str(neto.numLayers) '-by-' num2str(neto.numLayerDelays) ' cell array.'];
  error('nnet:data:IncorrectDimensions',msg);
end
for i=1:neto.numLayers
  for j=1:neto.numLayerDelays
    ai = aio{i,j};
    if ~isnumeric(ai) || ~ismatrix(ai) || any(size(ai) ~= [neto.layers{i}.size Q])
      msg = ['Ai{' num2str(i) ',' num2str(j) '} is not a ' num2str(neto.layers{i}.size) '-by-' num2str(Q) ' numeric array.'];
      error('nnet:data:IncorrectDimensions',msg);
    end
  end
end

% Keep Non-Feedback Input States
nonFeedbackInputs = true(1,neto.numInputs);
for i=neto.numInputs:-1:1
  nonFeedbackInputs(i) = isempty(neto.inputs{i}.feedbackOutput);
end
delayShift = neto.numInputDelays - netc.numInputDelays;
xic = xio(nonFeedbackInputs,(1:netc.numInputDelays)+delayShift);

% Allocate Layer States
aic = cell(netc.numLayers,netc.numLayerDelays);
for i=1:netc.numLayers
  aic(i,:) = {nan(netc.layers{i}.size,Q)};
end

% Keep Layer States
delayShift = netc.numLayerDelays - neto.numLayerDelays;
aic(:,(1:neto.numLayerDelays)+delayShift) = aio;

% Convert Open Feedback Input States to Layer States
% by applying input processing
for i=1:neto.numLayers
  if neto.outputConnect(i)
    if strcmp(neto.outputs{i}.feedbackMode,'open')
      j = neto.outputs{i}.feedbackInput;
      numDelays = min(neto.numInputDelays,netc.numLayerDelays);
      delayShift1 = neto.numInputDelays - numDelays;
      delayShift2 = netc.numLayerDelays - numDelays;
      for ts=1:numDelays
        ai = xio(j,ts+delayShift1);
        for k=1:length(neto.inputs{j}.processFcns)
          fcn = neto.inputs{j}.processFcns{k};
          settings = neto.inputs{j}.processSettings{k};
          ai = feval(fcn,'apply',ai,settings);
        end
        aic(i,ts+delayShift2) = ai;
      end
    end
  end
end

