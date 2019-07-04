function dw = forwardstart(w,p,z,param)
%MANDIST.FORWARDSTART Propagate derivative from weight to weighted input

% Copyright 2012-2015 The MathWorks, Inc.

  [S,Q] = size(z);
  R = size(p,1);
  p = reshape(p',1,Q,1,R); % 1xQx1xR
  w = reshape(w,S,1,1,R); % Sx1x1xR
  z1 = bsxfun(@minus,w,p); % SxQx1xR
  d = sign(z1); % SxQx1xR
  dw = zeros(S,Q,S,R,'like',w); % SxQxSxR
  for i=1:S
    dw(i,:,i,:) = d(i,:,1,:);
  end
end
