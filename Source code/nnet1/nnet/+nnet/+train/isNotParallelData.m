function flag = isNotParallelData(data)
% isNotParallelData   True for data that is not "parallel data"
%
%   Syntax:
%       isNotParallelData(data)
%
%   Inputs:
%       data -- structure or composite of structures of data as generated
%       by nntraining.setup
%
%   See also: nntraining.setup.

% Copyright 2014-2014 The MathWorks, Inc.

flag = ~isa(data,'Composite') && strcmpi(data.format,'CellOfMatrix');

end
