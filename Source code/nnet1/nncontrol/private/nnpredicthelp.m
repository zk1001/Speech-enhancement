function nnpredicthelp(varargin);
%NNPREDICTHELP Help text for the NN Predictive Control GUI
%
%  Synopsis
%
%   nnpredicthelp(varargin) 
%
%   displays the help text for the portion of the NN Predictive Control GUI 
%   specified by varargin. 
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of Neural Network Toolbox. We recommend
%    you do not write code which calls this function.
%    This function is generally being called from a Simulink block.

% Orlando De Jesus, Martin Hagan, 1-25-00
% Copyright 1992-2013 The MathWorks, Inc.

if (nargin > 0)
  switch varargin{1},
  case 'main',
     %---Help for the main Indirect Adaptive Control window
     doc(fullfile(nnpath.nnet_root,'toolbox/nnet/nncontrol/private/nnpredicthelp_main.m'))

  case 'plant_ident',
     %---Help for the Plant Identification process
     doc(fullfile(nnpath.nnet_root,'toolbox/nnet/nncontrol/private/nnpredicthelp_plant_ident.m'))

  case 'simulation',
     %---Help for the simulation process
     doc(fullfile(nnpath.nnet_root,'toolbox/nnet/nncontrol/private/nnpredicthelp_simulation.m'))

  end, % switch action
end

