function nndataexporthelp(varargin)
%NNDATAEXPORTHELP Help text for the Export Data window.
%
%  Synopsis
%
%   nndataexporthelp(varargin) 
%
%   displays the help text for the Export Data window. 
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
     %---Help for the Data Export window
     doc(fullfile(nnpath.nnet_root,'toolbox/nnet/nncontrol/private/nndataexporthelp_main.m'));
  end, % switch action
end