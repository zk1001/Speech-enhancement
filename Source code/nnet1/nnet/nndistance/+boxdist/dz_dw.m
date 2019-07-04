function d = dz_dw(w,p,z,param)
%BOXDIST.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(w,1);
  [R,Q] = size(p);
  if (R==0)
    d = repmat({zeros(0,Q,'like',w)},1,S);
  else
    d = cell(1,S);
    for i=1:S
      z1 = bsxfun(@minus,w(i,:)',p); % RxQ
      z2 = abs(z1); % RxQ
      z3 = max(abs(z2),[],1); % 1xQ
      di = bsxfun(@eq,z2,z3) .* sign(z1); % RxQ
      d{i} = di;
    end
  end
end
