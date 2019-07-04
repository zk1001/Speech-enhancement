function da = forwardprop(dn,n,a,param)
%SOFTMAX.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(dn,'gpuArray')
    da = iForwardpropGPU(dn,a);
  else
    da = iForwardpropCPU(dn,a);
  end
end

function da = iForwardpropCPU(dn,a)
  [S,Q,N] = size(dn);
  da = zeros(S,Q,N);
  for q=1:Q
    aq = a(:,q);
    d = bsxfun(@times,-aq,aq') + diag(aq);
    da(:,q,:) = reshape(d * reshape(dn(:,q,:),S,N),S,1,N);
  end
end

function da = iForwardpropGPU(dn,a)
  [S,Q,N] = size(dn);
  ind = gpuArray.colon(1,S);
  a = reshape(a,S,1,Q);
  at = reshape(a,1,S,Q);
  dn = reshape(dn,S,1,Q,N);
  d = arrayfun(@iForwardpropGPU_Helper,a,at,ind,ind');
  da = pagefun(@mtimes,d,dn);
  da = reshape(da,S,Q,N);
end
  
function d = iForwardpropGPU_Helper(a,at,colInd,rowInd)
  d = -a .* at;
  if (colInd == rowInd)
    d = d + a;
  end
end

