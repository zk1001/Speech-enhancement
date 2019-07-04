function dw = forwardstart(w,p,z,param)
%NEGDIST.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(w,'gpuArray')
    dw = iGPU(w,p,z);
  else
    dw = iCPU(w,p,z);
  end
end

function dw = iCPU(w,p,z)
  [S,R] = size(w);
  Q = size(p,2);
  p = reshape(p',1,Q,1,R);
  w = reshape(w,S,1,1,R);
  d = bsxfun(@rdivide,bsxfun(@minus,w,p),z); % SxQx1XR
  d(isnan(d)) = 0;
  dw = zeros(S,Q,S,R);
  for i=1:S
    dw(i,:,i,:) = d(i,:,1,:);
  end
end

function dw = iGPU(w,p,z)
  [S,R] = size(w);
  Q = size(p,2);
  pt = reshape(p',1,Q,1,R);
  w = reshape(w,S,1,1,R);
  ind1 = gpuArray.colon(1,S)'; % Sx1x1x1
  ind3 = reshape(gpuArray.colon(1,S),1,1,S); % 1x1xSx1
  dw = arrayfun(@iGPUHelper,w,pt,z,ind1,ind3); % SxQxSxR
end

function d = iGPUHelper(w,pt,z,ind1,ind3)
  if (ind1 ~= ind3)
    d = 0;
  else
    d = (w - pt) ./ z;
    if ~isfinite(d)
      d = 0;
    end
  end
end
