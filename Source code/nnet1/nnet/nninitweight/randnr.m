function out1 = randnr(in1,in2,in3,in4,in5,in6)
%RANDNR Normalized row weight initialization function.
%
%  <a href="matlab:doc randnr">randnr</a> initializes weights with random normalized rows.
%
%  <a href="matlab:doc randnr">randnr</a>(S,R) takes the number of neurons (rows) and number of input
%  elements (columns) and returns an SxR matrix of random signed values
%  with rows normalized to a length of 1.
%
%  Here initial weights are calculated for a 5 neuron layer from a
%  3 element input.
%
%    w = <a href="matlab:doc randnr">randnr</a>(5,3)
%  
%  See also RANDNC.

% Mark Beale, 1-31-92
% Copyright 1992-2010 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Weight/Bias Initialization Functions.

  persistent INFO;
  if isempty(INFO)
    if nnet.test.flags('initWeightInfoTestFcns')
      INFO = nnet.test.initWeightInfoTestFcns;
    else
      INFO = get_info;
    end
  end
  if (nargin < 1), error(message('nnet:Args:NotEnough')); end
  if ischar(in1)
    switch lower(in1)
      case 'info', out1 = INFO;
      case 'configure'
        out1 = configure_weight(in2);
      case 'initialize'
        switch(upper(in3))
        case {'IW'}
          if INFO.initInputWeight
            if in2.inputConnect(in4,in5)
              out1 = initialize_input_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          else
            nnerr.throw([upper(mfilename) ' does not initialize input weights.']);
          end
        case {'LW'}
          if INFO.initLayerWeight
            if in2.layerConnect(in4,in5)
              out1 = initialize_layer_weight(in2,in4,in5,in6);
            else
              out1 = [];
            end
          else
            nnerr.throw([upper(mfilename) ' does not initialize layer weights.']);
          end
        case {'B'}
          if INFO.initBias
            if in2.biasConnect(in4)
              out1 = initialize_bias(in2,in4);
            else
              out1 = [];
            end
          else
            nnerr.throw([upper(mfilename) ' does not initialize biases.']);
          end
        otherwise,
          error(message('nnet:Args:UnrecValue'));
        end
      otherwise
        try
          out1 = eval(['INFO.' in1]);
        catch me,
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    if (nargin == 1)
      if INFO.initFromRows
        out1 = new_value_from_rows(in1);
      else
        nnerr.throw([upper(mfilename) ' cannot initialize from rows.']);
      end
    elseif (nargin == 2)
      if numel(in2) == 1
        if INFO.initFromRowsCols
          out1 = new_value_from_rows_cols(in1,in2);
        else
          nnerr.throw([upper(mfilename) ' cannot initialize from rows and columns.']);
        end
      elseif size(in2,2) == 2
        if INFO.initFromRowsRange
          out1 = new_value_from_rows_range(in1,minmax(in2));
        else
          nnerr.throw([upper(mfilename) ' cannot initialize from rows and ranges.']);
        end
      elseif size(in2,2) > 2
        if INFO.initFromRowsInput
          out1 = new_value_from_rows_inputs(in1,minmax(in2));
        else
          nnerr.throw([upper(mfilename) ' cannot initialize from rows and inputs.']);
        end
      else
        error(message('nnet:randnr:SecondArgNotScalarOr2Col'));
      end
    else
      error(message('nnet:Args:TooManyInputArgs'));
    end
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnWeightInit(mfilename,'Random Normalized Row',7.0,...
    false,true,true, true,true,true,true, true);
end

function settings = configure_weight(inputs)
  settings.inputSize = size(inputs,1);
end

function w = initialize_input_weight(net,i,j,config)
  w = normr(rands(net.layers{i}.size,config.inputSize));
end

function w = initialize_layer_weight(net,i,j,config)
  w = normr(rands(net.layers{i}.size,config.inputSize));
end

function b = initialize_bias(net,i)
  error(message('nnet:NNInit:InitBNotSupported'));
end

function x = new_value_from_rows(rows)
  x = ones(rows,1);
end

function x = new_value_from_rows_cols(rows,cols)
  x = normr(rands(rows,cols));
end

function x = new_value_from_rows_range(rows,range)
  x = normr(rands(rows,size(range,1)));
end

function x = new_value_from_rows_inputs(rows,inputs)
  x = normr(rands(rows,size(inputs,1)));
end
