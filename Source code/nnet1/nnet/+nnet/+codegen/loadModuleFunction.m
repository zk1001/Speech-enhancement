function code = loadModuleFunction(module,fcn)

% Copyright 2012-2015 The MathWorks, Inc.

filename = ['+',module,filesep,fcn,'.m'];
code = nntext.load(filename)';