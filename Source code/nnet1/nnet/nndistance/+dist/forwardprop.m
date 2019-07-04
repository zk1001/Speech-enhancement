function dz = forwardprop(dp,w,p,z,param)
%DIST.FORWARDPROP Propagate derivative from input to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q,N] = size(dp);
  S = size(w,1);
  if isa(dp,'gpuArray')
    dz = iGPU(dp,w,p,z,R,S,Q,N);
  else
    dz = iCPU(dp,w,p,z,R,S,Q,N);
  end
end

function dz = iCPU(dp,w,p,z,R,S,Q,N)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dp = reshape(dp,1,R,Q,N); % 1xRxQxN
  d = bsxfun(@rdivide,bsxfun(@minus,p,w),z); % SxRxQ
  d(~isfinite(d)) = 0;
  dz = sum(bsxfun(@times,d,dp),2); % Sx1xQxN
  dz = reshape(dz,S,Q,N); % SxQxN
end

function dz = iGPU(dp,w,p,z,R,S,Q,N)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dp = reshape(dp,1,R,Q,N); % 1xRxQxN
  d = arrayfun(@iGPUHelper,dp,w,p,z); % SxRxQxN
  dz = reshape(sum(d,2),S,Q,N); % SxQxN
end

function d = iGPUHelper(dp,w,p,z)
  d = dp .* (p - w) ./ z;
  if ~isfinite(d)
    d = 0;
  end
end