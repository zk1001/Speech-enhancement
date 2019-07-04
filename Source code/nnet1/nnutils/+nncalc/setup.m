function [calcLib,calcNet,net,resourceText] = setup(calcMode,net,data)
% Setup calculation mode, net, data & hints for non-parallel calculations

% Copyright 2012-2013 The MathWorks, Inc.

% Setup Step 1: On Main Thread Only
[calcMode,calcNet,calcData,calcHints,net,resourceText] = nncalc.setup1(calcMode,net,data);

% Setup Step 2: On Each Worker, if using Parallel Calculation Mode
if isa(calcMode,'Composite');
  spmd
    % Finish setup for parallel mode
    [calcLib,calcNet] = nncalc.setup2(calcMode,net,calcData,calcHints);
  end
else
  % Finish setup for MATLAB, MEX, GPU and other non-parallel modes
  [calcLib,calcNet] = nncalc.setup2(calcMode,calcNet,calcData,calcHints);
end
