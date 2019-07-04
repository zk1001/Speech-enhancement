function n = apply(z,S,Q,param,arrayType)
%NETPROD.APPLY Combined weighted inputs into net input

% Copyright 2012-2015 The MathWorks, Inc.

if isempty(z)
    % No inputs
    if (nargin < 5)
        arrayType = 0;
    end
    n = ones(S,Q,'like',arrayType);
    
else
    % Combine inputs
    n = z{1};
    for i=2:length(z)
        n = bsxfun(@times,n,z{i});
    end
    
    % Expand bias if it is the only input
    if (size(n,2) == 1) && (nargin >= 3)
        n = repmat(n,1,Q);
    end
end
end
