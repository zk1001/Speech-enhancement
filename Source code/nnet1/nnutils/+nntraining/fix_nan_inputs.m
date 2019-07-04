function [X,Xi,Ai,T] = fix_nan_inputs(net,X,Xi,Ai,T,Q,TS)
% NNTRAINING.FIX_NAN_INPUTS
%
% Sets targest to NaN where inputs result in NaN outputs. This allows
% those outputs to be ignored.
%
% Replace NaN values in input, input states and layer states to 0.
% This avoids the problem of zero derivates (coming from NaN targets)
% being multiplied by NaN and becoming NaN.  Any finite value would work,
% zero was an arbitrary choice.

% Copyright 2010-2015 The MathWorks, Inc.

% Are their any NaN values?
anyNaN = iAnyNaN(X) || iAnyNaN(Xi) || iAnyNaN(Ai);

if anyNaN
    % Propagate NaN values to outputs
    data.Q = Q;
    data.TS = TS;
    
    % Calculate outputs
    % TODO - Use fastest mode after calculation feature parity is completed.
    % For now just use nnMATLAB calculation mode
    isCellOfGPU = iAnyIsCellOfGPU(X,Xi,Ai,T);
    if isCellOfGPU
        data.X = iGatherCellOfGPUData(X);
        data.Xi = iGatherCellOfGPUData(Xi);
        data.Ai = iGatherCellOfGPUData(Ai);
    elseif isa(X,'gpuArray')
        data.X = gpu2nndata(X,Q,nn.input_sizes(net),TS);
        data.Xi = gpu2nndata(Xi,Q,nn.input_sizes(net),net.numInputDelays);
        data.Ai = gpu2nndata(Ai,Q,nn.layer_sizes(net),net.numLayerDelays);
    else
        data.X = X;
        data.Xi = Xi;
        data.Ai = Ai;
    end
    hints = nnMATLAB.netHints(net);
    hints = nnMATLAB.dataHints(net,data,hints);
    Y = nnMATLAB.y(net,data,hints);
    
    % Copy NaN outputs to targets so those values will be ignored
    % Clear NaN from inputs and delay states so they can no longer
    % contaminate gradient.
    if isCellOfGPU
        T = iCopyNaNCellOfGPU(Y,T);
        X = iClearNaNCellOfGPU(X);
        Xi = iClearNaNCellOfGPU(Xi);
        Ai = iClearNaNCellOfGPU(Ai);
    elseif isa(X,'gpuArray')
        T = arrayfun(@iCopyNaNGPU,nndata2gpu(Y),T);
        X = arrayfun(@iClearNaNGPU,X);
        Xi = arrayfun(@iClearNaNGPU,Xi);
        Ai = arrayfun(@iClearNaNGPU,Ai);
    else
        T = iCopyNaN(Y,T);
        X = iClearNaN(X);
        Xi = iClearNaN(Xi);
        Ai = iClearNaN(Ai);
    end
end

% Return fewer output arguments if nargout is 1 or 2
if (nargout == 1)
    % Return only T
    X = T;
    
elseif (nargout == 2)
    % Backward compatibility for obsolete code
    % Returns Pc and T, instead of X, Xi, Ai an T.
    
    % Get processed input and input delays
    toolsML = nnMATLAB;
    hintsML = nnMATLAB.netHints(net,toolsML.hints);
    Pc = toolsML.pc(net,X,Xi,Q,TS,hintsML);
    
    % Remove NaN values so they don't corrupt gradients
    Pc = iClearNaN(Pc);
    
    % Outputs
    X = Pc;
    Xi = T;
end
end

% Is cell of gpuArray?
function flag = iAnyIsCellOfGPU(varargin)
for i=1:numel(varargin)
    vi = varargin{i};
    if ~isempty(vi) && iscell(vi) && isa(vi{1},'gpuArray')
        flag = true;
        return;
    end
end
flag = false;
end

% Find any NaN values in cell array of matrices
function flag = iAnyNaN(x)
if isa(x,'gpuArray')
    flag = iAnyNaN({gpu2nndata(x)});
else
    for i=1:numel(x)
        flag = any(any(isnan(x{i})));
        if isa(flag,'gpuArray')
            flag = gather(flag);
        end
        if flag
            return
        end
    end
    flag = false;
end
end

% Convert cell arrays of gpuArray to cell arrays of MATLAB array
function varargout = iGatherCellOfGPUData(varargin)
n = nargin;
varargout = cell(1,n);
for k=1:n
    x = varargin{k};
    for i=1:numel(x)
        x{i} = gather(x{i});
    end
    varargout{k} = x;
end
end

% Copy NaN values from first argument to second argument
function t = iCopyNaN(y,t)
for i=1:numel(y)
    yi = y{i};
    t{i}(isnan(yi)) = NaN;
end
end

% Copy NaN values from first argument to second argument on GPU
function t = iCopyNaNCellOfGPU(y,t)
for i=1:numel(y)
    t{i} = arrayfun(@iCopyNaNGPU,y{i},t{i});
end
end
function t = iCopyNaNGPU(y,t)
if isnan(y)
    t = NaN;
end
end

% Replace NaN values with 0 in cell array of matrices
function x = iClearNaN(x)
for i=1:numel(x)
    xi = x{i};
    xi(isnan(xi)) = 0;
    x{i} = xi;
end
end

% Replace NaN values with 0 in cell array of gpuArray
function x = iClearNaNCellOfGPU(x)
for i=1:numel(x)
    x{i} = arrayfun(@iClearNaNGPU,x{i});
end
end
function x = iClearNaNGPU(x)
if isnan(x)
    x = 0;
end
end