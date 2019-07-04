function dw = forwardstart(w,p,z,param)
%NORMPROD.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  if isa(w,'gpuArray')
    dw = iGPU(p,S,R,Q);
  else
    dw = iCPU(p,S,R,Q);
  end
end

function dw = iCPU(p,S,R,Q)
  dw = zeros(S,Q,S,R);
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  normpt = bsxfun(@times,p,dividep)';
  normpt(~isfinite(normpt)) = 0;
  for i=1:S
    dw(i,:,i,:) = normpt;
  end
end

function dw = iGPU(p,S,R,Q)
  sump = sum(abs(p),1);
  pt = reshape(p',1,Q,1,R);
  ind1 = gpuArray.colon(1,S)';
  ind3 = reshape(gpuArray.colon(1,S),1,1,S);
  dw = arrayfun(@iGPUHelper,pt,sump,ind1,ind3);
end

function dw = iGPUHelper(pt,sump,ind1,ind3)
  if (ind1 ~= ind3)
    dw = 0;
  else
    dw = pt .* (1 ./ sump);
    if ~isfinite(dw);
      dw = 0;
    end
  end
end
