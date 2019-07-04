function result = closeAllViews

% Copyright 2013 The MathWorks, Inc.

if nargout > 0, result = []; end

JAVA_TOOLS = javaObjectEDT('com.mathworks.toolbox.nnet.matlab.nnTools');
JAVA_TOOLS.disposeAllViews;
