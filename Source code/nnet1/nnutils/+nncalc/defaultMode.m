function calcMode = defaultMode(net,calcMode)
% defaultMode

% Copyright 2012-2015 The MathWorks, Inc.

if isdeployed
    calcMode = iCalculationModeForDeployed();
    
elseif (nargin < 2) || isempty(calcMode) || strcmp(calcMode.name,'default')
    % Set calculation mode if it is unspecified or specified as 'default'.
    calcMode = iDefaultCalculationMode( net );
    
elseif isfield(calcMode.hints,'subcalc')
    % If calculation mode was specified, recursively set subcalc defaults.
    % Modes with submodes include nnParallel, nn2Point, nn5Point and nnNPoint
    calcMode.hints.subcalc = nncalc.defaultMode(net,calcMode.hints.subcalc);
end
end

function calcMode = iCalculationModeForDeployed()
calcMode = nnMATLAB;
end

function calcMode = iDefaultCalculationMode(net)
% iDefaultCalculationMode
%
% MEX is preferred as it is generally fastest and always more memory
% efficient, but may not support custom modules.
%
% MATLAB is the fallback, as it supports all modules.  MATLAB may be
% slightly faster for open-loop Jacobian but uses much more memory.
if iMexModeCompatibleWithNetwork(net)
    calcMode = nnMex;
else
    calcMode = nnMATLAB;
end
end

function supported = iMexModeCompatibleWithNetwork(net)
% iMexModeCompatibleWithNetwork   True if MEX mode is compatible with
% network's standard and custom modules.
%
% If training function is specified, then gradient or Jacobian support for
% the modules is required as indicated by that function.
[usesGradient,usesJacobian] = iUsesDerivatives( net.trainFcn );

calcMode = nnMex;
problem = calcMode.netCheck( net, calcMode.hints, usesGradient, usesJacobian );

supported = isempty( problem );
end


function [usesGradient,usesJacobian] = iUsesDerivatives(trainFcn)
% iUsesDerivatives   True for train functions that use gradients &/or
% Jacobian
if isempty(trainFcn)
    usesGradient = false;
    usesJacobian = false;
else
    trainInfo = feval(trainFcn,'info');
    usesGradient = trainInfo.usesGradient;
    usesJacobian = trainInfo.usesJacobian;
end
end