function [cost, grad] = computeSparsityRegularizationNNGPUOp( ...
    calcNet, calcHints, calcData, transferFunction, numMasks)

% Copyright 2015 The MathWorks, Inc.

Pc = calcData.Pc{1};

trainMask = calcData.train.indices;
valMask = calcData.val.indices;
testMask = calcData.test.indices;

[cost,grad] = iComputeSparsityRegularizationOnDataset(calcNet, calcHints, Pc(:,trainMask), transferFunction);

if (numMasks == 3)
    cost = [cost 0 0];
    if(~isempty(valMask))
        cost(2) = iComputeSparsityRegularizationOnDataset(calcNet, calcHints, Pc(:,valMask), transferFunction);
    end
    if(~isempty(testMask))
        cost(3) = iComputeSparsityRegularizationOnDataset(calcNet, calcHints, Pc(:,testMask), transferFunction);
    end
end

cost = gather(cost);
grad = gather(grad);
end

function [cost, grad] = iComputeSparsityRegularizationOnDataset(calcNet, calcHints, Pc, transferFunction)

firstLayerIndex = calcHints.layerOrder(1);
outputSize = calcHints.outputSizes(1);
sparsity = calcHints.perfParam.sparsity;
sparsityRegularization = calcHints.perfParam.sparsityRegularization;

sparsity = iBoundAwayFromZeroAndOne(sparsity);

w1 = calcNet.IW{firstLayerIndex,1};
b1 = calcNet.b{firstLayerIndex};
Z2 = w1*Pc;
if(~isempty(b1))
    Z2 = arrayfun(@plus, Z2, b1);
end
A2 = feval([transferFunction '.apply'], Z2);

n = size(Pc,2);
sparsityAvg = sum(A2,2)/n;
sparsityAvg = iBoundAwayFromZeroAndOne(sparsityAvg);
sparsityTerm = sparsityRegularization*(-(sparsity./sparsityAvg)+((1-sparsity)./(1-sparsityAvg)));

sparsecost = sum( (sparsity*log(sparsity./sparsityAvg)) + ...
    ((1-sparsity)*log((1-sparsity)./(1-sparsityAvg))) );

if(sparsecost < 0)
    sparsecost = 0;
    sparsityTerm = 0;
end

dA2bydZ2 = feval([transferFunction '.da_dn'], Z2, A2);
delta2 = arrayfun(@times, sparsityTerm, dA2bydZ2);

W1grad = delta2*Pc'/n;
if(~isempty(b1))
    b1grad = sum(delta2,2)/n;
else
    b1grad = [];
end

sparsegrad = [b1grad(:) ; W1grad(:) ; zeros(size(calcHints.initWB,1)-numel(b1)-numel(w1),1)];

cost = sparsityRegularization*sparsecost/outputSize;
grad = sparsegrad/outputSize;
end

function X = iBoundAwayFromZeroAndOne(X)
X(X < eps) = eps;
X(X > 1-eps) = 1 - eps;
end
