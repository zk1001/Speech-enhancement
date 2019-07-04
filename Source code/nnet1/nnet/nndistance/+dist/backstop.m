function dw = backstop(dz,w,p,z,param)
%DIST.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(dz);
  R = size(p,1);
  if isa(dz,'gpuArray')
    dw = iGPU(dz,w,p,z,R,S,Q);
  else
    dw = iCPU(dz,w,p,z,R,S,Q);
  end
end

function dw = iCPU(dz,w,p,z,R,S,Q)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q); % Sx1xQ
  d = bsxfun(@rdivide,bsxfun(@minus,w,p),z); % SxRxQ
  d(~isfinite(d)) = 0;
  dw = sum(bsxfun(@times,d,dz),3); % SxR
end

function dw = iGPU(dz,w,p,z,R,S,Q)
  p = reshape(p,1,R,Q); % 1xRxQ
  z = reshape(z,S,1,Q); % Sx1xQ
  dz = reshape(dz,S,1,Q); % Sx1xQ
  d = arrayfun(@iGPUHelper,dz,w,p,z); % SxRxQ
  dw = sum(d,3); % SxR
end

function d = iGPUHelper(dz,w,p,z)
  d = dz .* (w-p) ./ z;
  if ~isfinite(d)
    d = 0;
  end
end
