function out1 = initsompc(in1,in2,in3,in4,in5,in6)
%INITSOMPC Initialize SOM weights with principle components.
%
%  <a href="matlab:doc initsompc">initsompc</a> initializes the weights of an N-dimensional self-organizing map
%  so that the initial weights are distributed across the space spanned
%  by the most significant N principal components of the inputs. This
%  significantly speeds up SOM learning, as the map starts out with a
%  reasonable ordering of the input space.
%
%  <a href="matlab:doc initsompc">initsompc</a>('configure',x) takes inputs X and returns initialization
%  settings for weights associated with that input data.
%
%  <a href="matlab:doc initsompc">initsompc</a>('initialize',net,'IW',i,j,settings) returns new weights
%  for layer i from input j.
%
%  <a href="matlab:doc initsompc">initsompc</a>('initialize',net,'LW',i,j,settings) returns new weights
%  for layer i from layer j.
%
%  <a href="matlab:doc initsompc">initsompc</a>('initialize',net,'b',i) returns new biases for layer i.
%
%  See also SELFORGMAP.

% Copyright 2007-2015 The MathWorks, Inc.


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
            error(message('nnet:initsompc:SecondArgNotScalarOr2Col'));
        end
    else
        error(message('nnet:Args:TooManyInputArgs'));
    end
end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
info = nnfcnWeightInit(mfilename,'Principle Component',7.0,...
    false,true,false, false,false,false,false, false);
end

function settings = configure_weight(x)
[inputSize,numSamples] = size(x);
settings.inputSize = inputSize;
settings.sampleSize = numSamples;
settings.numElements = numel(x);

weightsNeedToBeSet = not(inputSize == 0);
trySVD = settings.sampleSize <= 10000;

if weightsNeedToBeSet
    if trySVD
        ind = ~isfinite(x);
        x(ind) = sign(x(ind));
        posMean = mean(x,2);
        x = bsxfun( @minus, x, posMean );
        [components,gains,encodedInputsT, doneSVD] = iMemorySafeSVD(x);
    else
        doneSVD = false;
    end
    
    if doneSVD
        basis = components*gains;
        stdev = std(encodedInputsT,1,1)';
        posBasis = basis * 2.5 * diag(stdev);
        
        settings.posMean = nnet.array.safeGather(posMean);
        settings.posBasis = nnet.array.safeGather(posBasis);
    else
        settings.inputSize = inputSize;
        settings.mean = nnet.array.safeGather(mean(x,2));
    end
end
end

function [components,gains,encodedInputsT,doneSVD] = iMemorySafeSVD(x)
try
    [components,gains,encodedInputsT] = svd(x);
    doneSVD = true;
catch exception
    if ~isequal(exception.identifier, 'MATLAB:array:SizeLimitExceeded')
        rethrow(exception);
    end
    components = [];
    gains = [];
    encodedInputsT = [];
    doneSVD = false;
end
end

function w = initialize_input_weight(net,i,j,config)
inputSize = config.inputSize;

weightsDoNotNeedToBeSet = (inputSize == 0);
doneSVD = isfield(config, 'posBasis');

if weightsDoNotNeedToBeSet
    w = zeros(0,net.layers{i}.size);
elseif doneSVD
    sampleSize = config.sampleSize;
    posMean = config.posMean;
    posBasis = config.posBasis;
    numNeurons = net.layers{i}.size;
    dimensions = net.layers{i}.dimensions;
    numDimensions = length(dimensions);
    [~,dimOrder] = sort(dimensions,2,'descend');
    restoreOrder = [sort(dimOrder) (numDimensions+1):min(inputSize,sampleSize)]; %%
    if numDimensions > inputSize
        posBasis = [posBasis rands(inputSize,numDimensions-inputSize)*0.001];
    end
    posBasis = posBasis(:,restoreOrder);
    if (sampleSize < inputSize)
        posBasis = [posBasis zeros(inputSize,inputSize-sampleSize)];
    end
    pos = net.layers{i}.positions;
    if inputSize > numDimensions
        pos = [pos; zeros(inputSize-numDimensions,numNeurons)];
    end
    pos = normalize_positions(pos);
    w = spread_positions(pos,posMean,posBasis)';
else
    w = repmat(config.mean',net.layers{i}.size,1);
end
end

function w = initialize_layer_weight(net,i,j,config)
error(message('nnet:NNInit:InitLWNotSupported'));
end

function b = initialize_bias(net,i)
error(message('nnet:NNInit:InitBNotSupported'));
end

function x = new_value_from_rows(rows)
error(message('nnet:NNInit:InitRowsNotSupported'));
end

function x = new_value_from_rows_cols(rows,cols)
error(message('nnet:NNInit:InotRowsColsNotSupported'));
end

function x = new_value_from_rows_range(rows,range)
error(message('nnet:NNInit:InitRowsRangesNotSupported'));
end

function x = new_value_from_rows_inputs(rows,x)
error(message('nnet:NNInit:InitRowsInputsNotSupported'));
end

%%  HELPER FUNCTIONS

function pos = normalize_positions(pos)
% Map min-max position values to [-1,+1] interval.
numPos = size(pos,2);
minPos = min(pos,[],2);
maxPos = max(pos,[],2);
difPos = maxPos-minPos;
difPos(difPos == 0) = 1;
copyIndex = ones(1,numPos);
minPos = minPos(:,copyIndex);
difPos = difPos(:,copyIndex);
pos = 2 *((pos-minPos)./difPos) - 1;
end

function pos = spread_positions(pos,posMean,posBasis)
% Map mean-basis position values from 0 mean, identity basis.
numPos = size(pos,2);
pos = repmat(posMean,1,numPos) + (posBasis * pos);
end
