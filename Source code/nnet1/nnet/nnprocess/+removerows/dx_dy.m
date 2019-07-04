function d = dx_dy(x,y,settings)
%REMOVEROWS.DX_DY Derivatives of input with respect to output

% Copyright 2012-2015 The MathWorks, Inc.

  d = removerows.dy_dx(x,y,settings);
  d = cellfun( @ctranspose, d, 'UniformOutput', false );
end
