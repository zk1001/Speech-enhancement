function code = moduleSubfunction(module,fcn,structName)
% moduleSubfunction 

% Copyright 2012-2015 The MathWorks, Inc.

code = nnet.codegen.loadModuleFunction(module,fcn);
code = iRemoveBlankAndCommentLines(code);
code{1} = strrep(code{1},fcn,[module '_' fcn]);
if isempty(nnet.codegen.getStructFieldsFromMCode(code,structName))
    code{1} = iRemoveStructArgument(code{1},structName);
end
code = iRemoveNoChangeBlockFromCode(code);
code = iAddMissingEnd(code);
end

function code = iRemoveBlankAndCommentLines(code)
% iRemoveBlankAndCommentLines   Remove blank and comment lines
TAB = sprintf( '\t' );
SPACE = ' ';

for j=numel(code):-1:1
    line = code{j};
    line((line == SPACE) | (line == TAB)) = [];
    if isempty(line) || (line(1) == '%')
        code(j) = [];
    end
end
end

function code = iAddMissingEnd(code)
if isempty(strfind(code{end},'end'))
    code{end+1} = 'end';
end
end

function str = iRemoveStructArgument(str,structName)
% Remove the struct argument, which is the last argument
startPos = strfind(str,structName);
endPos = startPos + numel(structName);
str = [str(1:(startPos-1)) '~' str(endPos:end)];
end

function code = iRemoveNoChangeBlockFromCode(code)
% Eliminate "if settings.no_change" block as generated
% code will not call functions if no_change is true
i = 1;
while (i<numel(code))
    if ~isempty(strfind(code{i},'if settings.no_change'))
        j = i+1;
        while (j <= numel(code)) && isempty(strfind(code{j},'end'))
            j = j+1;
        end
        code(i:j) = [];
    else
        i = i+1;
    end
end
end


