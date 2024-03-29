function n=netsum(varargin)
%NETSUM Sum net input function.
%
% Net input functions combine a layer's weighted inputs and biases to form
% the layer's net input.
%
% <a href="matlab:doc netsum">netsum</a>({Z1,Z2,...,Zn}) takes a variable number of SxQ weighted inputs,
% and combines them, by summing them, to form the SxQ net input.
%
% Here two 4x5 weighted inputs are defined and combined:
%
%   z1 = <a href="matlab:doc rands">rands</a>(4,5);
%   z2 = <a href="matlab:doc rands">rands</a>(4,5);
%   n = <a href="matlab:doc netsum">netsum</a>({z1,z2})
%
% To set a network's ith layer to calculate net input with this function:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_netInputFcn">netInputFcn</a> = '<a href="matlab:doc netsum">netsum</a>'
%
%	See also NETPROD.

% Mark Beale, 11-31-97
% Copyright 1992-2012 The MathWorks, Inc.

% NNET 7.0 Compatibility
% WARNING - This functionality may be removed in future versions
if ischar(varargin{1})
  n = nnet7.net_input_fcn(mfilename,varargin{:});
  return
end

% Apply
if iscell(varargin{1})
  n = netsum.apply(varargin{:});
else
  n = netsum.apply(varargin,1,1);
end
