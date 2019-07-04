function d = da_dn(n,a,param)
%SOFTMAX.DA_DN Derivative of outputs with respect to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  if isa(n,'gpuArray')
    d = i_dAdN_GPU(a);
  else
    d = i_dAdN_CPU(a);
  end
end

function d = i_dAdN_CPU(a)
  Q = size(a,2);
  d = cell(1,Q);
  for q=1:Q
    aq = a(:,q);
    d{q} = bsxfun(@times,-aq,aq') + diag(aq);
  end
end

function d = i_dAdN_GPU(a)
  [S,Q] = size(a);
  d = cell(1,Q);
  ind = gpuArray.colon(1,S);
  for q=1:Q
    aq = a(:,q);
    d{q} = arrayfun(@i_dAdN_GPU_helper,aq,aq',ind,ind');
  end
end

function d = i_dAdN_GPU_helper(a,at,ind,indt)
  d = -a .* at;
  if (ind == indt)
    d = d + a;
  end
end
