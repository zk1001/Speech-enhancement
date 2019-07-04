function d = dy_dx(x,y,settings)
%PROCESSPCA.DY_DX Derivatives of output with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

Q = size(x,2);
d = settings.transform;
d = cast( d, 'like', x );
d = repmat({d},1,Q);
end
