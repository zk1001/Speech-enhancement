function code = outputConstantDefinitions(net,i,prefix)

% Copyright 2012-2015 The MathWorks, Inc.

import nnet.codegen.*;

if nargin < 3, prefix = ''; end
output2layer = find(net.outputConnect);
code = {};
ii = output2layer(i);
for j=numel(net.outputs{ii}.processFcns):-1:1
  module = net.outputs{ii}.processFcns{j};
  settings = net.outputs{ii}.processSettings{j};
  if ~settings.no_change
    fields = getStructFieldsFromMFile(module,'reverse','settings');
    for k=1:numel(fields)
      field = fields{k};
      var = outputSettingName(i,j,field);
      code{end+1} = [prefix var ' = ' mat2str(settings.(field)) ';'];
    end
  end
end
