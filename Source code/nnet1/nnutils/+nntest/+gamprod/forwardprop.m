function dz = forwardprop(dp,w,p,z,param)
%GAMPROD.FORWARDPROP Forward propagate derivatives from inputs to outputs

% Copyright 2012-2015 The MathWorks, Inc.

  [R,Q,N] = size(dp);
  S = size(z,1);
  TruncateS = max(0,min(R-1,S));
  TruncateR = min(R,S+1);

  if (S==0)
    dz = zeros(S,Q,N,'like',dp);
  else
    w = w(1);
    dp = reshape(dp(1:TruncateR,:,:),1,TruncateR,Q,N); % 1xTruncateRxQxN
    d1 = diag(w*ones(1,TruncateS,'like',dp)); % TruncateSxTruncateS
    zeros1 = zeros(TruncateS,1,'like',dp); % TruncateSx1
    d = ([d1 zeros1] + [zeros1 -d1]); % TruncateSxTruncateR
    dz = zeros(S,Q,N,'like',dp); % SxQxN
    dz1 = sum(bsxfun(@times,dp,d),2); % TruncaseSx1xQxN
    dz(1:TruncateS,:,:) = reshape(dz1,TruncateS,Q,N); % TruncateSxQxN
  end
end
