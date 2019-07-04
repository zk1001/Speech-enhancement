function dn = backprop(da,n,a,param)
%SOFTMAX.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(da,'gpuArray')
    dn = iBackpropGPU(da,a);
  else
    dn = iBackpropCPU(da,a);
  end
end

function dn = iBackpropCPU(da,a)
  [S,Q,N] = size(da);
  dn = zeros(S,Q,N);
  for q=1:Q
    aq = a(:,q);
    d = bsxfun(@times,-aq,aq') + diag(aq);
    dn(:,q,:) = reshape(d' * reshape(da(:,q,:),S,N),S,1,N);
  end
end

function dn = iBackpropGPU(da,a)
  [S,Q,N] = size(da);
  ind = gpuArray.colon(1,S);
  a = reshape(a,S,1,Q);
  at = reshape(a,1,S,Q);
  da = reshape(da,S,1,Q,N);
  d = arrayfun(@iBackpropGPU_Helper,a,at,ind,ind'); % SxSxQxN
  dn = pagefun(@mtimes,d,da); % Sx1xQxN
  dn = reshape(dn,S,Q,N);
end
  
function d = iBackpropGPU_Helper(a,at,colInd,rowInd)
  d = -a .* at;
  if (colInd == rowInd)
    d = d + a;
  end
end

