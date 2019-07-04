function [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = perfsJEJJ(net,data,hints)
% nnMATLAB.perfsJEJJ   Jacobian and performance computed by nnMATLAB

% Copyright 2012-2014 The MathWorks, Inc.

% Which Jacobian function should we use for the direction of computation?
direction = iDirection( hints, net );
jacobian = iJacobianFunctionForDirection( direction );

% Compute the Jacobian
[JE,JJ,Perfs,PerfN] = jacobian( net,...
    data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.T,data.EW,...
    {data.train.mask data.val.mask data.test.mask},data.Q,data.TS,hints );

% Assign output arguments
trainPerf = Perfs(1);
valPerf = Perfs(2);
testPerf = Perfs(3);
trainN = PerfN(1);
valN = PerfN(2);
testN = PerfN(3);
end

function direction = iDirection(hints,net)
direction = hints.direction;
if strcmp(direction,'default')
    if (net.numLayerDelays == 0)
        direction = 'static';
    else
        direction = 'backward';
    end
end
end

function jacobian = iJacobianFunctionForDirection( direction )
switch direction
  case 'static'
    jacobian = @nnMATLAB.backpropJacobianStatic;
  case 'forward'
    jacobian = @nnMATLAB.fj;
  case 'backward'
    jacobian = @nnMATLAB.bj;
end
end
