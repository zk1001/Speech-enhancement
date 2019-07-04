function sendToEditor(text)
% SENDTOEDITOR - This function sends the input text to an editor window,
% and also indents the text correctly.

% Copyright 2014 The MathWorks, Inc.

document = matlab.desktop.editor.newDocument(text);
document.smartIndentContents();
end