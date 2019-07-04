function dp = backprop(dz,w,p,z,param)
%NORMPROD.BACKPROP Backpropagate weighted input derivative to input

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(dz,'gpuArray')
    dp = iGPU(dz,w,p,z);
  else
    dp = iCPU(dz,w,p,z);
  end
end

function dp = iCPU(dz,w,p,z)
  [~,Q,N] = size(dz);
  R = size(p,1);
  dp = zeros(R,Q,N);
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  signp = sign(p);
  for q=1:Q
    dq = (w - bsxfun(@times,signp(:,q)',z(:,q))) * dividep(q);
    dpq = sum(bsxfun(@times,dq,dz(:,q,:)),1);
    dpq(~isfinite(dpq)) = 0;
    dp(:,q,:) = reshape(dpq,R,1,N);
  end
end

function dp = iGPU(dz,w,p,z)
  [S,Q,N] = size(dz);
  R = size(p,1);
  p = reshape(p,1,R,Q);
  dz = reshape(dz,1,S,Q,N);
  z = reshape(z,S,1,Q);
  sump = sum(abs(p),2); % 1x1xQ
  d = arrayfun(@iGPUHelper,w,p,z,sump); % SxRxQ
  dp = pagefun(@mtimes,dz,d); % Rx1xQxN
  dp = reshape(dp,R,Q,N);
end

function d = iGPUHelper(w,p,z,sump)
  d = (w - sign(p) .* z) .* (1 ./ sump);
  if ~isfinite(d)
    d = 0;
  end
end
