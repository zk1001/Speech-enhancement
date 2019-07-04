function dw = backstop(dz,w,p,z,param)
%VGAMPROD.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(z);
  R = size(p,1);
  TruncateS = max(0,min(R-1,S));
  TruncateR = max(0,min(R,S+1));
  d = p(1:TruncateS,:)-p(2:TruncateR,:)+1; % TruncateSxQ
  dw = zeros(S,1,'like',dz);
  dw(1:TruncateS) = sum(bsxfun(@times,dz(1:TruncateS,:),d),2);
end
