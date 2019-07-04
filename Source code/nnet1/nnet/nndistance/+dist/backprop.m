function dp = backprop(dz,w,p,z,param)
%DIST.BACKPROP Backpropagate weighted input derivative to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  if isa(dz,'gpuArray')
    dp = iGPU(dz,w,p,z,R,S,Q,N);
  else
    dp = iCPU(dz,w,p,z,R,S,Q,N);
  end
end

function dp = iCPU(dz,w,p,z,R,S,Q,N)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  d = bsxfun(@rdivide,bsxfun(@minus,p,w),z); % SxRxQ
  d(~isfinite(d)) = 0;
  dp = sum(bsxfun(@times,d,dz),1); % 1xRxQxN
  dp = reshape(dp,R,Q,N); % RxQxN
end

function dp = iGPU(dz,w,p,z,R,S,Q,N)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q,N); % Sx1xQxN
  d = arrayfun(@iGPUHelper,dz,w,p,z); % SxRxQxN
  dp = reshape(sum(d,1),R,Q,N); % RxQxN
end

function d = iGPUHelper(dz,w,p,z)
  d = dz .* (p-w) ./ z;
  if ~isfinite(d)
    d = 0;
  end
end
