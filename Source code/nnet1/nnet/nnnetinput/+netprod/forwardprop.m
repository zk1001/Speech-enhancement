function dn = forwardprop(dz,j,z,n,param)
%NETSUM.FORWARDPROP Propagate derivates from weighted input to net input

% Copyright 2012-2015 The MathWorks, Inc.

if length(z) == 1
    dn = dz;
else
    zj = z{j};
    if all(zj(:) ~= 0)
        dn = bsxfun(@times,dz,bsxfun(@rdivide,n,zj));
    else
        d = 1;
        for i= [1:(j-1) (j+1):numel(z)]
            d = bsxfun(@times,d,z{i});
        end
        dn = bsxfun(@times,dz,d);
    end
end
end
