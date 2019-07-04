function d = dz_dw(w,p,z,param)
%CONVWF.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q] = size(p);
  N = length(w);
  S = R-N+1;
  if isa(w,'gpuArray')
    i1 = gpuArray.colon(1,S)';
    i2 = gpuArray.colon(0,N-1);
    i3 = reshape(gpuArray.colon(0,Q-1),1,1,Q);
  else
    i1 = (1:S)';
    i2 = 0:(N-1);
    i3 = reshape(0:(Q-1),1,1,Q);
  end
  i = bsxfun(@plus,bsxfun(@plus,i1,i2),i3*R);
  d = p(i);
end
