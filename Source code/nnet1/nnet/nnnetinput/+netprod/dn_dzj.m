function d = dn_dzj(j,z,n,param)
%NETPROD.DN_DZN Derivative of net input with respect to jth weighted input

% Copyright 2012-2015 The MathWorks, Inc.

if length(z) == 1
    d = ones(size(n),'like',n);
else
    zj = z{j};
    if all(zj(:) ~= 0)
        d = bsxfun(@rdivide,n,zj);
    else
        d = 1;
        for i= [1:(j-1) (j+1):numel(z)]
            d = bsxfun(@times,d,z{i});
        end
        if (size(d,2) == 1)
            d = repmat(d,1,size(n,2));
        end
    end
end
end
