function [out1,out2] = performance_fcn(in1,in2,in3)
%NN_PERFORMANCE_FCN Training function type.

% Copyright 2010-2014 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Type Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if nargin < 1, error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch (in1)
      
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'isa'
        % this('isa',value)
        out1 = isempty(type_check(in2));
        
      case {'check','assert','test'}
        % [*err] = this('check',value,*name)
        nnassert.minargs(nargin,2);
        if nargout == 0
          err = type_check(in2);
        else
          try
            err = type_check(in2);
          catch me
            out1 = me.message;
            return;
          end
        end
        if isempty(err)
          if nargout>0,out1=''; end
          return;
        end
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout==0, err = nnerr.value(err,'Value'); end
        if nargout > 0
          out1 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'format'
        % [x,*err] = this('format',x,*name)
        err = type_check(in2);
        if isempty(err)
          out1 = strict_format(in2);
          if nargout>1, out2=''; end
          return
        end
        out1 = in2;
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout < 2, err = nnerr.value(err,'Value'); end
        if nargout>1
          out2 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    error(message('nnet:Args:Unrec1'))
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnFunctionType(mfilename,'Performance Function',7,...
    7,fullfile('nnet','nnperformance'));
end

function err = type_check(fcn)

  % Reproducable Random Stream
  rs = RandStream('mt19937ar','seed',1);
    
  % ---------- FCN
  
  % Function name is a string
  err = nntype.string('check',fcn);
  if ~isempty(err), return; end
  FCN = upper(fcn);
  
  % On path
  if isempty(nnpath.fcn2file(fcn))
    err = [FCN ' is not a function on the MATLAB path.'];
    return;
  end
  
  % ---------- FCN.NAME
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.name']))
    err = ['Package function +' FCN '/name does not exist.'];
    return
  end
  
  % Name must be a string
  err = nntype.string('check',feval([fcn '.name']));
  if ~isempty(err), err = nnerr.value(err,'VALUE.name'); return; end
    
  % ---------- FCN.PARAMETER_INFO
  
  % Package function must exist
  if isempty(nnpath.fcn2file([fcn,'.parameterInfo']))
    err = ['Package function +' FCN '/parameterInfo does not exist.'];
    return
  end
  
  % Must return array of parameter info
  param_info = feval([fcn '.parameterInfo']);
  for i=1:length(param_info)
    pi = param_info(i);
    if ~isa(pi,'nnetParamInfo')
      err = ['Package function +' FCN '/parameterInfo does not return array of nnetParamInfo.'];
      return
    end
  end
  
  % ---------- FCN(...)
  
  % Performance
  defaultParam = nn_modular_fcn.parameter_defaults(fcn);
  x = 0:0.1:1;
  t = rs.rand(size(x));
  net = feedforwardnet;
  net = configure(net,x,t);
  y = net(x);
  ew = rs.rand(size(t));
  perf = feval(fcn,net,t,y,ew,defaultParam);
  
  % Backprop
  defaultParam = nn_modular_fcn.parameter_defaults(fcn);
  y = 0.1:0.1:0.9;
  t = rs.rand(size(y));
  deltay = 1e-8;
  y2 = y + deltay;
  e = t - y;
  e2 = t - y2;
  perf1 = feval([fcn '.apply'],t,y,e,defaultParam);
  perf2 = feval([fcn '.apply'],t,y2,e2,defaultParam);
  d = feval([fcn '.backprop'],t,y,e,defaultParam);
  d2 = (perf2-perf1)/deltay;
  diff = max(abs(d-d2));
  if (diff > 1e-5)
    err = 'Backprop derivative is not accurate';
    return
  end
  
  % Forwardprop
  defaultParam = nn_modular_fcn.parameter_defaults(fcn);
  y = 0.1:0.1:0.9;
  t = rs.rand(size(y));
  dy = rs.rand(size(t));
  deltay = 1e-8;
  y2 = y + deltay;
  e = t - y;
  e2 = t - y2;
  perf1 = feval([fcn '.apply'],t,y,e,defaultParam);
  perf2 = feval([fcn '.apply'],t,y2,e2,defaultParam);
  d1 = feval([fcn '.forwardprop'],dy,t,y,e,defaultParam);
  d2 = dy .* (perf2-perf1)/deltay;
  diff = max(abs(d1-d2));
  if (diff > 1e-5)
    err = 'Backprop derivative is not accurate';
    return
  end
end

function x = strict_format(x)
  x = lower(x);
end


