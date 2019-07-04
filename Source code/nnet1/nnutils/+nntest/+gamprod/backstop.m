function dw = backstop(dz,w,p,z,param)
%GAMPROD.BACKSTOP Backpropagate weighted input derivative to weight

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(z,1);
  R = size(p,1);
  TruncateS = max(0,min(R-1,S));
  d = p(1:TruncateS,:)-p(2:TruncateS+1,:)+1; % TruncateSxQ
  dw = zeros(S,1,'like',dz);
  dw(1) = sum(sum(bsxfun(@times,dz(1:TruncateS,:),d),1),2);
end
