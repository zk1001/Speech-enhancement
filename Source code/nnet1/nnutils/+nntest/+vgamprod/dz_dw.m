function d = dz_dw(w,p,z,param)
%VGAMPROD.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(z);
  R = size(p,1);
  TruncateS = max(0,min(R-1,S));

  d1 = p(1:TruncateS,:)-p(2:TruncateS+1,:) + 1;
  d1 = reshape(d1,1,TruncateS,Q);
  d = zeros(S,S,Q,'like',w);
  for i=1:TruncateS
    d(i,i,:) = d1(1,i,:);
  end
end
