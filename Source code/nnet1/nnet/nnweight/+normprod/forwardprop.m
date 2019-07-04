function dz = forwardprop(dp,w,p,z,param)
%NORMPROD.FORWARDPROP Propagate derivative from input to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q,N] = size(dp);
  S = size(z,1);
  if isa(dp,'gpuArray')
    dz = iGPU(dp,w,p,z,R,S,Q,N);
  else
    dz = iCPU(dp,w,p,z,R,S,Q,N);
  end
end

function dz = iCPU(dp,w,p,z,R,S,Q,N)
  dz = zeros(S,Q,N);
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  signp = sign(p);
  for q=1:Q
    dq = (w - bsxfun(@times,signp(:,q)',z(:,q))) * dividep(q);
    dzq = sum(bsxfun(@times,dq',dp(:,q,:)),1);
    dzq(~isfinite(dzq)) = 0;
    dz(:,q,:) = reshape(dzq,S,1,N);
  end
end

function dz = iGPU(dp,w,p,z,R,S,Q,N)
  p = reshape(p,1,R,Q);
  z = reshape(z,S,1,Q);
  dp = reshape(dp,R,1,Q);
  sump = sum(abs(p),2);
  d = arrayfun(@iGPUHelper,w,p,z,sump); % SxRxQ
  dz = pagefun(@mtimes,d,dp); % 1xRxQxN
  dz = reshape(dz,S,Q,N);
end

function d = iGPUHelper(w,p,z,sump)
  d = (w - sign(p) .* z) .* (1 ./ sump);
  if ~isfinite(d)
    d = 0;
  end
end
