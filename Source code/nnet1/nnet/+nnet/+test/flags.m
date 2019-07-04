function value = flags(name,value)
%FLAGS Test Flags
%
%  NNET.TEST.FLAGS, returns the names of all flags set to true.  Normally
%  there will be no flags set.  Flags are only set to true in test code.
%
%  NNET.TEST.FLAGS('anyflagname',true/false) adds or removes a flag name
%  from the flag list.
%
%  NNET.TEST.FLAGS('anyflagname') return true if 'myflagname' is in the flag
%  list.  Returns false otherwise.
%
%  NNET.TEST.FLAGS('clear') removes all flag names from the list.
%
%  For example, to test that the code in RANDS which would respond with an
%  error if the (row,col) argument API were disabled in a custom function
%  derived from RANDS:
%
%    rands(2,3); % Normally does not throw error
%    nnet.test.flags('initWeightInfoTestFcns',true);
%    clear rands
%    rands(2,3); % Should cause 'nnet:rands:Arguments' error.
%    [~,id] = lasterr
%    nnet.test.flags('initWeightInfoTestFcns',false);
%    clear rands

% Copyright 2013-2015 The MathWorks, Inc.

% Default Test Flags all False
persistent FLAGS;
if isempty(FLAGS), FLAGS = {}; end

% No arguments: Return test flags
if nargin == 0
  value = FLAGS;
  
% One argument: Get flag
elseif nargin == 1
  
  if ~ischar(name) || ~isrow(name)
    error('nnet:testFlags:badFlag','Flag must be a string.');
  end
  name = lower(name);
  if strcmp(name,'clear')
    FLAGS = {};
    if (nargout > 1)
      error('nnet:testFlags:noOutput','Clearing flags does not produce an output argument.');
    end
    return
  end
  
  i = nnstring.match(name,FLAGS);
  value = ~isempty(i);
  
% Two arguments: Set flag
else
  
  if ~ischar(name) || ~isrow(name)
    error('nnet:testFlags:badFlag','Flag must be a string.');
  end
  name = lower(name);
  if ~isscalar(value) || ~islogical(value)
    error('nnet:testFlags:badFlagValue','Test flag value is not a scalar logical.');
  end
  i = nnstring.match(name,FLAGS);
  if isempty(i) && value
    FLAGS{end+1} = name;
  elseif ~isempty(i) && ~value
    FLAGS(i) = [];
  end
  
end


