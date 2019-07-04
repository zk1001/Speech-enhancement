function net = trainSoftmaxLayer(X, T, varargin)
% trainSoftmaxLayer   Train a softmax layer for classification
%   net = trainSoftmaxLayer(x, t) trains and returns a softmax layer on the
%   input data x and the targets given by t. The user does not supply a
%   size for the softmax layer, as it will have the same size as the
%   targets.
%
%   x must be a matrix of training samples where each column represents a
%   single sample. t must be a matrix of labels in 1-of-K format, where
%   each column represents a sample, and all of the entries of a column are
%   zero except for a single entry in a row which indicates the class for
%   that sample.
%
%   net = trainSoftmaxLayer(x, t, Name1, Value1, ...) trains and returns a
%   softmax layer on the input data x and the labels given by t, with
%   additional options specified by the following name/value pairs:
%
%       'MaxEpochs'             - The maximum number of training epochs.
%                                 The default is 1000.
%       'LossFunction'          - The loss function for the softmax layer.
%                                 Possible values are 'mse' and
%                                 'crossentropy'. The default is
%                                 'crossentropy'.
%       'ShowProgressWindow'    - Indicates whether the training window
%                                 should be shown during training. The 
%                                 default is true.
%       'TrainingAlgorithm'     - The training algorithm used to train the
%                                 autoencoder. Only 'trainscg' is allowed,
%                                 which is the default.
%
%   Example:
%       Train a softmax layer to perform classification.
%
%       [x,t] = iris_dataset;
%       net = trainSoftmaxLayer(x,t);
%
%   See also trainAutoencoder

%   Copyright 2015 The MathWorks, Inc.

paramsStruct = iParseInputArguments(varargin{:});
net = iCreateSoftmaxLayer(paramsStruct);
net = iTrainSoftmaxLayer(net,X,T);
end

function paramsStruct = iParseInputArguments(varargin)
    p = inputParser;
    
    defaultLossFunction = 'crossentropy';
    validLossFunctions = {'crossentropy','mse'};
    defaultMaxEpochs = 1000;
    defaultShowProgressWindow = true;
    defaultTrainingAlgorithm = 'trainscg';
    validTrainingAlgorithms = {'trainscg'};
    
    addParameter(p, 'LossFunction', defaultLossFunction);
    addParameter(p, 'MaxEpochs', defaultMaxEpochs);
    addParameter(p, 'ShowProgressWindow', defaultShowProgressWindow);
    addParameter(p, 'TrainingAlgorithm', defaultTrainingAlgorithm);
    
    parse(p, varargin{:});
    iAssertLossFunctionIsOneOfTheseStrings(p.Results.LossFunction, validLossFunctions);
    iAssertMaxEpochsIsRealScalarFiniteNumericGreaterThanZero(p.Results.MaxEpochs);
    iAssertShowProgressWindowIsScalarAndReal(p.Results.ShowProgressWindow);
    iAssertTrainingAlgorithmIsOneOfTheseStrings(p.Results.TrainingAlgorithm, validTrainingAlgorithms);
    paramsStruct = p.Results;
end

function softnet = iCreateSoftmaxLayer(paramsStruct)
    softnet = network;
    
    % Define topology
    softnet.numInputs = 1;
    softnet.numLayers = 1;
    softnet.biasConnect = 1;
    softnet.inputConnect(1,1) = 1;
    softnet.outputConnect = 1;
    
    % Set values for labels
    softnet.name = 'Softmax Classifier';
    softnet.layers{1}.name = 'Softmax Layer';
    
    % Define transfer function
    softnet.layers{1}.transferFcn = 'softmax';
    
    % Set parameters
    softnet.performFcn = paramsStruct.LossFunction;
    softnet.trainFcn = paramsStruct.TrainingAlgorithm;
    softnet.trainParam.epochs = paramsStruct.MaxEpochs;
    softnet.trainParam.showWindow = paramsStruct.ShowProgressWindow;
    softnet.divideFcn = 'dividetrain';
end

function net = iTrainSoftmaxLayer(net,X,T)
net = train(net,X,T);
end

function exception = iCreateExceptionFromErrorID(errorID)
exception = MException(errorID, getString(message(errorID)));
end

function iAssertShowProgressWindowIsScalarAndReal(showProgressWindow)
if iIsScalarAndReal(showProgressWindow)
else
    exception = iCreateExceptionFromErrorID('nnet:autoencoder:ShowProgressWindowIsInvalid');
    throwAsCaller(exception);
end
end

function result = iIsScalarAndReal(x)
result = isscalar(x) && isreal(x);
end

function iAssertMaxEpochsIsRealScalarFiniteNumericGreaterThanZero(maxEpochs)
if iIsRealScalarFiniteNumericGreaterThanZero(maxEpochs)
else
    exception = iCreateExceptionFromErrorID('nnet:autoencoder:MaxEpochsIsInvalid');
    throwAsCaller(exception);
end
end

function result = iIsRealScalarFiniteNumericGreaterThanZero(x)
result = isscalar(x) && isnumeric(x) && isreal(x) && (x > 0) && isfinite(x);
end

function iAssertLossFunctionIsOneOfTheseStrings(lossFunction, validLossFunctions)
if iIsOneOfTheseStrings(lossFunction, validLossFunctions)
else
    exception = iCreateExceptionFromErrorID('nnet:autoencoder:LossFunctionIsInvalid');
    throwAsCaller(exception);
end
end

function iAssertTrainingAlgorithmIsOneOfTheseStrings(trainingAlgorithm, validTrainingAlgorithms)
if iIsOneOfTheseStrings(trainingAlgorithm, validTrainingAlgorithms)
else
    exception = iCreateExceptionFromErrorID('nnet:autoencoder:TrainingAlgorithmIsInvalid');
    throwAsCaller(exception);
end
end

function result = iIsOneOfTheseStrings(x, strings)
result = any(strcmp(x, strings));
end
