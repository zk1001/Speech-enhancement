function perfs = apply(t,y,e,param)
%CROSSENTROPY.APPLY Calculate performances

% Copyright 2013-2015 The MathWorks, Inc.

  % Defined range for Y and T
  y = max(min(y,1-eps),eps);
  t = max(min(t,1),0);

  S = size(t,1);
  if (S > 1)
    % Standard case: single term 1-of-N crossentropy
    perfs = -t.*log(y);
  else
    % Safe fallback: two term binary crossentropy
    perfs = -t.*log(y) -(1-t).*log(1-y);
  end
end
