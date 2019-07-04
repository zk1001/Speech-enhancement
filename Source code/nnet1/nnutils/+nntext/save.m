function save(path,text)

% Copyright 2010-2014 The MathWorks, Inc.

file = fopen(path,'w','n','UTF-8');
if (file == -1)
  error('nnet:General:CannotCreateFile','Unable to create file.');
end
for i=1:length(text)
  ti = text{i};
  ti = protectstr(ti);
  fprintf(file,[ti '\n']);
end
fclose(file);

function str = protectstr(str)

percent = find(str == '%');
for i=fliplr(percent)
  str = [str(1:i) '%' str((i+1):end)];
end

slash = find(str == '\');
for i=fliplr(slash)
  str = [str(1:i) '\' str((i+1):end)];
end
