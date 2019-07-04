function err = check(options)

% Copyright 2013-2015 The MathWorks, Inc.

% Check Precision option
if ~ischar(options.precision) || (size(options.precision,1) ~= 1) || ...
  isempty(nnstring.match(options.precision,{'single','double'}))
  err = 'Option ''precision'' must be either ''single'' or ''double''.';
  return
end

% Check Direction option
if ~ischar(options.direction) || (size(options.direction,1) ~= 1) || ...
  isempty(nnstring.match(options.direction,{'default','forward','backward'}))
  err = 'Option ''direction'' must be ''default'', ''forward'' or ''backward''.';
  return
end

% Check UseParallel option
if ~ischar(options.useParallel) || (size(options.useParallel,1) ~= 1) || ...
  isempty(nnstring.match(options.useParallel,{'no','yes','always'}))
  err = 'Option ''useParallel'' must be either ''no'' or ''yes''.';
  return
end

% Check UseGPU option
if ~ischar(options.useGPU) || (size(options.useGPU,1) ~= 1) || ...
  isempty(nnstring.match(options.useGPU,{'no','yes','only'}))
  err = 'Option ''useGPU'' must be either ''no'', ''yes'' or ''only''.';
  return
end

% Check Reduction option
if ~isscalar(options.reduction) || ~isnumeric(options.reduction) || ...
    (options.reduction < 1) || (options.reduction ~= floor(options.reduction))
  err = 'Memory reduction must be an integer of 1 or greater.';
  return;
end

% Check ShowResources option
if ~ischar(options.showResources) || (size(options.showResources,1) ~= 1) || ...
  isempty(nnstring.match(options.showResources,{'yes','no'}))
  err = 'Option ''showResources'' must be either ''yes'' or ''no''.';
  return
end

% Check Checkpoint Options
err = nnet.checkpoint.checkOptions(options);

