function checkThatNetworkIsCompatibleWithMSESparse(net, calcMode)

% Copyright 2014-2015 The MathWorks, Inc.

iThrowErrorIfNetworkHasTimeDelays(net);
iThrowErrorIfNetworkHasUnsupportedNetInputOrWeightFunction(net);
iThrowErrorIfCalculationModeIsGPU(calcMode.mode);
iThrowErrorIfCalculationModeIsParallel(calcMode.mode);
iThrowErrorIfFirstLayerTransferFunctionHasBadOutputRange(net);
iThrowErrorIfNetworkHasMultipleInputs(net.numInputs);
end

function result = iHasUnitOutputRange( transferFunction )
outputRange = feval([transferFunction,'.outputRange']);
result = all( outputRange == [0, 1] );
end

function iThrowErrorIfNetworkHasTimeDelays(net)
if(net.numInputDelays > 0 || net.numLayerDelays > 0 || net.numFeedbackDelays > 0)
    error(message('nnet:msesparse:TimeDelaysNotAllowed'));
end
end

function iThrowErrorIfNetworkHasUnsupportedNetInputOrWeightFunction(net)
for i = 1:net.numLayers
    iThrowErrorIfLayerHasNetProdNetInputFunction(net, i);
    for j = 1:net.numInputs
        iThrowErrorIfInputWeightHasUnsupportedWeightFunction(net,i,j);
    end
    for j = 1:net.numLayers
        iThrowErrorIfLayerWeightHasUnsupportedWeightFunction(net,i,j);
    end
end
end

function iThrowErrorIfLayerHasNetProdNetInputFunction(net, i)
if(strcmp(net.layers{i}.netInputFcn, 'netprod'))
    error(message('nnet:msesparse:NetProdNotAllowed'));
end
end

function iThrowErrorIfInputWeightHasUnsupportedWeightFunction(net,i,j)
if(~isempty(net.inputWeights{i,j}))
    if(~strcmp(net.inputWeights{i,j}.weightFcn,'dotprod'))
        error(message('nnet:msesparse:OnlyDotProdWeightFunctionAllowed'))
    end
end
end

function iThrowErrorIfLayerWeightHasUnsupportedWeightFunction(net,i,j)
if(~isempty(net.layerWeights{i,j}))
    if(~strcmp(net.layerWeights{i,j}.weightFcn,'dotprod'))
        error(message('nnet:msesparse:OnlyDotProdWeightFunctionAllowed'))
    end
end
end

function iThrowErrorIfCalculationModeIsGPU(mode)
if(strcmp(mode,'nnGPU'))
    error(message('nnet:msesparse:GPUNotAllowed'));
end
end

function iThrowErrorIfCalculationModeIsGPUOp(mode)
if(strcmp(mode,'nnGPUOp'))
    error(message('nnet:msesparse:GPUNotAllowed'));
end
end

function iThrowErrorIfCalculationModeIsParallel(mode)
if(strcmp(mode,'nnParallel'))
    error(message('nnet:msesparse:ParallelNotAllowed'));
end
end

function iThrowErrorIfFirstLayerTransferFunctionHasBadOutputRange(net)
layerOrder = nn.layer_order(net);
firstLayerIndex = layerOrder(1);
if(~iHasUnitOutputRange(net.layers{firstLayerIndex}.transferFcn))
    error(message('nnet:msesparse:OutputRangeNotValid'));
end
end

function iThrowErrorIfNetworkHasMultipleInputs(numInputs)
if(numInputs > 1)
    error(message('nnet:msesparse:OnlyOneInputAllowed'));
end
end
