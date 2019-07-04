function dz_dw = forwardstart(w,p,z,param)
%GAMPROD.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,R] = size(w);
  Q = size(p,2);
  dz_dw = zeros(S,Q,S,R,'like',w);
  pt = reshape(param.beta*p',1,Q,1,R);
  for i=1:S
    dz_dw(i,:,i,:) = pt;
  end
end
