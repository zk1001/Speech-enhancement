function d = dz_dw(w,p,z,param)
%DIST.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  if isa(w,'gpuArray')
    d = iGPU(w,p,z,R,S,Q);
  else
    d = iCPU(w,p,z,S);
  end
end

function d = iCPU(w,p,z,S)
  d = cell(1,S);
  w = w';
  for i=1:S
    di = bsxfun(@rdivide,bsxfun(@minus,w(:,i),p),z(i,:));
    di(~isfinite(di)) = 0;
    d{i} = di;
  end
end

function d = iGPU(w,p,z,R,S,Q)
  p = reshape(p,1,R,Q);
  z = reshape(z,S,1,Q);
  d = arrayfun(@iGPUHelper,w,p,z); % SxRxQ
  d = mat2cell(d,ones(1,S),R,Q)';  % {1xS}(1xRxQ)
  d = cellfun(@(d) reshape(d,R,Q),d,'UniformOutput',false); % {1xS}(RxQ)
end

function d = iGPUHelper(w,p,z)
  d = (w - p) ./ z;
  if ~isfinite(d)
    d = 0;
  end
end