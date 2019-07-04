function dn = backprop(da,n,a,param)
%RADBASN.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(da,'gpuArray')
    dn = iBackpropGPU(da,n,a);
  else
    dn = iBackpropCPU(da,n,a);
  end
end

function dn = iBackpropCPU(da,n,a)
  [S,Q,N] = size(da);
  dn = zeros(S,Q,N,'like',da);
  for q=1:Q
    nq = n(:,q);
    aq = a(:,q);
    anq = aq .* nq;
    d = 2*(bsxfun(@times,aq,anq') - diag(anq));
    dn(:,q,:) = reshape(d' * reshape(da(:,q,:),S,N),S,1,N);
  end
end

function dn = iBackpropGPU(da,n,a)
  [S,Q,N] = size(da);
  ind = gpuArray.colon(1,S);
  n = reshape(n,S,1,Q);
  a = reshape(a,S,1,Q);
  at = reshape(a,1,S,Q);
  da = reshape(da,S,1,Q,N);
  d = arrayfun(@iBackpropGPU_Helper,n,a,at,ind,ind');
  dn = pagefun(@mtimes,d,da);
  dn = reshape(dn,S,Q,N);
end

function d = iBackpropGPU_Helper(n,a,at,colInd,rowInd)
  an = a .* n;
  d = 2 .* at .* an;
  if (colInd == rowInd)
    d = d - 2 .* an;
  end
end
