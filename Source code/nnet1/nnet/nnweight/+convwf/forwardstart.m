function dz = forwardstart(w,p,z,param)
%CONVWF.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(z);
  M = length(w);
  mframe = 0:(M-1);
  pt = p';
  dz = zeros(S,Q,M,'like',p);
  for i=1:S
    dz(i,:,:) = pt(:,i+mframe);
  end
end
