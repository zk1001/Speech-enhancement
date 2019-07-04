function k = getKernel(name,cproto)

% Copyright 2012-2013 The MathWorks, Inc.

if nargin < 2
  cproto = fullfile(nnpath.nnet_root,'toolbox','nnet','nnet','nnderivative','+nnGPU',[name '.cu']);
end

ext = parallel.gpu.ptxext;
ptx = fullfile(nnpath.nnet_root,'COMPILED','+nnGPU',[name '.ptx']);
if ~exist(ptx,'file')
  ptx = fullfile(nnpath.nnet_root,'toolbox','nnet','nnet','nnderivative','+nnGPU',[name '.' ext]);
end
k = parallel.gpu.CUDAKernel(ptx,cproto);

