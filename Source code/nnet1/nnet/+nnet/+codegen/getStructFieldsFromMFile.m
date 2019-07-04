function fields = getStructFieldsFromMFile(module,fcn,structName)
% getStructFieldsFromMFile   Get names of all "param" or "settings" fields
% used in function code

% Copyright 2012-2015 The MathWorks, Inc.

import nnet.codegen.*;

code = loadModuleFunction(module,fcn);
fields = getStructFieldsFromMCode(code,structName);
