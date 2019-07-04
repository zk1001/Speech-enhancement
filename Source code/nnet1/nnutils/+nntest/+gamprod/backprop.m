function dp = backprop(dz,w,p,z,param)
%GAMPROD.BACKPROP Backpropagate derivatives from outputs to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q,N] = size(dz);
  R = size(p,1);
  TruncateS = max(0,min(R-1,S));
  TruncateR = max(0,min(R,S+1));
  if (TruncateS == 0)
    dp = zeros(R,Q,N,'like',dz);
  else
    w = w(1);
    dz = reshape(dz(1:TruncateS,:,:),TruncateS,1,Q,N); % TruncteSx1xQxN
    d1 = diag(w*ones(1,TruncateS)); % TruncateSxTruncateS
    zeros1 = zeros(TruncateS,1,'like',dz); % TruncateSx1
    d = [d1 zeros1] + [zeros1 -d1]; % TruncateSxTruncateR
    dp = zeros(R,Q,N,'like',dz); % RxQxN
    dp1 = sum(bsxfun(@times,dz,d),1); % TruncaseSxTruncateR
    dp(1:TruncateR,:,:) = reshape(dp1,TruncateR,Q,N); %TruncateRxQxN
  end
end
