function dz_dw = forwardstart(w,p,z,param)
%VGAMPROD.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(z);
  R = size(p,1);
  TruncateS = min(R-1,S);

  dz_dw = zeros(S,Q,S,1,'like',w); % SxQxSx1
  for i=1:TruncateS
    dz_dw(i,:,i,1) = p(i,:) - p(i+1,:) + 1; % truncateSxQx1x1
  end
end
