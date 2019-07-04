function fields = getStructFieldsFromMCode(code,structName)
% getStructFieldsFromMCode   Search function code for references to
% structure fields

% Copyright 2012-2015 The MathWorks, Inc.

import nnet.codegen.*;

fields = {};
structRef = [structName '.'];
for i=2:numel(code)
  str = code{i};
  pos = strfind(str,structRef);
  for j=(pos+numel(structRef))
    k = j;
    while (k<=numel(str)) && isFieldChar(str(k))
      k = k+1;
    end
    field = str(j:(k-1));
    if isempty(nnstring.match(field,fields)) && ~strcmp(field,'no_change')
      fields{end+1} = str(j:(k-1));
    end
  end
end
