function out1 = rands(in1,in2,in3,in4,in5,in6)
%RANDS Symmetric random weight/bias initialization function.
%
%  <a href="matlab:doc rands">rands</a> initializes weights with random signed values.
%
%  <a href="matlab:doc rands">rands</a>(S,R) takes the number of neurons (rows) and number of input
%  elements (columns) and returns an SxR matrix of random signed values.
%
%  Here initial weights are calculated for a 5 neuron layer from a
%  3 element input.
%
%    w = <a href="matlab:doc rands">rands</a>(5,3)
%
%  See also RANDSMALL, RANDNR, RANDNC, INITWB, INITLAY, INIT

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2011 The MathWorks, Inc.

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
        error(message('nnet:rands:SecondArgNotScalarOr2Col'));
      end
    else
      error(message('nnet:Args:TooManyInputArgs'));
    end
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnWeightInit(mfilename,'Random Symmetric',7.0,...
    true,true,true, true,true,true,true, true);
end

function settings = configure_weight(inputs)
  settings = struct;
end

function w = initialize_input_weight(net,i,j,config)
  w = 2*rand(net.inputWeights{i,j}.size)-1;
end

function w = initialize_layer_weight(net,i,j,config)
  w = 2*rand(net.layerWeights{i,j}.size)-1;
end

function b = initialize_bias(net,i)
  b = 2*rand(net.layers{i}.size,1)-1;
end

function x = new_value_from_rows(rows)
  x = 2*rand(rows,1)-1;
end

function x = new_value_from_rows_cols(rows,cols)
  x = 2*rand(rows,cols)-1;
end

function x = new_value_from_rows_range(rows,range)
  x = new_value_from_rows_cols(rows,size(range,1));
end

function x = new_value_from_rows_inputs(rows,inputs)
  x = new_value_from_rows_cols(rows,size(inputs,1));
end

