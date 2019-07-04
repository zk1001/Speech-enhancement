function z = apply(w,p,param)
%VGAMPROD.APPLY Apply weight to input

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(w,1);
  [R,Q] = size(p);
  TruncateS = max(0,min(R-1,S));
  PadS = max(0,S-TruncateS);
  pad = zeros(PadS,Q,'like',w);
  z = [bsxfun(@times,w(1:TruncateS,:),(p(1:TruncateS,:)-p(2:TruncateS+1,:)+1)); pad];
end
