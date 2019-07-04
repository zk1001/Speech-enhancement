function out1 = plotsompos(varargin)
%PLOTSOMPOS Plot self-organizing map weight positions.
%
% <a href="matlab:doc plotsompos">plotsompos</a>(net) takes a self-organizing map network and plots the
% weights of each neuron in the input space, and showing the connections
% between adjecent neurons.
%
% <a href="matlab:doc plotsompos">plotsompos</a>(net,inputs) plots the input data along side the weights.
%
% Here a self-organizing map is trained to classify iris flowers:
%
%    x = <a href="matlab:doc iris_dataset">iris_dataset</a>;
%    net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%    net = <a href="matlab:doc train">train</a>(net,x);
%    y = net(x)
%    <a href="matlab:doc plotsompos">plotsompos</a>(net,x);
%
% See also plotsomhits, plotsomnc, plotsomnd, plotsomplanes, plotsomtop.

% Copyright 2007-2014 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Transfer Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if nargin == 0
    fig = nnplots.find_training_plot(mfilename);
    if nargout > 0
      out1 = fig;
    elseif ~isempty(fig)
      figure(fig);
    end
    return;
  end
  in1 = varargin{1};
  if ischar(in1)
    switch in1
      case 'info',
        out1 = INFO;
      case 'data_suitable'
        data = varargin{2};
        out1 = nnet.train.isNotParallelData(data);
      case 'suitable'
        [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
        [net,tr,signals] = deal(args{2:end});
        update_args = standard_args(net,tr,signals);
        unsuitable = unsuitable_to_plot(param,update_args{:});
        if nargout > 0
          out1 = unsuitable;
        elseif ~isempty(unsuitable)
          for i=1:length(unsuitable)
            disp(unsuitable{i});
          end
        end
      case 'training_suitable'
        [net,tr,signals,param] = deal(varargin{2:end});
        update_args = training_args(net,tr,signals,param);
        unsuitable = unsuitable_to_plot(param,update_args{:});
        if nargout > 0
          out1 = unsuitable;
        elseif ~isempty(unsuitable)
          for i=1:length(unsuitable)
            disp(unsuitable{i});
          end
        end
      case 'training'
        [net,tr,signals,param] = deal(varargin{2:end});
        update_args = training_args(net,tr,signals);
        fig = nnplots.find_training_plot(mfilename);
        if isempty(fig)
          fig = figure('Visible','off','Tag',['TRAINING_' upper(mfilename)]);
          plotData = setup_figure(fig,INFO,true);
        else
          plotData = get(fig,'UserData');
        end
        set_busy(fig);
        unsuitable = unsuitable_to_plot(param,update_args{:});
        if isempty(unsuitable)
          set(0,'CurrentFigure',fig);
          plotData = update_plot(param,fig,plotData,update_args{:});
          update_training_title(fig,INFO,tr)
          nnplots.enable_plot(plotData);
        else
          nnplots.disable_plot(plotData,unsuitable);
        end
        fig = unset_busy(fig,plotData);
        if nargout > 0, out1 = fig; end
      case 'close_request'
        fig = nnplots.find_training_plot(mfilename);
        if ~isempty(fig),close_request(fig); end
      case 'check_param'
        out1 = ''; % TODO
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
    update_args = standard_args(args{:});
    if ischar(update_args)
      nnerr.throw(update_args);
    end
    [plotData,fig] = setup_figure([],INFO,false);
    unsuitable = unsuitable_to_plot(param,update_args{:});
    if isempty(unsuitable)
      plotData = update_plot(param,fig,plotData,update_args{:});
      nnplots.enable_plot(plotData);
    else
      nnplots.disable_plot(plotData,unsuitable);
    end
    set(fig,'Visible','on');
    drawnow;
    if nargout > 0, out1 = fig; end
  end
end

function set_busy(fig)
  set(fig,'UserData','BUSY');
end

function close_request(fig)
  ud = get(fig,'UserData');
  if ischar(ud)
    set(fig,'UserData','CLOSE');
  else
    delete(fig);
  end
  drawnow;
end

function fig = unset_busy(fig,plotData)
  ud = get(fig,'UserData');
  if ischar(ud) && strcmp(ud,'CLOSE')
    delete(fig);
    fig = [];
  else
    set(fig,'UserData',plotData);
  end
  drawnow;
end

function tag = new_tag
  tagnum = 1;
  while true
    tag = [upper(mfilename) num2str(tagnum)];
    fig = nnplots.find_plot(tag);
    if isempty(fig), return; end
    tagnum = tagnum+1;
  end
end

function [plotData,fig] = setup_figure(fig,info,isTraining)
  PTFS = nnplots.title_font_size;
  if isempty(fig)
    fig = get(0,'CurrentFigure');
    if isempty(fig) || strcmp(get(fig,'NextPlot'),'new')
      if isTraining
        tag = ['TRAINING_' upper(mfilename)];
      else
        tag = new_tag;
      end
      fig = figure('Visible','off','Tag',tag);
      if isTraining
        set(fig,'CloseRequestFcn',[mfilename '(''close_request'')']);
      end
    else
      clf(fig);
      set(fig,'Tag','');
      set(fig,'Tag',new_tag);
    end
  end
  set(0,'CurrentFigure',fig);
  ws = warning('off','MATLAB:Figure:SetPosition');
  plotData = setup_plot(fig);
  warning(ws);
  if isTraining
    set(fig,'NextPlot','new');
    update_training_title(fig,info,[]);
  else
    set(fig,'NextPlot','replace');
    set(fig,'Name',[info.name ' (' mfilename ')']);
  end
  set(fig,'NumberTitle','off','ToolBar','none');
  plotData.CONTROL.text = uicontrol('Parent',fig,'Style','text',...
    'Units','normalized','Position',[0 0 1 1],'FontSize',PTFS,...
    'FontWeight','bold','ForegroundColor',[0.7 0 0]);
  set(fig,'UserData',plotData);
end

function update_training_title(fig,info,tr)
  if isempty(tr)
    epochs = '0';
    stop = '';
  else
    epochs = num2str(tr.num_epochs);
    if isempty(tr.stop)
      stop = '';
    else
      stop = [', ' tr.stop];
    end
  end
  set(fig,'Name',['Neural Network Training ' ...
    info.name ' (' mfilename '), Epoch ' epochs stop]);
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnPlot(mfilename,'SOM Weight Positions',7.0,[]);
end

function args = training_args(net,tr,data)
  inputs = data.X;
  args = {net inputs};
end

function args = standard_args(varargin)
  net = varargin{1};
  if nargin >= 2
    inputs = varargin{2};
    inputs = nntype.data('format',inputs);
  else
    inputs = {};
  end
  args = {net,inputs};
end

function plotData = setup_plot(fig)
  plotData.created = false;
  plotData.axis = subplot(1,1,1);
end

function fail = unsuitable_to_plot(param,net,input)
  if net.inputs{1}.processedSize == 0
    fail = 'Network has no processed inputs.';
  elseif (net.numLayers < 1)
    fail = 'Network has no layers.';
  elseif (net.layers{1}.size == 0)
    fail = 'Layer has no neurons.';
  elseif isempty(net.layers{1}.distanceFcn)
    fail = 'Layer 1 does not have a distance function.';
  elseif isempty(net.layers{1}.topologyFcn)
    fail = 'Layer 1 does not have a topology function.';
  else
    fail = '';
  end
end

function plotData = update_plot(param,fig,plotData,net,inputs)
  
  if (~plotData.created)
    set(fig,'NextPlot','replace');
    a = plotData.axis;
    set(a,...
      'DataAspectRatio',[1 1 1],...
      'Box','on',...
      'Color',[1 1 1])
    hold on

    % Setup neurons
    plotData.inputs = plot([NaN NaN],[NaN NaN],'.g','MarkerSize',10);
    plotData.links = plot([NaN NaN],[NaN NaN],'r');
    plotData.weights = plot([NaN NaN],[NaN NaN],'.','MarkerSize',20,'Color',[0.4 0.4 0.6]);

    title(a,'SOM Weight Positions');
    xlabel(a,'Weight 1');
    ylabel(a,'Weight 2');
    
    set(fig,'UserData',plotData);
    set(fig,'NextPlot','new');
    plotData.created = true;
  end

  weights = net.IW{1,1};
  [numNeurons,numDimensions] = size(weights);
  if numDimensions > 3
    weights = weights(:,1:3);
  else
    weights = [weights zeros(numNeurons,3-numDimensions)];
  end

  % Inputs
  if ~isempty(inputs)
    inputs = inputs{1,1};
    [numInputs,numSamples] = size(inputs);
    if numDimensions == 1
      fillInputs = zeros(1,numSamples);
      set(plotData.inputs,'XData',inputs(1,:),'YData',fillInputs,'ZData',fillInputs-1);
    elseif numDimensions == 2
      fillInputs = zeros(1,numSamples);
      set(plotData.inputs,'XData',inputs(1,:),'YData',inputs(2,:),'ZData',fillInputs-1);
    else
      set(plotData.inputs,'XData',inputs(1,:),'YData',inputs(2,:),'ZData',inputs(3,:));
    end
  else
    set(plotData.inputs,'XData',[NaN NaN],'YData',[NaN NaN],'ZData',[NaN NaN]);
  end

  % Links
  neighbors = sparse(tril(net.layers{1}.distances <= 1.001) - eye(numNeurons));
  numEdges = sum(sum(neighbors));

  linkx = nan(3,numEdges);
  linky = nan(3,numEdges);
  linkz = nan(3,numEdges);
  k = 1;
  for i=1:numNeurons
    for j=find(neighbors(i,:))
      linkx(1:2,k) = weights([i j],1);
      linky(1:2,k) = weights([i j],2);
      linkz(1:2,k) = weights([i j],3);
      k = k + 1;
    end
  end
  set(plotData.links,'XData',linkx(:)','YData',linky(:)','ZData',linkz(:)');

  % Weights
  if numDimensions == 3
    set(plotData.weights,'XData',weights(:,1)','YData',weights(:,2)','ZData',weights(:,3)');
  else
    fillWeights = ones(1,numNeurons);
    set(plotData.weights,'XData',weights(:,1)','YData',weights(:,2)','ZData',fillWeights);
  end

  % Axis
  if numDimensions == 2
    set(plotData.axis,'View',[0 90])
  end
end
