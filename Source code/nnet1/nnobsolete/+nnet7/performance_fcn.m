function out1 = performance_fcn(fcn,varargin)

% Copyright 2012 The MathWorks, Inc.

info = nnModuleInfo(fcn);
in1 = varargin{1};
if ischar(in1)
  switch (in1)

    % NNET 7.0 Compatibility

    case 'dperf_dwb'
      [args,param,nargs] = nnparam.extract_param(varargin(2:end),info.defaultParam);
      nnassert.minargs(nargs,1);
      net = nntype.network('format',args{1},'NET');
      out1 = info.dperf_dwb(getwb(net),param);

    case {'info','subfunctions'}
      out1 = info;
      
    case {'pdefaults','defaultParam'}
      out1 = info.defaultParam;
      
    case 'parameters'
      out1 = info.parameterInfo;
      
    case 'name'
      out1 = info.name;
      
    case 'pnames'
      out1 = fieldnames(info.defaultParam);

    % NNET 6.0 Compatibility

    case 'dy'
      if nargin < 6, param = info.defaultParam; else param = varargin{6}; end
      if isempty(param), param = info.defaultParam; end
      e = varargin{2};
      y = varargin{3};
      %perf = varargin{5};
      wasMatrix = ~iscell(e);
      if wasMatrix, e = {e}; y = {y}; end
      t = gadd(e,y);
      net.performFcn = info.mfunction;
      out1 = nncalc.dperform(net,t,y,{1},param);
      if (wasMatrix), out1 = out1{1}; end

    case 'dx'
      if nargin < 6, param = info.defaultParam; else param = varargin{6}; end
      if isempty(param), param = info.defaultParam; end
      wb = varargin{4};
      if isstruct(wb) || isa(wb,'network')
        wb = getwb(wb);
      end
      out1 = info.dperf_dwb(wb,param);
  end
else
  
  % NNET 4.0 and 6.0 Compatibility
  
  if (nargin == 2)
    % mse(e)
    e = in1;
  else
    in2 = varargin{2};
    if iscell(in1) && iscell(in2)
      if (nargin >= 4)
        in3 = varargin{3};
        if (iscell(in1) && isnumeric(in3))
          % mse(celle,celly,wb)
          e = in1;
        elseif isnumeric(in1) && isnumeric(in3) && all(size(in1)==(in3))
          % mse(t,y,e)
          e = in1-in2;
        else
          % mse(e,y,wb)
          e = in1;
        end
      else
        % mse(cellt,celle)
        e = gsubtract(in1,in2);
      end
    elseif iscell(in1) && isnumeric(in2)
        % mse(celle,wb)
        e = in1;
    else
      if all(size(in1)==size(in2))
        % mse(t,e)
        e = in1-in2;
      else
        % mse(t,x)
        e = in1;
      end
    end
  end
  if iscell(e), e = cell2mat(e); end
  perfs = info.apply([],[],e);
  dontcare = find(isnan(perfs));
  perfs(dontcare) = 0;
  perf = sum(sum(perfs));
  if info.normalize
    perf = perf / (numel(perfs)-numel(dontcare));
  end
  out1 = perf;
end
  
  
