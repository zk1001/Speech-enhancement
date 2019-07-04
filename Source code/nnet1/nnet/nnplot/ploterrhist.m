function out1 = ploterrhist(varargin)
%PLOTERRHIST Plot error histogram.
%
% <a href="matlab:doc ploterrhist">ploterrhist</a>(errors) takes error data and plots a histogram.
%
% <a href="matlab:doc ploterrhist">ploterrhist</a>(errors1'name1',errors2,name2,...) plots multiple error sets.
%
% <a href="matlab:doc ploterrhist">ploterrhist</a>(...,'bins',bins) plots using an optional parameter that
% overrides the default number of error bins (20).
%
% Here a feed-forward network is used to solve a simple fitting problem:
%
%   [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%   net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%   net = <a href="matlab:doc train">train</a>(net,x,t);
%   y = net(x);
%   e = t - y;
%   <a href="matlab:doc ploterrhist">ploterrhist</a>(e,'bins',30)
%    
% See also plotregression, ploterrcorr, plotinerrcorr.

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
  info = nnfcnPlot(mfilename,'Error Histogram',7.0,[...
  nnetParamInfo('bins','Number of Bins','nntype.pos_int_scalar',20,...
      'Number of bins to divide errors between.'), ...
  ]);
end

function args = training_args(net,tr,data)
  y = nncalc.y(net,data.X,data.Xi,data.Ai);
  trainColor = [0 0 1];
  t = gmultiply(data.T,data.train.mask);
  e = {gsubtract(t,y)};
  names = {'Training'};
  colors = {trainColor};
  if data.val.enabled
    valColor = [0 0.8 0];
    t = gmultiply(data.T,data.val.mask);
    e = [e {gsubtract(t,y)}];
    names = [names {'Validation'}];
    colors = [colors {valColor}];
  end
  if data.test.enabled
    testColor = [1 0 0];
    t = gmultiply(data.T,data.test.mask);
    e = [e {gsubtract(t,y)}];
    names = [names {'Test'}];
    colors = [colors {testColor}];
  end
  args = {e,names,colors,'= Targets - Outputs'};
end

function args = standard_args(varargin)
  colors = {[0 0 1],[0 0.8 0],[1 0 0]};
  lastArg = varargin{end};
  if ischar(lastArg) && strcmp(lastArg,'T-Y')
    note = '= Targets - Outputs';
    varargin(end) = [];
  else
    note = '';
  end
  if length(varargin) < 1
    args = 'Not enough input arguments.';
  elseif length(varargin) == 1
    % ploterrhist(e)
    e = nntype.data('format',varargin{1});
    args = {{e},{''},colors(1),note};
  else
    % ploterrhist(e1,name1,...)
    count = floor(length(varargin)/2);
    if (length(varargin) ~= count*2)
      error(message('nnet:Args:IncorrectNum'));
    end
    e = cell(1,count);
    names = cell(1,count);
    c = cell(1,count);
    for i=1:count
      e{i} = nntype.data('format',varargin{i*2-1});
      names{i} = nntype.string('format',varargin{i*2});
      if (i<length(colors))
        c{i} = colors{i};
      else
        c{i} = rand(1,3);
      end
    end
    args = {e,names,colors,note};
  end
end

function plotData = setup_plot(fig)
  PTFS = nnplots.title_font_size;
  errorColor = [1 0.6 0];
  hold on
  plotData.bars(1) = bar(0:10,'Visible', 'off');
  plotData.bars(2) = bar(0:10,'Visible', 'off');
  plotData.bars(3) = bar(0:10,'Visible', 'off');
  plotData.bars(4) = bar(0:10,'Visible', 'off');
  plotData.errorLine = line([0 0],[NaN NaN],'Color',errorColor,'LineWidth',2);
  plotData.bars = fliplr(plotData.bars);
  p = get(gca,'Position');
  set(gca,'Position',p + [0 0.12 0 -0.12])
  plotData.title = title('Error Histogram','FontWeight','bold','FontSize',PTFS);
  plotData.ylabel = ylabel('Instances','FontWeight','bold','FontSize',PTFS);
  %plotData.xlabel = xlabel('Error Bins','fontweight','bold','fontsize',PTFS);
  plotData.xlabels = [];
  plotData.axis = gca;
  plotData.numSignals = 0;
  %x = get(gca,'xlabel');
  %p = get(x,'position');
  %set(x,'position',p + [0 0 0]);
  plotData.xlabel = text(0.5,-0.22,'Error Values','FontSize',PTFS,'FontWeight','bold',...
    'Units','normalized','HorizontalAlignment','center');
  drawnow
end

function fail = unsuitable_to_plot(param,e,names,colors,note)
  fail = '';
end

function plotData = update_plot(param,fig,plotData,e,names,colors,note)
  set(plotData.title,'String',...
    ['Error Histogram with ' num2str(param.bins) ' Bins']);
  delete(plotData.xlabels);
  axis(plotData.axis);

  % Remove empty datasets
  for i=numel(e):-1:1
      if numsamples(e{i}) == 0
          e(i) = [];
          names(i) = [];
          colors(i) = [];
      end
  end
  
  numSignals = length(names);
  [emin,emax] = find_min_and_max_error(e,numSignals);
  
  estep = (emax-emin)/param.bins;
  ebins = emin + ((1:param.bins)-0.5)*estep;
  lastY = 0;
  for i=1:numSignals
    b = plotData.bars(i);
    ei = cell2mat(e{i});
    ei = ei(:)';
    [y,x] = hist(ei,ebins);
    y = y + lastY;
    set(b,'XData',x,'YData',y,'FaceColor',colors{i},...
        'BarWidth',0.8,'Visible','on');
    lastY = y;
  end
  ymax = max(y);
  set(plotData.axis,'XLim',[emin emax],'YLim',[0 ymax*1.1]);
  set(plotData.errorLine,'YData',[0 ymax*1.1])
  if ~isempty(names{1})
    legend([plotData.bars(1:numSignals) plotData.errorLine],names{:},'Zero Error');
  else
    legend(plotData.errorLine,'Zero Error');
  end
  set(plotData.axis,'XTick',ebins);
  for i=(numSignals+1):4
    b = plotData.bars(i);
    set(b,'XData',1:2,'YData',1:2,'Visible','off');
  end
  labels = cell(1,param.bins);
  for i=1:param.bins
    numchar = 4;
    str = sprintf(['%.' num2str(numchar) 'g'],ebins(i));
    while(length(str) > 8)
      numchar = numchar - 1;
      str = sprintf(['%.' num2str(numchar) 'g'],ebins(i));
    end
    labels{i} = str;
  end
  xticks = get(gca,'XTick');
  yticks = get(gca,'YTick');
  ypos = yticks(1)-.1*(yticks(2)-yticks(1));
  plotData.xlabels = text(xticks,repmat(ypos,length(xticks),1),labels,...
    'HorizontalAlignment','right','Rotation',90);
  set(gca,'XTickLabel',[])
  set(plotData.xlabel,'String',['Errors ' note]);
end

function [emin,emax] = find_min_and_max_error(e,numSignals)
emin = NaN;
emax = NaN;
for i=1:numSignals
  ei = cell2mat(e{i});
  ei = ei(:)';
  emin = min(emin,min(ei));
  emax = max(emax,max(ei));
end
if emin == emax
    emin = emin - 1;
    emax = emax + 1;
end
end
