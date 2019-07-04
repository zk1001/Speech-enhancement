function z = apply(w,p,param)
%NEGDIST.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  if isa(w,'gpuArray')
    z = iNegDistApplyGPU(w,p,R,S,Q);
  else
    z = iNegDistApplyCPU(w,p,S,Q);
  end
end

function z = iNegDistApplyCPU(w,p,S,Q)
  z = zeros(S,Q);
  if (Q<S)
    pt = p';
    for q=1:Q
      z(:,q) = sum(bsxfun(@minus,w,pt(q,:)).^2,2);
    end
  else
    wt = w';
    for i=1:S
      z(i,:) = sum(bsxfun(@minus,wt(:,i),p).^2,1);
    end
  end
  z = -sqrt(z);
end

function z = iNegDistApplyGPU(w,p,R,S,Q)
  p = reshape(p,1,R,Q);
  sd = arrayfun(@iNegDistApplyGPUHelper,w,p);
  z = -sqrt(reshape(sum(sd,2),S,Q));
end

function sd = iNegDistApplyGPUHelper(w,p)
  sd = (w-p) .^ 2;
end
