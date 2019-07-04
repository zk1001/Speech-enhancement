function flag = distCompAvailable()
%AVAILABLE True if Parallel Computing Toolbox is available and checked out

% Copyright 2010-2013 The MathWorks, Inc.

flag = ~isempty(ver('distcomp')) ...
    && license('test','distrib_computing_toolbox') ...
    && license('checkout','distrib_computing_toolbox');
