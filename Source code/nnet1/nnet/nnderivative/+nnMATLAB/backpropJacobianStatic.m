function [JE,JJ,Perfs,PerfN] = backpropJacobianStatic(net,X,Xi,Pc,Pd,Ai,T,EW,masks,Q,TS,hints)
%nnMATLAB.backpropJacobianStatic Static Jacobian Backpropagation
%
% Input arguments:
%   net   - neural network
%   X     - inputs
%   Xi    - initial input delay states
%   Pc    - processed combined [Xi X] inputs (empty or precalculated)
%   Pd    - Delayed processed inputs (empty precalculated)
%   Ai    - initial layer delay states
%   T     - targets
%   OW    - Observation weights
%   masks - 1 or more masks (1st mask is always training mask)
%   Q     - Number of samples
%   TS    - Number of timesteps
%   hints - Network and data calculation hints
%
% Output arguments
%   JE    - dPerf/dWB, an Nwb-by-1 matrix
%   JJ    - (dE/dWB)^2, an Nwb-by-Nwb matrix
%   Perfs - Total performance for each masks
%   PerfN - Total number of performances for each mask

% Copyright 2012-2014 The MathWorks, Inc

% Initialize JE, JJ, Performance and Counts
JE = zeros(hints.wbLen,1);
JJ = zeros(hints.wbLen,hints.wbLen);
numMasks = numel(masks);
Perfs = zeros(1,numMasks);
PerfN = zeros(1,numMasks);

% Needed pre-processing steps
doDelayedInputs = isempty(Pd);

% Expand Biases
bz = cell(net.numLayers,1);
bq = ones(1,Q);
for i=1:net.numLayers
    if net.biasConnect(i)
        bz{i} = net.b{i}(:,bq);
    end
end

% Temporary Variables
Z = cell(net.numLayers,hints.maxZ); % biases, weighted inputs and layer outputs
N = cell(net.numLayers,1); % Net inputs
Ac = cell(net.numLayers,1); % Layer outputs
Yp = cell(1,hints.maxOutProc); % Processed layer outputs

% Loop through time
for ts=1:TS
    
    % Simulate forward through layers
    for ipos = 1:net.numLayers
        i = hints.layerOrder(ipos);
        
        % Biases
        if net.biasConnect(i)
            Z{i,1} = bz{i};
        end
        
        % Input Weights
        for j = 1:net.numInputs
            if net.inputConnect(i,j)
                pd = getDelayedInputs(net,Pc,Pd,i,j,ts,doDelayedInputs,hints);
                Z{i,hints.iwzInd(i,j)} = hints.iwApply{i,j}(net.IW{i,j},pd,hints.iwParam{i,j});
            end
        end
        
        % Layer Weights
        for j = 1:net.numLayers
            if net.layerConnect(i,j)
                ad = Ac{j};
                Z{i,hints.lwzInd(i,j)} = hints.lwApply{i,j}(net.LW{i,j},ad,hints.lwParam{i,j});
            end
        end
        
        % Net Input and Transfer Function
        N{i} = hints.netApply{i}(Z(i,1:hints.numZ(i)),net.layers{i}.size,Q,hints.netParam{i});
        
        % Transfer Function
        Ac{i} = hints.tfApply{i}(N{i},hints.tfParam{i});
        
        % Outputs
        if net.outputConnect(i)
            ii = hints.layer2Output(i);
            
            % Output Processing
            yi = Ac{i};
            Yp{hints.numOutProc(ii)+1} = yi;
            for j = hints.numOutProc(ii):-1:1
                yi = hints.out(ii).procRev{j}(yi,hints.out(ii).procSet{j});
                Yp{j} = yi;
            end
            
            % Error
            e = T{ii,ts} - yi;
            
            % Derivative of Output with respect to itself (negated)
            dy = -ones(size(e));
            
            % Error Normalization
            if hints.doErrNorm(ii)
                e = bsxfun(@times,e,hints.errNorm{ii});
                dy = bsxfun(@times,dy,hints.errNorm{ii});
            end
            
            % Observation Weights
            if hints.doEW
                if (hints.M_EW == 1)
                    ewii=1;
                else
                    ewii=ii;
                end
                ew = EW{ewii,ts};
                sqrt_ew = sqrt(ew);
                e = bsxfun(@times,e,sqrt_ew);
                dy = bsxfun(@times,dy,sqrt_ew);
            end
            
            % Performance = Squared Error
            perf = e .^ 2;
            
            % Masks
            for k=1:numMasks
                % Apply mask
                perfk = perf .* [masks{k}{ii,ts}];
                ignore = find(isnan(perfk));
                perfk(ignore) = 0;
                
                % Sum performances and counts
                Perfs(k) = Perfs(k) + sum(sum(perfk));
                PerfN(k) = PerfN(k) + numel(perfk) - length(ignore);
                
                % Zero out dY and E associated with NaN training (k==1) performances
                if (k==1)
                    dy(ignore) = 0;
                    e(ignore) = 0;
                end
            end
            
            % Expand dY across output elements for Jacobian calculations
            dy_expanded = zeros(net.outputs{i}.size,Q,net.outputs{i}.size);
            for s=1:net.outputs{i}.size;
                dy_expanded(s,:,s) = dy(s,:);
            end
            dy = dy_expanded;
            
            % Backprop through Output Processing
            for j = 1:hints.numOutProc(ii)
                dy = hints.out(ii).procBPrev{j}(dy,Yp{j},Yp{j+1},hints.out(ii).procSet{j});
                Yp{j} = []; % Deallocate
            end
            
            % Clear dB, dIW, dLW
            dB = cell(net.numLayers,1);
            dIW = cell(net.numLayers,net.numInputs);
            dLW = cell(net.numLayers,net.numLayers);
            
            % Backpropagate from the layer's output
            dA = cell(net.numLayers,1);
            dA{i} = dy;
            
            % Backprop backward through previous layers
            for ibp = fliplr(hints.layerOrder(1:ipos));
                
                % Backprop Transfer Function
                if ~isempty(dA{ibp})
                    dn = hints.tfBP{ibp}(dA{ibp},N{ibp},Ac{ibp},hints.tfParam{ibp});
                    Zi = Z(ibp,1:hints.numZ(ibp));
                    
                    % Backprop Layer Weights
                    for j = net.numLayers:-1:1
                        if net.layerConnect(ibp,j)
                            
                            % Net Input -> Weighted Layer Output
                            ind = hints.lwzInd(ibp,j);
                            dz = hints.netBP{ibp}(dn,ind,Zi,N{ibp},hints.netParam{ibp});
                            
                            % To Layer Weight
                            ad = Ac{j};
                            if hints.lwInclude(ibp,j)
                                dLW{ibp,j} = addToPossiblyEmptyMatrix(dLW{ibp,j},hints.lwBSP{ibp,j}(dz,net.LW{ibp,j},ad,Z{ibp,ind},hints.lwParam{ibp,j}));
                            end
                            
                            % Through Layer Weight
                            dad = hints.lwBP{ibp,j}(dz,net.LW{ibp,j},ad,Z{ibp,ind},hints.lwParam{ibp,j});
                            dA{j} = addToPossiblyEmptyMatrix(dA{j},dad);
                        end
                    end
                    
                    % Backprop Input Weights
                    for j = net.numInputs:-1:1
                        if hints.iwInclude(ibp,j)
                            
                            % Net Input -> Weighted Input
                            ind = hints.iwzInd(ibp,j);
                            dz = hints.netBP{ibp}(dn,ind,Zi,N{ibp},hints.netParam{ibp});
                            
                            % To Input Weight
                            pd = getDelayedInputs(net,Pc,Pd,ibp,j,ts,doDelayedInputs,hints);
                            dIW{ibp,j} = addToPossiblyEmptyMatrix(dIW{ibp,j},hints.iwBSP{ibp,j}(dz,net.IW{ibp,j},pd,Z{ibp,ind},hints.iwParam{ibp,j}));
                        end
                    end
                    
                    % Backprop Biases
                    if hints.bInclude(ibp)
                        
                        % Net Input -> Bias
                        dz = hints.netBP{ibp}(dn,1,Zi,N{ibp},hints.netParam{ibp});
                        
                        % To Bias
                        dB{ibp} = addToPossiblyEmptyMatrix(dB{ibp},dz);
                    end
                end
            end
            
            % Jacobian Values
            J = formJ(net,i,dB,dIW,dLW,Q,TS,hints);
            et = e';
            JE = JE + J * et(:);
            JJ = JJ + J * J';
        end
    end
end
end

function c = addToPossiblyEmptyMatrix(a,b)
if isempty(a)
    c = b;
else
    c = a + b;
end
end

function pd = getDelayedInputs(net,Pc,Pd,i,j,ts,doDelayedInputs,hints)
% Calculate or get delayed outputs
if doDelayedInputs
    if hints.iwUnitDelay(i,j)
        p_ts = net.numInputDelays+ts;
        pd = Pc{j,p_ts};
    else
        p_ts = (net.numInputDelays+ts)-net.inputWeights{i,j}.delays;
        pd = cat(1,Pc{j,p_ts});
    end
else
    pd = Pd{i,j,ts};
end
end

function J = formJ(net,ii,dB,dIW,dLW,Q,TS,hints)
% Create J = dY/dWB = Nwb-by-(So*Q) sized matrix
numCol = net.outputs{ii}.size * Q;
J = zeros(net.numWeightElements,numCol);
for i=1:net.numLayers
    if hints.bInclude(i)
        if ~isempty(dB{i})
            J(hints.bInd{i},:) = reshape(dB{i},numel(net.b{i}),numCol);
        end
    end
    for j=find(hints.iwInclude(i,:))
        if ~isempty(dIW{i,j})
            dIW{i,j} = reshape(dIW{i,j},numel(net.IW{i,j}),numCol);
            J(hints.iwInd{i,j},:) = reshape(dIW{i,j},numel(net.IW{i,j}),numCol);
        end
    end
    for j=find(hints.lwInclude(i,:))
        if ~isempty(dLW{i,j})
            J(hints.lwInd{i,j},:) = reshape(dLW{i,j},numel(net.LW{i,j}),numCol);
        end
    end
end
end

