function net = loadobj(net)
%LOADOBJ Load a network object.
%
%  <a href="matlab:doc loadobj">loadobj</a>(NET) is automatically called with a structure when
%  a network is loaded from a MAT file.  If the network is from a
%  previous version of Neural Network Toolbox software then
%  it is updated to the latest version.

% Copyright 1992-2012 The MathWorks, Inc.
% $Revision: 1.4.78.2 $ $Date: 2013/10/09 06:33:11 $

net = struct(net);
net = nnupdate.net(net);
net = network(net);

