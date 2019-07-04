function dw = backstop(dz,w,p,z,param)
%NORMPROD.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  sump = sum(abs(p),1); % 1xQ
  normp = bsxfun(@times,p,1 ./ sump); % RxQ
  normp(~isfinite(normp)) = 0;
  dw = dz * normp'; % SxR
end
