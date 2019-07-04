function a = apply(n,param)
%ELLIOT2SIG.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  n2 = n.*n; 
  a = sign(n).*n2 ./ (1 + n2);
end
