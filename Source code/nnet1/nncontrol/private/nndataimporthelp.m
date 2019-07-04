function nndataimporthelp(varargin)
%NNDATAIMPORTHELP Help text for the Import Data window.
%
%  Synopsis
%
%   nndataimporthelp(varargin) 
% 
%   displays the help text for the Import Data window. 
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
     %---Help for the Data Import window
     doc(fullfile(nnpath.nnet_root,'toolbox/nnet/nncontrol/private/nndataimporthelp_main.m'));
  end, % switch action
end