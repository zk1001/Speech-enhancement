function fcn = caller(n)
%NNCALLINGFCN Returns the name of the calling function.
%
%  NNCALLINGFCN returns the name of the function calling the function
%  which called NNCALLINGFCN.
%
%  NNCALLINGFCN(1) returns the same thing.
%
%  NNCALLINGFCN(0) returns the same name returned by MFILENAME.
%
%  NNCALLINGFCN(N) with N>1, returns the name of the calling function
%  N steps up the calling stack.

% Copyright 2010-2014 The MathWorks, Inc.

if nargin < 1, n = 1; end

s = dbstack;
if length(s) >= (n+2)
  fcn = s(n+2).file;
  fcn = iExtractFunctionName(fcn);
else
  fcn = '';
end

function fcnname = iExtractFunctionName(filename)
if iIsMatlabFile(filename)
    fcnname = filename(1:(end-2));
else
    fcnname = filename;
end

function tf = iIsMatlabFile(filename)
tf = nnstring.ends(filename,'.m') || nnstring.ends(filename,'.p');