function d = dx_dy(x,y,settings)
%MAPMINMAX.DX_DY Derivatives of input with respect to output

% Copyright 2012-2015 The MathWorks, Inc.

Q = size(x,2);
gain = settings.gain;
gain = cast( gain, 'like', x );
d = diag(1 ./ gain);
d = repmat({d},1,Q);
end
