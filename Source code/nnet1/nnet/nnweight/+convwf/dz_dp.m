function d = dz_dp(w,p,z,param)
%CONVWF.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  R = size(p,1);
  N = length(w);
  S = R-N+1;
  pad = zeros(S-1,1,'like',w);
  w2 = [pad; flipud(w); pad];
  if isa(w,'gpuArray')
    i1 = gpuArray.colon(R,R+S-1)';
    i2 = gpuArray.colon(0,-1,-R+1);
  else
    i1 = (R:(R+S-1))';
    i2 = 0:-1:(-R+1);
  end
  i = bsxfun(@plus,i1,i2);
  d = w2(i);
end