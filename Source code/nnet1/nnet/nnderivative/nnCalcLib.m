classdef nnCalcLib
    %nnCalcLib Neural network calculation training library interface.
    %
    % WARNING: Custom training functions which rely on nnCalcLib's interface
    % may need to be updated in future versions of the toolbox.
    %
    % nnCalcLib objects are passed to <a href="matlab:help nntrain">training functions</a> and can be used within
    % training functions to set and get a networks weights and biases, and
    % calculate network outputs, performance, gradient and Jacobian values.
    %
    % Each of these operations requires a calculation version of the neural
    % network, supplied as the calcNet argument to training algorithms.
    %
    % The implementation of calcLib and calcNet will depend on what calculation
    % mode is being used, for instance, MATLAB, GPU or Parallel.  (See help
    % for train on choosing parallel computing modes.) Also calcLib
    % encapsulates the training data suitable for the current calculation
    % mode, so training data does not need to be supplied to calcLib methods.
    %
    % Regardless of calcLib and calcNet's implementation, calcLib will support
    % the following methods.  See their individual help for more information:
    %
    %   <a href="matlab:help nnCalcLib.summary">nnCalcLib.summary</a>
    %   <a href="matlab:help nnCalcLib.getwb">nnCalcLib.getwb</a>
    %   <a href="matlab:help nnCalcLib.setwb">nnCalcLib.setwb</a>
    %   <a href="matlab:help nnCalcLib.y">nnCalcLib.y</a>
    %   <a href="matlab:help nnCalcLib.trainPerf">nnCalcLib.trainPerf</a>
    %   <a href="matlab:help nnCalcLib.trainValTestPerfs">nnCalcLib.trainValTestPerfs</a>
    %   <a href="matlab:help nnCalcLib.grad">nnCalcLib.grad</a>
    %   <a href="matlab:help nnCalcLib.perfsGrad">nnCalcLib.perfsGrad</a>
    %   <a href="matlab:help nnCalcLib.perfsJEJJ">nnCalcLib.perfsJEJJ</a>
    
    % Copyright 2012-2014 The MathWorks, Inc.
    
    properties (SetAccess = private, GetAccess = private)
        calcMode
        calcData
        calcHints
    end
    
    properties (SetAccess = private, GetAccess = public)
        isParallel
        isActiveWorker
        isMainWorker
        mainWorkerInd
        options
    end
    
    methods
        
        function lib = nnCalcLib(cm,cd,ch)
            lib.calcMode = cm;
            lib.calcData = cd;
            lib.calcHints = ch;
            lib.isParallel = cm.isParallel;
            lib.isActiveWorker = cm.isActiveWorker;
            lib.isMainWorker = cm.isMainWorker;
            lib.mainWorkerInd = cm.mainWorkerInd;
            lib.options = cm.options;
            if ~lib.isActiveWorker
                lib.options.calcSummary = 'Unused Worker';
            elseif ~isdeployed
                lib.options.calcSummary = cm.summary(ch);
            else
                lib.options.calcSummary = 'MATLAB';
            end
        end
        
        function s = summary(lib)
            %SUMMARY String summary of calculation mode
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  s = calcLib.summary returns a string summarizing the calculation mode.
            s = lib.options.calcSummary;
        end
        
        function wb = getwb(lib,calcNet)
            %GETWB Get neural network's weight and bias vector.
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  wb = calcLib.getwb(calcNet) returns the weight/bias vector.
            wb = lib.calcMode.getwb(calcNet,lib.calcHints);
        end
        
        function calcNet = setwb(lib,calcNet,wb)
            %SETWB Set neural network's weight and bias vector.
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  calcLib.setwb(calcNet,wb) sets the weight/bias vector.
            calcNet = lib.calcMode.setwb(calcNet,wb,lib.calcHints);
        end
        
        % function pc
        
        % function pd
        
        function [Y,Af] = y(lib,calcNet)
            %Y Calculate neural network outputs.
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  Y = calcLib.y(calcNet) returns the networks outputs.
            if nargout == 2
                [Y,Af] = lib.calcMode.y(calcNet,lib.calcData,lib.calcHints);
            else
                Y = lib.calcMode.y(calcNet,lib.calcData,lib.calcHints);
                Af = [];
            end
            
            % Unflatten if necessary
            if lib.isActiveWorker && lib.calcHints.isComposite
                if lib.calcHints.doFlattenTime
                    Yflat = Y;
                    Y = cell(lib.calcHints.numOutputs,lib.calcHints.TSu);
                    for i=1:lib.calcHints.numOutputs
                        Y(i,:) = mat2cell(Yflat{i},lib.calcHints.outputSizes(i),ones(1,lib.calcHints.TSu)*lib.calcData.Qu);
                    end
                end
            elseif lib.isMainWorker
                if (lib.calcHints.doFlattenTime)
                    Yflat = Y;
                    Y = cell(lib.calcHints.numOutputs,lib.calcHints.TSu);
                    for i=1:lib.calcHints.numOutputs
                        Y(i,:) = mat2cell(Yflat{i},lib.calcHints.outputSizes(i),ones(1,lib.calcHints.TSu)*lib.calcHints.Qu);
                    end
                end
            end
        end
        
        function [trainPerf,trainN] = trainPerf(lib,calcNet)
            %trainPerf Training performance.
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  [perf,N] = calcLib.trainPerf(calcNet) returns:
            %     perf - Training performance
            %     N    - The number of individual training performance values
            [trainPerf,trainN] = lib.calcMode.trainPerf(calcNet,lib.calcData,lib.calcHints);
            if lib.isMainWorker
                if lib.calcHints.perfNorm
                    Ne = max(1,trainN);
                    trainPerf = trainPerf / Ne;
                end
                reg = lib.calcHints.regularization;
                if (reg > 0)
                    wb = lib.calcMode.getwb(calcNet,lib.calcHints);
                    perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
                    if lib.calcHints.perfNorm
                        Nwb = max(1,numel(wb));
                        perfreg = perfreg / Nwb;
                    end
                    trainPerf = reg*perfreg + (1-reg)*trainPerf;
                end
            end
        end
        
        function [trainPerf,valPerf,testPerf,trainN,valN,testN] = ...
                trainValTestPerfs(lib,calcNet)
            %trainValTestPerfs Training, validation and test performances.
            %
            % WARNING: Custom training functions which rely on this method may
            % need to be updated in the future if the nnCalcLib interface changes.
            %
            %  [trainPerf,valPerf,testPerf,trainN,valN,testN] = calcLib.trainValTestPerfs(calcNet) returns:
            %     trainPerf - Training performance
            %     valPerf   - Validation performance
            %     testPerf  - Test performance
            %     trainN    - The number of individual training performance values
            %     valN      - The number of individual validation performance values
            %     testN     - The number of individual test performance values
            [trainPerf,valPerf,testPerf,trainN,valN,testN] = ...
                lib.calcMode.trainValTestPerfs(calcNet,lib.calcData,lib.calcHints);
            if lib.isMainWorker
                if lib.calcHints.perfNorm
                    Ne = max(1,trainN);
                    trainPerf = trainPerf / Ne;
                    valPerf = valPerf / valN;
                    testPerf = testPerf / testN;
                end
                reg = lib.calcHints.regularization;
                if (reg > 0)
                    wb = lib.calcMode.getwb(calcNet,lib.calcHints);
                    perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
                    if lib.calcHints.perfNorm
                        Nwb = numel(wb);
                        perfreg = perfreg / Nwb;
                    end
                    trainPerf = reg*perfreg + (1-reg)*trainPerf;
                    valPerf = reg*perfreg + (1-reg)*valPerf;
                    testPerf = reg*perfreg + (1-reg)*testPerf;
                end
            end
        end
        
        function [gWB,trainPerf,trainN] = grad(lib,calcNet)
            %GRAD Gradient and training performance.
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  The gradient is used for training algorithms like TRAINGD and
            %  TRAINSCG and <a href="matlab:help nntrain">others</a>.
            %
            %  [gWB,trainPerf,trainN] = calcLib.grad(calcNet) returns:
            %     gWB       - Vector of derivatives of training performance with
            %                 respect to the weight and bias vector.
            %     trainPerf - Training performance
            %     trainN    - The number of individual training performance values
            %
            %  See also TRAINGD, TRAINSCG, TRAINBFG, TRAINCGB, TRAINOSS, TRAINRP.
            [gWB,trainPerf,trainN] = lib.calcMode.grad(calcNet,lib.calcData,lib.calcHints);
            if lib.isMainWorker
                if(isfield(lib.calcHints.perfParam, 'L2WeightRegularization'))
                    [L2WeightsPerf, L2WeightsGrad] = msesparse.computeWeightRegularization(calcNet,lib.calcMode,lib.calcHints);
                    trainPerf = trainPerf + trainN*L2WeightsPerf;
                    gWB = gWB - trainN*L2WeightsGrad;
                end
                if(isfield(lib.calcHints.perfParam, 'sparsityRegularization'))
                    if(strcmp(lib.calcMode.mode,'nnMex'))
                        transferFunction = iGetFirstLayerTransferFunctionNNMex(lib.calcHints.long);
                        if(iHasUnitOutputRange(transferFunction))
                            [sparsePerf, sparseGrad] = msesparse.computeSparsityRegularizationNNMex(calcNet, lib.calcMode, ...
                                lib.calcHints, lib.calcData, ...
                                transferFunction, ...
                                1);
                            trainPerf = trainPerf + 2*trainN*sparsePerf;
                            gWB = gWB - 2*trainN*sparseGrad;
                        end
                    end
                    if(strcmp(lib.calcMode.mode, 'nnGPUOp'))
                        transferFunction = iGetFirstLayerTransferFunctionNNGPUOp(calcNet, lib.calcHints);
                        if(iHasUnitOutputRange(transferFunction))
                            [sparsePerf, sparseGrad] = msesparse.computeSparsityRegularizationNNGPUOp( ...
                                calcNet, lib.calcHints, ...
                                lib.calcData, transferFunction, ...
                                1);
                            trainPerf = trainPerf + 2*trainN*sparsePerf;
                            gWB = gWB - 2*trainN*sparseGrad;
                        end
                    end
                end
                if lib.calcHints.perfNorm
                    Ne = max(1,trainN);
                    gWB = gWB / Ne;
                    trainPerf = trainPerf / Ne;
                end
                reg = lib.calcHints.regularization;
                if (reg > 0)
                    wb = lib.calcMode.getwb(calcNet,lib.calcHints);
                    perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
                    gWBreg = lib.calcHints.dPerfWB(wb,lib.calcHints.perfParam);
                    if lib.calcHints.perfNorm
                        Nwb = max(1,numel(wb));
                        perfreg = perfreg / Nwb;
                        gWBreg = gWBreg / Nwb;
                    end
                    trainPerf = reg*perfreg + (1-reg)*trainPerf;
                    gWB = reg*gWBreg + (1-reg)*gWB;
                end
            end
        end
        
        function [trainPerf,valPerf,testPerf,gWB,gradient,trainN,valN,testN] ...
                = perfsGrad(lib,calcNet)
            %perfsGrad Gradient and training, validation and test performances.
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  The gradient is used for training algorithms like TRAINGD and
            %  TRAINSCG and <a href="matlab:help nntrain">others</a>.
            %
            %  [trainPerf,valPerf,testPerf,gWB,gradient,trainN,valN,testN] = calcLib.perfsGrad(calcNet) returns:
            %     trainPerf - Training performance
            %     valPerf   - Validation performance
            %     testPerf  - Test performance
            %     gWB       - Vector of derivatives of training performance with
            %                 respect to the weight and bias vector.
            %     gradient  - Gradient length (square root of sum of squared gWB)
            %     trainN    - The number of individual training performance values
            %     valN      - The number of individual validation performance values
            %     testN     - The number of individual test performance values
            %
            %  See also TRAINGD, TRAINSCG, TRAINBFG, TRAINCGB, TRAINOSS, TRAINRP.
            [trainPerf,valPerf,testPerf,gWB,trainN,valN,testN] = ...
                lib.calcMode.perfsGrad(calcNet,lib.calcData,lib.calcHints);
            if lib.isMainWorker
                if(isfield(lib.calcHints.perfParam, 'L2WeightRegularization'))
                    [L2WeightsPerf, L2WeightsGrad] = msesparse.computeWeightRegularization(calcNet,lib.calcMode,lib.calcHints);
                    trainPerf = trainPerf + trainN*L2WeightsPerf;
                    valPerf = valPerf + valN*L2WeightsPerf;
                    testPerf = testPerf + testN*L2WeightsPerf;
                    gWB = gWB - trainN*L2WeightsGrad;
                end
                if(isfield(lib.calcHints.perfParam, 'sparsityRegularization'))
                    if(strcmp(lib.calcMode.mode,'nnMex'))
                        transferFunction = iGetFirstLayerTransferFunctionNNMex(lib.calcHints.long);
                        if(iHasUnitOutputRange(transferFunction))
                            [sparsePerf, sparseGrad] = msesparse.computeSparsityRegularizationNNMex( ...
                                calcNet, lib.calcMode, ...
                                lib.calcHints, lib.calcData, ...
                                transferFunction, 3);
                            trainPerf = trainPerf + 2*trainN*sparsePerf(1);
                            valPerf = valPerf + 2*valN*sparsePerf(2);
                            testPerf = testPerf + 2*testN*sparsePerf(3);
                            gWB = gWB - 2*trainN*sparseGrad;
                        end
                    end
                    if(strcmp(lib.calcMode.mode, 'nnGPUOp'))
                        transferFunction = iGetFirstLayerTransferFunctionNNGPUOp(calcNet, lib.calcHints);
                        if(iHasUnitOutputRange(transferFunction))
                            [sparsePerf, sparseGrad] = msesparse.computeSparsityRegularizationNNGPUOp( ...
                                calcNet, lib.calcHints, ...
                                lib.calcData, transferFunction, ...
                                3);
                            trainPerf = trainPerf + 2*trainN*sparsePerf(1);
                            valPerf = valPerf + 2*valN*sparsePerf(2);
                            testPerf = testPerf + 2*testN*sparsePerf(3);
                            gWB = gWB - 2*trainN*sparseGrad;
                        end
                    end
                end
                if lib.calcHints.perfNorm
                    Ne = max(1,trainN);
                    gWB = gWB / Ne;
                    trainPerf = trainPerf / Ne;
                    valPerf = valPerf / valN;
                    testPerf = testPerf / testN;
                end
                reg = lib.calcHints.regularization;
                if (reg > 0)
                    wb = lib.calcMode.getwb(calcNet,lib.calcHints);
                    perfreg = lib.calcHints.perfWB(wb,lib.calcHints.perfParam);
                    gWBreg = lib.calcHints.dPerfWB(wb,lib.calcHints.perfParam);
                    if lib.calcHints.perfNorm
                        Nwb = max(1,numel(wb));
                        perfreg = perfreg / Nwb;
                        gWBreg = gWBreg / Nwb;
                    end
                    trainPerf = reg*perfreg + (1-reg)*trainPerf;
                    valPerf = reg*perfreg + (1-reg)*valPerf;
                    testPerf = reg*perfreg + (1-reg)*testPerf;
                    gWB = reg*gWBreg + (1-reg)*gWB;
                end
                if (nargout >= 5)
                    gradient = sqrt(sum(gWB.^2));
                end
            elseif (nargout >= 5)
                gradient = [];
            end
        end
        
        function [trainPerf,valPerf,testPerf,JE,JJ,gradient,trainN,valN,testN] ...
                = perfsJEJJ(lib,calcNet)
            %perfsJEJJ Jacobian values and training, validation and test performances.
            %
            %  WARNING: Custom training functions which rely on this method may
            %  need to be updated in the future if the nnCalcLib interface changes.
            %
            %  This function calculations Jacobian values where the Jacobian J is
            %  the derivative of errors with respect to the weight/bias vector.
            %
            %  Jacobian values require significantly more calculations than the
            %  gradient, but can be used for algorithms such as TRAINLM and
            %  TRAINBR that improve performance more per epoch than gradient
            %  algorithms.
            %
            %  [trainPerf,valPerf,testPerf,trainN,valN,testN] = calcLib.perfsJEJJ(calcNet) returns:
            %     trainPerf - Training performance
            %     valPerf   - Validation performance
            %     testPerf  - Test performance
            %     JE        - Gradient, equal to Jacobian * errors
            %     JJ        - Squared Jacobian matrix
            %     trainN    - The number of individual training performance values
            %     valN      - The number of individual validation performance values
            %     testN     - The number of individual test performance values
            %
            %  See also TRAINLM, TRAINBR.
            [trainPerf,valPerf,testPerf,JE,JJ,trainN,valN,testN] = ...
                lib.calcMode.perfsJEJJ(calcNet,lib.calcData,lib.calcHints);
            if lib.isMainWorker
                if lib.calcHints.perfNorm
                    Ne = max(1,trainN);
                    JE = JE / Ne;
                    JJ = JJ / Ne;
                    trainPerf = trainPerf / Ne;
                    valPerf = valPerf / valN;
                    testPerf = testPerf / testN;
                end
                reg = lib.calcHints.regularization;
                if (reg > 0)
                    wb = lib.calcMode.getwb(calcNet,lib.calcHints);
                    perfreg = sum(-2*wb); % MSE or SSE
                    Ereg = wb; % Jacobian has opposite sign to gradient
                    JEreg = Ereg; % Identity * Ereg
                    JJreg = eye(numel(wb)); % Identity * Identity
                    if lib.calcHints.perfNorm
                        Nreg = max(1,numel(wb));
                        perfreg = perfreg / Nreg;
                        JEreg = JEreg / Nreg;
                        JJreg = JJreg / Nreg;
                    end
                    trainPerf = reg*perfreg + (1-reg)*trainPerf;
                    valPerf = reg*perfreg + (1-reg)*valPerf;
                    testPerf = reg*perfreg + (1-reg)*testPerf;
                    JE = reg*JEreg + (1-reg)*JE;
                    JJ = reg*JJreg + (1-reg)*JJ;
                end
                if nargout >= 6
                    gradient = 2*sqrt(sum(JE.^2));
                end
            elseif (nargout >=6 )
                gradient = [];
            end
        end
        
        function y = broadcast(this,x)
            if this.isMainWorker
                y = x;
            else
                y = [];
            end
            if this.isParallel
                y = labBroadcast(this.mainWorkerInd,y);
            end
        end
    end
end

function transferFunction = iGetFirstLayerTransferFunctionNNMex(hints)
offset1 = 6 + hints(4);
offset2 = offset1 + 30;
offset3 = offset2 + hints(offset1 + 20);
offset4 = offset3 + 6*hints(offset1 + 3);
offset5 = offset4 + 5*hints(offset2 + 1);
transferFunctionNumber = hints(offset5 + 4);
transferFunction = iGetTransferFunctionNameFromNumber(transferFunctionNumber);
end

function transferFunction = iGetFirstLayerTransferFunctionNNGPUOp(calcNet, calcHints)
firstLayerIndex = calcHints.layerOrder(1);
transferFunction = calcNet.layers{firstLayerIndex}.transferFcn;
end

function transferFunction = iGetTransferFunctionNameFromNumber(x)
switch(x)
    case 1
        transferFunction = 'compet';
    case 2
        transferFunction = 'hardlim';
    case 3
        transferFunction = 'hardlims';
    case 4
        transferFunction = 'logsig';
    case 5
        transferFunction = 'netinv';
    case 6
        transferFunction = 'poslin';
    case 7
        transferFunction = 'purelin';
    case 8
        transferFunction = 'radbas';
    case 9
        transferFunction = 'radbasn';
    case 10
        transferFunction = 'satlin';
    case 11
        transferFunction = 'satlins';
    case 12
        transferFunction = 'softmax';
    case 13
        transferFunction = 'tansig';
    case 14
        transferFunction = 'tribas';
    case 15
        transferFunction = 'elliotsig';
    case 16
        transferFunction = 'elliot2sig';
    otherwise
        error(message('nnet:msesparse:TransferFunctionNotFound'));
end
end

function result = iHasUnitOutputRange( transferFunction )
outputRange = feval([transferFunction,'.outputRange']);
result = all( outputRange == [0, 1] );
end