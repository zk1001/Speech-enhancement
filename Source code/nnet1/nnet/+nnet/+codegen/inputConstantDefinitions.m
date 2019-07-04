function code = inputConstantDefinitions(net,i,prefix)

% Copyright 2012-2015 The MathWorks, Inc.

import nnet.codegen.*;

if nargin < 3, prefix = ''; end
code = {};
for j=1:numel(net.inputs{i}.processFcns)
  module = net.inputs{i}.processFcns{j};
  settings = net.inputs{i}.processSettings{j};
  if ~settings.no_change
    fields = getStructFieldsFromMFile(module,'apply','settings');
    for k=1:numel(fields)
      field = fields{k};
      var = inputSettingName(i,j,field);
      code{end+1} = [prefix var ' = ' mat2str(settings.(field)) ';'];
    end
  end
end
