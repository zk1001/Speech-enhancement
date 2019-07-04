function d = dz_dp(w,p,z,param)
%VGAMPROD.DZ_DP Derivative of weighted input with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

  S = size(z,1);
  R = size(p,1);

  if (S==0) || (R<2)
    d = zeros(S,R,'like',w);
  else
    TruncateS = max(0,min(R-1,S));
    PadS = max(0,S-TruncateS);
    PadR = max(0,R-TruncateS);

    d1 = diag(w(1:TruncateS)); % TruncateSxTruncateS
    zeros1 = zeros(TruncateS,PadR,'like',w);
    zeros2 = zeros(TruncateS,1,'like',w);
    zeros3 = zeros(TruncateS,PadR-1,'like',w);
    zeros4 = zeros(PadS,R,'like',w);
    d = [[d1 zeros1] + [zeros2 -d1 zeros3]; zeros4];
  end
end
