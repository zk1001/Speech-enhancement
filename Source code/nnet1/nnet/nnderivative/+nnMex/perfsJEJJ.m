function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)
% nnMex.perfsJEJJ   Jacobian and performance computed by nnMex

% Copyright 2012-2014 The MathWorks, Inc.

% Which Jacobian function should we use for the direction of computation?
direction = iDirection(hints);
[jacobian, TEMP] = iJacobianFunctionForDirection( direction, hints );

numMasks = 3;

% Compute the Jacobian
[JE,JJ,Perfs,PerfN] = jacobian(net,...
    data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,...
    data.masks,data.Q,data.TS,numMasks,hints,TEMP,hints.batch);

% Assign output arguments
trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);
trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);
end

function direction = iDirection(hints)
if strcmp(hints.direction,'default')
    if (hints.numLayerDelays == 0)
        direction = 'static';
    else
        direction = 'forward';
    end
else
    direction = hints.direction;
end
end

function [jacobian, TEMP] = iJacobianFunctionForDirection( direction, hints )
switch direction
    case 'static'
        jacobian = @nnMex.backpropJacobianStatic;
        TEMP = zeros(1,hints.tempSizeBackpropStaticJacobian);
    case 'forward'
        jacobian = @nnMex.fj;
        TEMP = zeros(1,ceil(hints.tempSizeFJ/8)*8);
end
end
