function out1 = plotsomtop(varargin)
%PLOTSOMTOP Plot self-organizing map topology.
%
% <a href="matlab:doc plotsomtop">plotsomtop</a>(net) takes a self-organizing map network and plots the
% topology of its neurons.
%
% Here a self-organizing map is trained to classify iris flowers:
%
%    net = <a href="matlab:doc selforgmap">selforgmap</a>([8 8]);
%    <a href="matlab:doc plotsomtop">plotsomtop</a>(net);
%
% This plot supports SOM networks with HEXTOP and GRIDTOP topologies,
% but not TRITOP or RANDTOP.
%
% See also plotsomhits, plotsomnc, plotsomnd, plotsomplanes, plotsompos.

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
        out1 = true;
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
  info = nnfcnPlot(mfilename,'SOM Topology',7.0,[]);
end

function args = training_args(net,tr,data)
  args = {net};
end

function args = standard_args(varargin)
  net = varargin{1};
  args = {net};
end

function plotData = setup_plot(fig)
  plotData.axis = subplot(1,1,1);
  plotData.numInputs = 0;
  plotData.numNeurons = 0;
  plotData.topologyFcn = '';
  plotData.dimensions = 0;
end

function fail = unsuitable_to_plot(param,net,input)
  if (net.numLayers < 1)
    fail = 'Network has no layers.';
  elseif (net.layers{1}.size == 0)
    fail = 'Layer has no neurons.';
  elseif ~any([1 2] == length(net.layers{1}.dimensions))
    fail = 'Layer neurons are not arranged in one or two dimensions.';
  elseif isempty(net.layers{1}.distanceFcn)
    fail = 'Layer 1 does not have a distance function.';
  elseif isempty(net.layers{1}.topologyFcn)
    fail = 'Layer 1 does not have a topology function.';
  elseif ~strcmp(net.layers{1}.topologyFcn,'gridtop') ...
      && ~strcmp(net.layers{1}.topologyFcn,'hextop')
    fail = 'Only HEXTOP and GRIDTOP topology functions supported.';
  else
    fail = '';
  end
end

function plotData = update_plot(param,fig,plotData,net)

  numInputs = net.inputs{1}.processedSize;
  numNeurons = net.layers{1}.size;
  topologyFcn = net.layers{1}.topologyFcn;
  dimensions = net.layers{1}.dimensions;

  if strcmp(topologyFcn,'gridtop')  
    shapex = [-1 1 1 -1]*0.5;
    shapey = [1 1 -1 -1]*0.5;
    dx = 1;
    dy = 1;
  elseif strcmp(topologyFcn,'hextop')
    z = sqrt(0.75)/3;
    shapex = [-1 0 1 1 0 -1]*0.5;
    shapey = [1 2 1 -1 -2 -1]*z;
    dx = 1;
    dy = sqrt(0.75);
  else
    shapex = cos(0:.1:2*pi)*0.5;
    shapey = sin(0:.1:2*pi)*0.5;
    dx = 1;
    dy = sqrt(0.75);
  end

  pos = net.layers{1}.positions;
  dimensions = net.layers{1}.dimensions;
  numDimensions = length(dimensions);
  if (numDimensions == 1)
    dim1 = dimensions(1);
    dim2 = 1;
    pos = [pos; zeros(1,size(pos,2))];
  elseif (numDimensions > 2)
    pos = pos(1:2,:);
    dim1 = dimensions(1);
    dim2 = dimensions(2);
  else
    dim1 = dimensions(1);
    dim2 = dimensions(2);
  end

  if (plotData.numInputs ~= numInputs) || any(plotData.dimensions ~= dimensions) ...
      || ~strcmp(plotData.topologyFcn,topologyFcn)
    set(fig,'NextPlot','replace');
    plotData.numInputs = numInputs;
    plotData.dimensions = dimensions;
    plotData.topologyFcn = topologyFcn;

    a = plotData.axis;
    cla(a);
    set(a,...
      'DataAspectRatio',[1 1 1],...
      'Box','on',...
      'Color',[1 1 1]*0.5)
    hold on

    % Setup neurons
    for i=1:numNeurons
      fill(pos(1,i)+shapex,pos(2,i)+shapey,[1 1 1], ...
        'FaceColor',[0.4 0.4 0.6], ...
        'EdgeColor',[1 1 1]*0.8);
    end

    set(a,'XLim',[-1 (dim1-0.5)*dx + 1]);
    set(a,'YLim',[-1 (dim2-0.5)*dy + 0.5]);
    title(a,'SOM Topology');
  end
end


