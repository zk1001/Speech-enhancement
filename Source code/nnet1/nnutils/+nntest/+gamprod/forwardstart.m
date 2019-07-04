function dz_dw = forwardstart(w,p,z,param)
%VGAMPROD.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(z);
  R = size(p,1);
  TruncateS = max(0,min(R-1,S));

  dz_dw = zeros(S,Q,S,1,'like',w); % SxQxSx1
  if (TruncateS > 0)
    dz_dw(1:TruncateS,:,1,1) = p(1:TruncateS,:) - p(2:TruncateS+1,:) + 1; % truncateSxQx1x1
  end
end
