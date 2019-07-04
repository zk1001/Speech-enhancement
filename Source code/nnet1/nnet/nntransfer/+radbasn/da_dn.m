function d = da_dn(n,a,param)
%RADBASN.DA_DN Derivative of outputs with respect to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(n,'gpuArray')
    d = i_dAdN_GPU(n,a);
  else
    d = i_dAdN_CPU(n,a);
  end
end

function d = i_dAdN_CPU(n,a)
  Q = size(n,2);
  d = cell(1,Q);
  for q=1:Q
    nq = n(:,q);
    aq = a(:,q);
    anq = aq .* nq;
    d{q} = 2*(bsxfun(@times,aq,anq') - diag(anq));
  end
end

function d = i_dAdN_GPU(n,a)
  [S,Q] = size(n);
  d = cell(1,Q);
  ind = gpuArray.colon(1,S);
  for q=1:Q
    nq = n(:,q);
    aq = a(:,q);
    d{q} = arrayfun(@i_dAdN_GPU_helper,nq',aq,aq',ind,ind');
  end
end

function d = i_dAdN_GPU_helper(nt,a,at,colInd,rowInd)
  ant = at .* nt;
  d = 2 .* a .* ant;
  if (colInd == rowInd)
    d = d - 2 .* ant;
  end
end
