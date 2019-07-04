function dz = backprop(dn,j,z,n,param)
%NETPROD.BACKPROP Propagate derivates from net input back to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

if length(z) == 1
    dz = dn;
else
    zj = z{j};
    if all(zj(:) ~= 0)
        dz = bsxfun(@times,dn,bsxfun(@rdivide,n,zj));
    else
        d = 1;
        for i= [1:(j-1) (j+1):numel(z)]
            d = bsxfun(@times,d,z{i});
        end
        dz = bsxfun(@times,dn,d);
    end
end
end

