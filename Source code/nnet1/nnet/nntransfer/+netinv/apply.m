function a = apply(n,param)
%NETINV.APPLY transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  a = 1./n;
  zero = (n == 0);
  a(zero) = 2e30;
  small = find((abs(n)<=1e-30) & ~zero);
  nSmall = n(small);
  a(small) = 2e30*sign(nSmall) - 1e60*nSmall;
end
