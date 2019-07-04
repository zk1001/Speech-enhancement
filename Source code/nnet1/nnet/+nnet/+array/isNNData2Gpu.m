function flag = isNNData2Gpu(d)
%isNNData2Gpu Returns true if data is likely NNDATA2GPU formatted data.

% Copyright 2015 The MathWorks, Inc.

[dRows,dCols] = size(d);
rowsMultipleOf32 = rem(dRows,32) == 0;
lastRowIsNaN = all(isnan(d(end,:)));
flag = (dRows > dCols) || (rowsMultipleOf32 && lastRowIsNaN);

end
