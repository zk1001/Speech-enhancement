function out1 = narnet(varargin)
%NARNET Nonlinear auto-associative time-series network.
%
%  For an introduction use the Neural Time Series app <a href="matlab: doc ntstool">ntstool</a>.
%  Click <a href="matlab:ntstool">here</a> to launch it.
%
%  Nonlinear autoregressive networks can learn to predict a time series Y
%  given past values of Y.
%
%  <a href="matlab:doc narnet">narnet</a>(feedbackDelays,hiddenSizes,feedbackMode,trainFcn) takes a row
%  vector of output-to-input feedback delays, a row vector of N hidden layer
%  sizes, an 'open' or 'closed' feedback mode and a backpropagation training
%  function, and returns a NAR network.
%
%  Input, output and output layers sizes are set to 0.  These sizes will
%  automatically be configured to match particular data by <a href="matlab:doc train">train</a>. Or the
%  user can manually configure inputs and outputs with <a href="matlab:doc configure">configure</a>.
%
%  Defaults are used if <a href="matlab:doc narnet">narnet</a> is called with fewer arguments.
%  The default arguments are (1:2,10,'<a href="matlab:doc trainlm">trainlm</a>').
%
%  Here a NAR network is used to solve a time series problem.
%
%    t = <a href="matlab:doc simplenar_dataset">simplenar_dataset</a>;
%    net = <a href="matlab:doc narnet">narnet</a>(1:2,10);
%    [X,Xi,Ai,T] = <a href="matlab:doc preparets">preparets</a>(net,{},{},t);
%    net = <a href="matlab:doc train">train</a>(net,X,T,Xi,Ai);
%    view(net)
%    Y = net(X,Xi,Ai);
%    perf = <a href="matlab:doc perform">perform</a>(net,Y,T)
%
%  Closed-loop Form
%
%  Once designed the dynamic network can be converted to closed loop with
%  <a href="matlab:doc closeloop">closeloop</a> and simulated.
%
%    netc = <a href="matlab:doc closeloop">closeloop</a>(net);
%    <a href="matlab:doc view">view</a>(netc)
%    [Xc,Xic,Aic,Tc] = <a href="matlab:doc preparets">preparets</a>(netc,{},{},t);
%    Yc = netc(Xc,Xic,Aic);
%
%  The function <a href="matlab:doc openloop">closeloop</a> reversed this transform.
%
%  Step-Ahead Form
%
%  The open-loop neural network is by default in model form, which means it outputs
%  values at the same time as the real system would.  Note that in the network diagram
%  the minimum delay between inputs and outputs is one.  This delay can be eliminated
%  if we would like predictions of the next output to be returned a timestep ahead
%  of the actual system being modelled.
%
%    nets = removedelay(net);
%    view(net)
%    [Xs,Xis,Ais,Ts] = preparets(nets,{},{},t);
%    Ys = nets(Xs,Xis,Ais);
%
%  The function <a href="matlab:doc adddelay">adddelay</a> reversed this transform.
%
%  Multistep Prediction
%
%  Sometimes it is useful to simulate a network in open-loop form for as long as there
%  is known data T, and then switch to closed-loop to perform multistep prediction.
%
%  The open-loop network is simulated on the first segment, then the network and
%  its current delay states are converted to closed-loop form to perform as many
%  predictions as desired, in this case 5 timesteps.
%
%    [Xo,Xio,Aio,To] = preparets(net,{},{},t);
%    [Y1,Xfo,Afo] = net(Xo,Xio,Aio);
%    [netc,Xic,Aic] = closeloop(net,Xfo,Afo);
%    [Y2,Xfc,Afc] = netc(cell(0,5),Xic,Aic);
%
%  Further predictions can be made by continuing simulation with Xfc and Afc.
%
%  Simulink Diagram
%
%  A Simulink can be produced for any neural networks using the function <a href="matlab:doc gensim">gensim</a>.
%
%    gensim(net)
%
%  See also PREPARETS, CLOSELOOP, REMOVEDELAY, NARNET, TIMEDELAYNET, GENSIM.

% Copyright 2008-2013 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Network Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin > 0) && ischar(varargin{1}) ...
      && ~strcmpi(varargin{1},'hardlim') && ~strcmpi(varargin{1},'hardlims')
    code = varargin{1};
    switch code
      case 'info',
        out1 = INFO;
      case 'check_param'
        err = check_param(varargin{2});
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = err;
      case 'create'
        if nargin < 2, error(message('nnet:Args:NotEnough')); end
        param = varargin{2};
        err = nntest.param(INFO.parameters,param);
        if ~isempty(err), nnerr.throw('Args',err); end
        out1 = create_network(param);
        out1.name = INFO.name;
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' code]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized argument: ''' code ''''])
        end
    end
  else
    [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
    [param,err] = INFO.overrideStructure(param,args);
    if ~isempty(err), nnerr.throw('Args',err,'Parameters'); end
    net = create_network(param);
    net.name = INFO.name;
    out1 = init(net);
  end
end

function v = fcnversion
  v = 7;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnNetwork(mfilename,'NAR Neural Network',fcnversion, ...
    [ ...
    nnetParamInfo('feedbackDelays','Feedback delays','nntype.pos_inc_int_row',[1 2],...
    'Row vector of feedback delays, usually starting with 0.'), ...
    nnetParamInfo('hiddenSizes','Hidden Layer Sizes','nntype.strict_pos_int_row',10,...
    'Sizes of 0 or more hidden layers.'), ...
    nnetParamInfo('feedbackMode','Feedback Loop Mode','nntype.feedback_mode','open',...
    'True for open loop feedback, false for closed loop feedback.'), ...
    nnetParamInfo('trainFcn','Training Function','nntype.training_fcn','trainlm',...
    'Function to train the network.'), ...
    ]);
end

function err = check_param(param)
  if (min(param.feedbackDelays) == 0)
    err = 'Minimum feedback delay is zero causing a zero-delay loop.';
  else
    err = '';
  end
end

function net = create_network(param)

  % Layers
  net = network;
  Nl = length(param.hiddenSizes)+1;
  net.numLayers = Nl;
  net.biasConnect = true(Nl,1);
  [j,i] = meshgrid(1:Nl,1:Nl);
  net.layerConnect = (j == (i-1));
  for i=1:Nl
    if i == Nl
      net.layers{i}.name = 'Output';
    else
      if (Nl == 2)
        net.layers{i}.name = 'Hidden';
      else
        net.layers{i}.name = ['Hidden ' num2str(i)];
      end
      net.layers{i}.size = param.hiddenSizes(i);
      net.layers{i}.transferFcn = 'tansig';
    end
    net.layers{i}.initFcn = 'initnw';
  end
  
  % Feedback Output
  net.outputConnect(Nl) = true;
  net.outputs{Nl}.processFcns = {'removeconstantrows','mapminmax'};
  net.outputs{Nl}.name = 'y';
  net.outputs{Nl}.feedbackMode = 'open';
  net.inputConnect(1,1) = true;
  net.inputWeights{1,1}.delays = param.feedbackDelays;
  
  % Training
  net.divideFcn = 'dividerand';
  net.divideMode = 'time';
  net.performFcn = 'mse';
  net.trainFcn = param.trainFcn;

  % Adaption
  net.adaptFcn = 'adaptwb';
  net.inputWeights{1,1}.learnFcn = 'learngdm';
  net.layerWeights{find(net.layerConnect)'}.learnFcn = 'learngdm';
  net.biases{:}.learnFcn = 'learngdm';

  % Plots
  net.plotFcns = {'plotperform','plottrainstate','ploterrhist','plotregression',...
    'plotresponse','ploterrcorr'};
  
  % Open/Closed Loop
  if strcmp(param.feedbackMode,'closed')
    net = closeloop(net);
  end
end
