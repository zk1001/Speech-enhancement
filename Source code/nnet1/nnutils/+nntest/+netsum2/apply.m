function n = apply(z,S,Q,param,arrayType)
%NETSUM2.APPLY Combined weighted inputs into net input

% Copyright 2012-2015 The MathWorks, Inc.

if isempty(z)
    % No inputs
    if (nargin < 5)
        arrayType = 1;
    end
    n = zeros(S,Q,'like',arrayType);
    
else
    % Combine inputs
    n = z{1};
    for i=2:numel(z)
        n = bsxfun(@plus,n,z{i});
    end
    
    % Expand bias if it is only input
    if (size(n,2) == 1) && (nargin >= 3)
        n = repmat(n,1,Q);
    end
end

n = param.alpha * n + param.beta;
end
