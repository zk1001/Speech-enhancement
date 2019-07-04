function [out1,out2] = simulink_output_mode(in1,in2,in3)
%NNTYPE_SIMULINK_OUTPUT_MODE Simulink output mode

% Copyright 2010-2011 The MathWorks, Inc.

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
  info = nnfcnType(mfilename,'Simulink output mode',7.0);
end

function err = type_check(x)
  if ~ischar(x)
    err = 'VALUE is not char.';
  elseif size(x,1) ~= 1
    err = 'VALUE is not a single row char array.';
  elseif isempty(nnstring.first_match(lower(x),{'','none','scope','display','port','workspace'}))
    err = 'VALUE is not '', ''none'', ''scope'', ''display'', ''port'' or ''workspace''.';
  else
    err = '';
  end
end

function x = strict_format(x)
  x = lower(x);
  if isempty(x), x = 'none'; end
end
