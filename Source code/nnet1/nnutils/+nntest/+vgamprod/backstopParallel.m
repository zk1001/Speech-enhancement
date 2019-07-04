function dw = backstopParallel(dz,w,p,z,param)
%VGAMPROD.BACKSTOPPARALLEL Backpropagate weighted input derivatives to weight

% Copyright 2012-2015 The MathWorks, Inc.

[S,Q,N] = size(dz);
R = size(p,1);
TruncateS = max(0,min(R-1,S));

dw = zeros(S,1,Q,N,'like',dz); % Sx1xQxN
if (TruncateS == 0) || isempty(dw)
    % nothing to do
else
    p = reshape(p,R,1,Q); % Rx1xQ
    dz = reshape(dz(1:TruncateS,:,:),TruncateS,1,Q,N); % TruncaseSx1xQxN
    d = p(1:TruncateS,1,:)-p(2:TruncateS+1,1,:)+1; % TruncateSx1xQxN
    dw(1:TruncateS,1,:,:) = bsxfun(@times,dz,d); % TruncateSx1xQxN
end
end
