function d = dz_dw(w,p,z,param)
%GAMPROD.DZ_DW Derivative of weighted input with respect to weight

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(z);
  d = zeros(S,S,Q,'like',w);
  if ~isempty(d)
    R = size(p,1);
    TruncateS = max(0,min(R-1,S));
    d1 = p(1:TruncateS,:)-p(2:TruncateS+1,:) + 1;
    d1 = reshape(d1,TruncateS,1,Q);
    d(1:TruncateS,1,:) = d1;
  end
end

% d = SxSxQ, all zeros except for 2nd index == 1, for only non-zero weight
