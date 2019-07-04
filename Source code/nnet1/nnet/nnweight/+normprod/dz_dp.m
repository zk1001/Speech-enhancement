function d = dz_dp(w,p,z,param)
%NORMPROD.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(w,'gpuArray')
    d = iGPU(w,p,z);
  else
    d = iCPU(w,p,z);
  end
end

function d = iCPU(w,p,z)
  Q = size(p,2);
  d = cell(1,Q);
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  signp = sign(p);
  for q=1:Q
    dq = (w - bsxfun(@times,signp(:,q)',z(:,q))) * dividep(q);
    dq(~isfinite(dq)) = 0;
    d{q} = dq;
  end
end

function d = iGPU(w,p,z)
  [S,R] = size(w);
  Q = size(p,2);
  sump = reshape(sum(abs(p),1),1,1,Q);
  p = reshape(p,1,R,Q);
  z = reshape(z,S,1,Q);
  d = arrayfun(@iGPUHelper,w,p,z,sump); % SxRxQ
  d = reshape(mat2cell(d,S,R,ones(1,Q)),1,Q); % {1xQ}(SxR)
end

function d = iGPUHelper(w,p,z,sump)
  d = (w - sign(p) .* z) .* (1 ./ sump);
  if ~isfinite(d)
    d = 0;
  end
end
