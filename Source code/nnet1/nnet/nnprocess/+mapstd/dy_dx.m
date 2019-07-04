function d = dy_dx(x,y,settings)
%MAPSTD.DY_DX Derivatives of output with respect to input

% Copyright 2012-2015 The MathWorks, Inc.

Q = size(x,2);
gain = settings.gain;
gain = cast( gain, 'like', x );
d = diag(gain);
d = repmat({d},1,Q);
end
