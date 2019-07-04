function d = dz_dp(w,p,z,param)
%GAMPROD.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(z,1);
  R = size(p,1);
  TruncateS = max(0,min(R-1,S));
  PadS = max(0,S-TruncateS);

  if (R==0) || (S==0)
    d = zeros(S,R,'like',w);
  else
    w = w(1);
    d1 = diag(w*ones(1,TruncateS,'like',w)); % TruncateSxTruncateS
    zeros1 = zeros(TruncateS,R-TruncateS,'like',w);
    zeros2 = zeros(TruncateS,1,'like',w);
    zeros3 = zeros(TruncateS,R-TruncateS-1,'like',w);
    zeros4 = zeros(PadS,R,'like',w);
    d = [[d1 zeros1] + [zeros2 -d1 zeros3]; zeros4];
  end
end