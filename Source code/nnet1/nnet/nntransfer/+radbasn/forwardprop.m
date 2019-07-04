function da = forwardprop(dn,n,a,param)
%RADBASN.FORWARDPROP Forward propagate derivatives from input to output.

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(dn,'gpuArray')
    da = iForwardpropGPU(dn,n,a);
  else
    da = iForwardpropCPU(dn,n,a);
  end
end

function da = iForwardpropCPU(dn,n,a)
  [S,Q,N] = size(dn);
  da = zeros(S,Q,N);
  for q=1:Q
    nq = n(:,q);
    aq = a(:,q);
    anq = aq .* nq;
    d = 2*(bsxfun(@times,aq,anq') - diag(anq));
    da(:,q,:) = reshape(d * reshape(dn(:,q,:),S,N),S,1,N);
  end
end

function da = iForwardpropGPU(dn,n,a)
  [S,Q,N] = size(dn);
  ind = gpuArray.colon(1,S);
  nt = reshape(n,1,S,Q);
  a = reshape(a,S,1,Q);
  at = reshape(a,1,S,Q);
  dn = reshape(dn,S,1,Q,N);
  d = arrayfun(@iForwardpropGPU_Helper,nt,a,at,ind,ind');
  da = pagefun(@mtimes,d,dn);
  da = reshape(da,S,Q,N);
end

function d = iForwardpropGPU_Helper(nt,a,at,colInd,rowInd)
  ant = at .* nt;
  d = 2 .* a .* ant;
  if (colInd == rowInd)
    d = d - 2 .* ant;
  end
end
