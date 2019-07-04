function dperf = forwardprop(dy,t,y,e,param)
%CROSSENTROPY.FORWARDPROP Forward propagation of derivatives

% Copyright 2013-2015 The MathWorks, Inc.

  % Defined range for Y and T
  y = max(min(y,1-eps),eps);
  t = max(min(t,1),0);

  S = size(t,1);
  if (S > 1)
    % Standard case: single term 1-of-N crossentropy
    d = -t./y;
  else
    % Safe fallback: two term binary crossentropy
    d = -t./y + (1-t)./(1-y);
  end
  dperf = bsxfun(@times,dy,d);
end
