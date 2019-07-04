function dw = backstop(dz,w,p,z,param)
%CONVWF.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(dz,1);
  R = size(p,1);
  M = R-S+1;
  mframe = 0:(M-1);
  dw = zeros(M,1,'like',dz);
  for i=1:S
    dw = dw + p(i+mframe,:) * dz(i,:)';
  end
end
