function a = apply(n,param)
%COMPET.APPLY Apply transfer function to inputs

% Copyright 2012-2015 The MathWorks, Inc.

  if isempty(n)
    a = n;
  else
    [S,Q] = size(n);
    nanInd = any(isnan(n),1);
    a = zeros(S,Q,'like',n);
    [~,maxRows] = max(n,[],1);
    onesInd = maxRows + S*(0:(Q-1));
    a(onesInd) = 1;
    a(:,nanInd) = NaN;
  end
end


