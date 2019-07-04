function dw = backstopParallel(dz,w,p,z,param)
%DIST.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  if isa(dz,'gpuArray')
    dw = iGPU(dz,w,p,z,R,S,Q,N);
  else
    dw = iCPU(dz,w,p,z,R,S,Q,N);
  end
end

function dw = iCPU(dz,w,p,z,R,S,Q,N)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  d = bsxfun(@rdivide,bsxfun(@minus,w,p),z); % SxRxQ
  d(~isfinite(d)) = 0;
  dw = bsxfun(@times,d,dz); % SxRxQxN
end

function dw = iGPU(dz,w,p,z,R,S,Q,N)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  dw = arrayfun(@iGPUHelper,dz,w,p,z); % SxRxQxN
end

function dw = iGPUHelper(dz,w,p,z)
  dw = dz .* (w-p) ./ z;
  if ~isfinite(dw)
    dw = 0;
  end
end
