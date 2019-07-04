function d = dz_dp(w,p,z,param)
%DIST.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  if isa(w,'gpuArray')
    d = iGPU(w,p,z,R,S,Q);
  else
    d = iCPU(w,p,z,Q);
  end
end

function d = iCPU(w,p,z,Q)
  pt = p';
  d = cell(1,Q);
  for q=1:Q
    dq = bsxfun(@rdivide,bsxfun(@minus,pt(q,:),w),z(:,q));
    dq(~isfinite(dq)) = 0;
    d{q} = dq;
  end
end

function d = iGPU(w,p,z,R,S,Q)
  p = reshape(p,1,R,Q);
  z = reshape(z,S,1,Q);
  d = arrayfun(@iGPUHelper,w,p,z); % SxRxQ
  d = reshape(mat2cell(d,S,R,ones(1,Q)),1,Q); % {1xQ}(SxR)
end

function d = iGPUHelper(w,p,z)
  d = (p - w) ./ z;
  if ~isfinite(d)
    d = 0;
  end
end