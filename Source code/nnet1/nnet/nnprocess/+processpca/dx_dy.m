function d = dx_dy(x,y,settings)
%PROCESSPCA.DX_DY Derivatives of input with respect to output

% Copyright 2012-2015 The MathWorks, Inc.

Q = size(x,2);
inverse = pinv(settings.transform);
inverse = cast( inverse, 'like', x );
d = repmat({inverse},1,Q);
end
