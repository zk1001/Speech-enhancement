function stackedNet = stack(varargin)

%   Copyright 2015 The MathWorks, Inc.

networksToStack = varargin;

iAssertNetworksAreStackable(networksToStack);

numLayers = iGetTotalNumberOfLayers(networksToStack);
stackedNet = iCreateStackedNetworkTopology(numLayers);

stackedNet.name = 'Stacked Network';
stackedNet.inputs{1} = networksToStack{1}.inputs{1};

stackedNet.numWeightElements = iGetTotalNumberOfWeightElements(networksToStack);

stackedLayer = 1;
for i = 1:numel(networksToStack)
    for j = 1:networksToStack{i}.numLayers
        stackedNet.layers{stackedLayer} = networksToStack{i}.layers{j};
        stackedNet = iCopyWeights(stackedNet, stackedLayer, networksToStack, i, j);
        stackedNet = iCopyBias(stackedNet, stackedLayer, networksToStack{i}, j);
        
        stackedLayer = stackedLayer + 1;
    end
end
stackedNet = iCopyNetworkSettings(stackedNet, networksToStack{end});

stackedNet.outputs{end} = networksToStack{end}.outputs{end};
end

function iAssertNetworksAreStatic(networksToStack)
for i = 1:numel(networksToStack)
    if(iIsDynamicNetwork(networksToStack{i}))
        error(message('nnet:stack:DynamicNetworksCannotBeStacked'));
    end
end
end

function result = iIsDynamicNetwork(net)
result = ((net.numInputDelays + net.numLayerDelays) > 0);
end

function iAssertNetworksAreSingleInputSingleOutput(networksToStack)
for i = 1:numel(networksToStack)
    if((networksToStack{i}.numInputs ~= 1) || (networksToStack{i}.numOutputs ~= 1))
        error(message('nnet:stack:NotSingleInputSingleOutput'));
    end
end
end

function iAssertNetworkDimensionsAllowStacking(networksToStack)
for i = 1:numel(networksToStack)-1
    if(networksToStack{i}.outputs{1,end}.processedSize ~= networksToStack{i+1}.inputs{1}.processedSize)
        error(message('nnet:stack:DimensionsNotMatchedForStacking'));
    end
end
end

function iAssertNetworksAreStackable(networksToStack)
iAssertNetworksAreStatic(networksToStack);
iAssertNetworksAreSingleInputSingleOutput(networksToStack);
iAssertNetworkDimensionsAllowStacking(networksToStack);
end

function numLayers = iGetTotalNumberOfLayers(cellArrayOfNetworks)
numLayers = 0;
for i = 1:numel(cellArrayOfNetworks)
    numLayers = numLayers + cellArrayOfNetworks{i}.numLayers;
end
end

function net = iCreateStackedNetworkTopology(numLayers)
net = network();
net = iAssignNetworkProperty(net, 'numInputs', 1);
net = iAssignNetworkProperty(net, 'numLayers', numLayers);
net = iAssignNetworkPropertyWithIndex(net, 'inputConnect', {1,1}, true);
for i = 1:numLayers-1
    net = iAssignNetworkPropertyWithIndex(net, 'layerConnect', {i+1,i}, true);
end
net = iAssignNetworkPropertyWithIndex(net, 'outputConnect', {1,numLayers}, true);
net = iAssignNetworkProperty(net, 'biasConnect', true(numLayers,1));
end

function totalNumWeightElements = iGetTotalNumberOfWeightElements(networksToStack)
totalNumWeightElements = 0;
for i = numel(networksToStack)
    totalNumWeightElements = totalNumWeightElements + networksToStack{i}.numWeightElements;
end
end

function net = iCopyWeights(net, stackedLayerIndex, networksToStack, networkToStackIndex, layerToStackIndex)
if(layerToStackIndex > 1)
    net.LW{stackedLayerIndex,stackedLayerIndex-1} = networksToStack{networkToStackIndex}.LW{layerToStackIndex,layerToStackIndex-1};
    net.layerWeights{stackedLayerIndex,stackedLayerIndex-1} = networksToStack{networkToStackIndex}.layerWeights{layerToStackIndex,layerToStackIndex-1};
else
    if(networkToStackIndex > 1)
        net.LW{stackedLayerIndex,stackedLayerIndex-1} = networksToStack{networkToStackIndex}.IW{1,1};
        net.layerWeights{stackedLayerIndex,stackedLayerIndex-1} = networksToStack{networkToStackIndex}.inputWeights{1,1};
    else
        net.IW{1,1} = networksToStack{1}.IW{1,1};
        net.inputWeights{1,1} = networksToStack{1}.inputWeights{1,1};
    end
end
end

function net = iCopyBias(net, stackedLayerIndex, networksToStack, layerToStackIndex)
if networksToStack.biasConnect(layerToStackIndex)
    net.biasConnect(stackedLayerIndex) = networksToStack.biasConnect(layerToStackIndex);
    net.b{stackedLayerIndex} = networksToStack.b{layerToStackIndex};
    net.biases{stackedLayerIndex} = networksToStack.biases{layerToStackIndex};
end
end

function net1 = iCopyNetworkSettings(net1, net2)
net1.adaptFcn = net2.adaptFcn;
net1.adaptParam = net2.adaptParam;
net1.divideFcn = net2.divideFcn;
net1.divideParam = net2.divideParam;
net1.divideMode = net2.divideMode;
net1.initFcn = net2.initFcn;
net1.performFcn = net2.performFcn;
net1.performParam = net2.performParam;
net1.plotFcns = net2.plotFcns;
net1.plotParams = net2.plotParams;
net1.derivFcn = net2.derivFcn;
net1.trainFcn = net2.trainFcn;
net1.trainParam = net2.trainParam;
end

function net = iAssignNetworkProperty(net, propertyName, propertyValue)
s.type = '.';
s.subs = propertyName;
net = subsasgn(net, s, propertyValue);
end

function net = iAssignNetworkPropertyWithIndex(net, propertyName, propertyIndices, propertyValue)
s = iCreateStructForPropertyWithIndex(propertyName, propertyIndices);
net = subsasgn(net, s, propertyValue);
end

function outputStruct = iCreateStructForPropertyWithIndex(propertyName, propertyIndices)
outputStruct(1).type = '.';
outputStruct(1).subs = propertyName;
outputStruct(2).type = '()';
outputStruct(2).subs = propertyIndices;
end