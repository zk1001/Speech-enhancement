function [neto,xio,aio] = openloop(netc,xic,aic)
%OPENLOOP Convert neural network closed feedback to open feedback loops.
%
%  <a href="matlab:doc openloop">openloop</a>(NET) takes a network and transforms any outputs marked
%  as closed loop (i.e. NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackMode">feedbackMode</a> = 'closed') to open
%  loop.
%
%  This is done by replacing any layer connections coming from closed
%  loop outputs with input weights coming from a new input, and associating
%  the new input with the output (NET.<a href="matlab:doc nnproperty.net_outputs">outputs</a>{i}.<a href="matlab:doc nnproperty.output_feedbackInput">feedbackInput</a> is set to
%  the index of the new input.)
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
%  [NET,Xi,Ai] = openloop(NET,Xi,Ai) converts a closed-loop network and its
%  current input delay states Xi and layer delay states Ai to open-loop form.
%
%  For examples on using <a href="matlab:doc closeloop">closeloop</a> and <a href="matlab:doc openloop">openloop</a> to implement multistep
%  prediction, see <a href="matlab:doc narxnet">narxnet</a> and<a href="matlab:doc narnet">narnet</a>.
%
% See also CLOSELOOP, NARXNET, NARNET.

% Copyright 2010-2013 The MathWorks, Inc.

% Check original network for zero-delay loops
[~,zeroDelayLoop] = nn.layer_order(netc);
if zeroDelayLoop, error(message('nnet:NNet:ZeroDelayLoop')); end

% Open all closed loops
neto = netc;
for i=find(neto.outputConnect)
  if strcmp(neto.outputs{i}.feedbackMode,'closed')
    neto.outputs{i}.feedbackMode = 'open';
  end
end

% Check open-loop network for zero delay loops
[~,zeroDelayLoop] = nn.layer_order(neto);
if zeroDelayLoop, error(message('nnet:NNet:ZeroDelayLoop')); end

% Return if no delay state arguments
if (nargin == 1)
  if (nargout > 1)
    error('nnet:arguments:TooManyOutputArguments','Too many output arguments.');
  end
  return;
elseif (nargout <=1)
  return;
end

% Two output arguments not allowed (only 1 or 3) because
% closing the loop typically creates layer states Aic.
if (nargout == 2)
  error('nnet:arguments:NotEnoughOutputArguments','Not enough output arguments.');
end

% Two input arguments not allowed (only 1 or 3) because
% opening the loop typically requires layer states Aic.
if (nargin == 2)
  error('nnet:arguments:NotEnoughInputArguments','Not enough input arguments.');
end

% Number of samples
if ~isempty(xic)
  Q = size(xic{1},2);
elseif ~isempty(aic)
  Q = size(aic{1},2);
else
  Q = 0;
end

% Check Xic size
if ~iscell(xic) || ~ismatrix(xic) || any(size(xic) ~= [netc.numInputs netc.numInputDelays])
  msg = ['Xi is not a ' num2str(netc.numInputs) '-by-' num2str(netc.numInputDelays) ' cell array.'];
  error('nnet:data:XiNotCorrectDimensions',msg);
end
for i=1:netc.numInputs
  for j=1:netc.numInputDelays
    xi = xic{i,j};
    if ~isnumeric(xi) || ~ismatrix(xi) || any(size(xi) ~= [netc.inputs{i}.size Q])
      msg = ['Xi{' num2str(i) ',' num2str(j) '} is not a ' num2str(netc.numInputs) '-by-' num2str(netc.numInputDelays) ' numeric array.'];
      error('nnet:data:IncorrectDimensions',msg);
    end
  end
end

% Check Aic size
if ~iscell(aic) || ~ismatrix(aic) || any(size(aic) ~= [netc.numLayers netc.numLayerDelays])
  msg = ['Ai is not a ' num2str(netc.numLayers) '-by-' num2str(netc.numLayerDelays) ' cell array.'];
  error('nnet:data:IncorrectDimensions',msg);
end
for i=1:netc.numLayers
  for j=1:netc.numLayerDelays
    ai = aic{i,j};
    if ~isnumeric(ai) || ~ismatrix(ai) || any(size(ai) ~= [netc.layers{i}.size Q])
      msg = ['Ai{' num2str(i) ',' num2str(j) '} is not a ' num2str(netc.numInputs) '-by-' num2str(netc.numInputDelays) ' numeric array.'];
      error('nnet:data:IncorrectDimensions',msg);
    end
  end
end

% Allocate Input States
xio = cell(neto.numInputs,neto.numInputDelays);
for i=1:neto.numInputs
  xio(i,:) = {nan(neto.inputs{i}.size,Q)};
end

% Keep Original Input States
delayShift = neto.numInputDelays - netc.numInputDelays;
xio(1:netc.numInputs,(1:netc.numInputDelays)+delayShift) = xic;

% Convert Closed Feedback Layer States to Input States
% by reverse applying input processing
for i=1:netc.numLayers
  if netc.outputConnect(i)
    if strcmp(netc.outputs{i}.feedbackMode,'closed')
      j = neto.outputs{i}.feedbackInput;
      numDelays = min(neto.numInputDelays,netc.numLayerDelays);
      delayShift1 = netc.numLayerDelays - numDelays;
      delayShift2 = neto.numInputDelays - numDelays;
      for ts=1:numDelays
        ai = aic(i,ts+delayShift1);
        for k=length(neto.inputs{j}.processFcns):-1:1
          fcn = neto.inputs{j}.processFcns{k};
          settings = neto.inputs{j}.processSettings{k};
          ai = feval(fcn,'reverse',ai,settings);
        end
        xio(j,ts+delayShift2) = ai;
      end
    end
  end
end

% Keep Layer States
delayShift = netc.numLayerDelays - neto.numLayerDelays;
aio = aic(:,(1:neto.numLayerDelays)+delayShift);
