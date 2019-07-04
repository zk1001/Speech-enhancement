classdef (Abstract) ScriptGenerator
    % SCRIPTGENERATOR - This abstract class is used to group together
    % functions that are used to generate training scripts for neural
    % networks.
    
    % Copyright 2014 The MathWorks, Inc.
        
    properties(Access = protected, Constant)
        AdvancedCodeForProcessFunctions = {
            '% Choose Input and Output Pre/Post-Processing Functions', ...
            '% For a list of all processing functions type: help nnprocess', ...
            'net.input.processFcns = {''removeconstantrows'',''mapminmax''};', ...
            'net.output.processFcns = {''removeconstantrows'',''mapminmax''};', ...
            ''
            };
        CommentForPlotFunctions = {
            '% Choose Plot Functions', ...
            '% For a list of all plot functions type: help nnplot', ...
            };
        CodeForPlotFunctionsForDynamicNetwork = {
            'net.plotFcns = {''plotperform'',''plottrainstate'', ''ploterrhist'', ...', ...
            '  ''plotregression'', ''plotresponse'', ''ploterrcorr'', ''plotinerrcorr''};', ...
            ''
            };
        CodeForTrainingAndTestingStaticNetwork = {
            '% Train the Network', ...
            '[net,tr] = train(net,x,t);', ...
            '', ...
            '% Test the Network', ...
            'y = net(x);', ...
            'e = gsubtract(t,y);', ...
            'performance = perform(net,t,y)'
            };
        CodeForTrainingAndTestingDynamicNetwork = {
            '% Train the Network', ...
            '[net,tr] = train(net,x,t,xi,ai);', ...
            '', ...
            '% Test the Network', ...
            'y = net(x,xi,ai);', ...
            'e = gsubtract(t,y);', ...
            'performance = perform(net,t,y)', ...
            ''
            };
        CodeForViewingNetwork = {
            '% View the Network', ...
            'view(net)', ...
            ''
            };
        CommentForPlots = {
            '% Plots', ...
            '% Uncomment these lines to enable various plots.', ...
            };
        CodeForPlotsForDynamicNetwork = {
            '%figure, plotperform(tr)', ...
            '%figure, plottrainstate(tr)', ...
            '%figure, ploterrhist(e)', ...
            '%figure, plotregression(t,y)', ...
            '%figure, plotresponse(t,y)', ...
            '%figure, ploterrcorr(e)', ...
            '%figure, plotinerrcorr(x,e)', ...
            ''
            };
        AdvancedCodeForRecalculatedPerformanceForStaticNetwork = {
            '% Recalculate Training, Validation and Test Performance', ...
            'trainTargets = t .* tr.trainMask{1};', ...
            'valTargets = t .* tr.valMask{1};', ...
            'testTargets = t .* tr.testMask{1};', ...
            'trainPerformance = perform(net,trainTargets,y)', ...
            'valPerformance = perform(net,valTargets,y)', ...
            'testPerformance = perform(net,testTargets,y)', ...
            ''
            };
        AdvancedCodeForRecalculatedPerformanceForDynamicNetwork = {
            '% Recalculate Training, Validation and Test Performance', ...
            'trainTargets = gmultiply(t,tr.trainMask);', ...
            'valTargets = gmultiply(t,tr.valMask);', ...
            'testTargets = gmultiply(t,tr.testMask);', ...
            'trainPerformance = perform(net,trainTargets,y)', ...
            'valPerformance = perform(net,valTargets,y)', ...
            'testPerformance = perform(net,testTargets,y)', ...
            ''
            };
        CodeForMatrixOnlyDeploymentForStaticNetwork = {
            'if (false)', ...
            '  % Generate a matrix-only MATLAB function for neural network code', ...
            '  % generation with MATLAB Coder tools.', ...
            '  genFunction(net,''myNeuralNetworkFunction'',''MatrixOnly'',''yes'');', ...
            '  y = myNeuralNetworkFunction(x);', ...
            'end'
            };
        CodeForMatrixOnlyDeploymentForNAROrTimeDelayNetwork = {
            'if (false)', ...
            '  % Generate a matrix-only MATLAB function for neural network code', ...
            '  % generation with MATLAB Coder tools.', ...
            '  genFunction(net,''myNeuralNetworkFunction'',''MatrixOnly'',''yes'');', ...
            '  x1 = cell2mat(x(1,:));', ...
            '  xi1 = cell2mat(xi(1,:));', ...
            '  y = myNeuralNetworkFunction(x1,xi1);', ...
            'end'
            };
        CodeForSimulink = {
            'if (false)', ...
            '  % Generate a Simulink diagram for simulation or deployment with.', ...
            '  % Simulink Coder tools.', ...
            '  gensim(net);', ...
            'end'
            };
    end
    
    properties(Access = protected, Dependent)
        AdvancedCodeForDeploymentForStaticNetwork
        AdvancedCodeForDeploymentForNAROrTimeDelayNetwork
    end
    
    methods(Abstract)
        code = generateSimpleScript(this)
        code = generateAdvancedScript(this)
    end
    
    methods
        function code = get.AdvancedCodeForDeploymentForStaticNetwork(this)
            code = [
                this.generateCodeForDeployment('x'), ...
                this.CodeForMatrixOnlyDeploymentForStaticNetwork, ...
                this.CodeForSimulink
                ];
        end
        
        function code = get.AdvancedCodeForDeploymentForNAROrTimeDelayNetwork(this)
            code = [
                this.generateCodeForDeployment('x,xi,ai'), ...
                this.CodeForMatrixOnlyDeploymentForNAROrTimeDelayNetwork, ...
                this.CodeForSimulink
                ];
        end
    end
    
    methods(Access = protected, Static)
        function code = generateCommentForDateOfCreation()
            code = ['% Created ' datestr(now) ''];
        end
        
        function code = generateCodeForDataDefinitionForStaticNetwork(sampleByColumn, ...
                inputName, targetName)
            transpose = '''';
            if sampleByColumn
                code = { ['x = ' inputName ';'], ['t = ' targetName ';'] };
            else
                code = { ['x = ' inputName transpose ';'], ['t = ' targetName transpose ';'] };
            end
        end
        
        function code = generateCodeForDataDefinitionForNARXOrTimeDelayNetwork(sampleByColumn, ...
                timestepInCell, inputName, feedbackOrTargetName)
            
            if(sampleByColumn && timestepInCell)
                code = {
                    ['X = ' inputName ';'], ...
                    ['T = ' feedbackOrTargetName ';']
                    };
            else
                code = {
                    ['X = tonndata(' inputName ',' mat2str(sampleByColumn) ',' mat2str(timestepInCell) ');'], ...
                    ['T = tonndata(' feedbackOrTargetName ',' mat2str(sampleByColumn) ',' mat2str(timestepInCell) ');']
                    };
            end
        end
        
        function code = generateCodeForTrainingFunction(trainingFunction)
            trainInfo = feval(trainingFunction,'info');
            trainingDescription = trainInfo.description;
            code = {
                '% Choose a Training Function', ...
                '% For a list of all training functions type: help nntrain', ...
                '% ''trainlm'' is usually fastest.', ...
                '% ''trainbr'' takes longer but may be better for challenging problems.', ...
                '% ''trainscg'' uses less memory. Suitable in low memory situations.', ...
                ['trainFcn = ''' trainingFunction ''';  % ' trainingDescription ''], ...
                '', ...
                };
        end
        
        function code = generateCodeForDataPreparation(inputTimeSeries)
            code = {
                '% Prepare the Data for Training and Simulation', ...
                '% The function PREPARETS prepares timeseries data for a particular network,', ...
                '% shifting time by the minimum amount to fill input states and layer', ...
                '% states. Using PREPARETS allows you to keep your original time series data', ...
                '% unchanged, while easily customizing it for networks with differing', ...
                '% numbers of delays, with open loop or closed loop feedback modes.', ...
                ['[x,xi,ai,t] = preparets(net,' inputTimeSeries ',T);'], ...
                ''
                };
        end
        
        function code = generateCodeForDataDivision(trainPercent, testPercent, validatePercent, ...
                divideMode, advanced)
            dataDivisionComment = {'% Setup Division of Data for Training, Validation, Testing'};
            dataDivisionAdvanced = {
                '% For a list of all data division functions type: help nndivide', ...
                'net.divideFcn = ''dividerand'';  % Divide data randomly', ...
                ['net.divideMode = ''' divideMode ''';  % Divide up every sample']
                };
            dataDivisionCode = {
                ['net.divideParam.trainRatio = ' mat2str(trainPercent) '/100;'], ...
                ['net.divideParam.valRatio = ' mat2str(testPercent) '/100;'], ...
                ['net.divideParam.testRatio = ' mat2str(validatePercent) '/100;'], ...
                ''
                };
            if advanced
                code = [dataDivisionComment dataDivisionAdvanced dataDivisionCode];
            else
                code = [dataDivisionComment dataDivisionCode];
            end
        end
        
        function code = generateCodeForPerformanceFunction(performFunction)
            performInfo = feval(performFunction,'info');
            performName = performInfo.name;
            code = {
                '% Choose a Performance Function', ...
                '% For a list of all performance functions type: help nnperformance', ...
                ['net.performFcn = ''' performFunction ''';  % ' performName], ...
                ''
                };
        end
        
        function code = generateAdvancedCodeForTrainingDynamicNetwork(performFunction)
            code = [
                nnet.genscript.ScriptGenerator.generateCodeForPerformanceFunction(performFunction), ...
                nnet.genscript.ScriptGenerator.CommentForPlotFunctions, ...
                nnet.genscript.ScriptGenerator.CodeForPlotFunctionsForDynamicNetwork
                ];
        end
        
        function code = generateCodeForClosedLoop(inputTimeSeries)
            code = {
                '% Closed Loop Network', ...
                '% Use this network to do multi-step prediction.', ...
                '% The function CLOSELOOP replaces the feedback input with a direct', ...
                '% connection from the outout layer.', ...
                'netc = closeloop(net);', ...
                'netc.name = [net.name '' - Closed Loop''];', ...
                'view(netc)', ...
                ['[xc,xic,aic,tc] = preparets(netc,' inputTimeSeries ',{},T);'], ...
                'yc = netc(xc,xic,aic);', ...
                'closedLoopPerformance = perform(net,tc,yc)', ...
                ''
                };
        end

        function code = generateCodeForStepAheadPrediction(inputSignal, inputTimeSeries)
            code = {
                '% Step-Ahead Prediction Network', ...
                '% For some applications it helps to get the prediction a timestep early.', ...
                '% The original network returns predicted y(t+1) at the same time it is', ...
                ['% given ' inputSignal '(t+1). For some applications such as decision making, it would'], ...
                ['% help to have predicted y(t+1) once ' inputSignal '(t) is available, but before the'], ...
                '% actual y(t+1) occurs. The network can be made to return its output a', ...
                '% timestep early by removing one delay so that its minimal tap delay is now', ...
                '% 0 instead of 1. The new network returns the same outputs as the original', ...
                '% network, but outputs are shifted left one timestep.', ...
                'nets = removedelay(net);', ...
                'nets.name = [net.name '' - Predict One Step Ahead''];', ...
                'view(nets)', ...
                ['[xs,xis,ais,ts] = preparets(nets,' inputTimeSeries ',T);'], ...
                'ys = nets(xs,xis,ais);', ...
                'stepAheadPerformance = perform(nets,ts,ys)', ...
                ''
                };
        end
        
        function code = generateCodeForDeployment(inputVariables)
            code = {
                '% Deployment', ...
                '% Change the (false) values to (true) to enable the following code blocks.', ...
                '% See the help for each generation function for more information.', ...
                'if (false)', ...
                '  % Generate MATLAB function for neural network for application', ...
                '  % deployment in MATLAB scripts or with MATLAB Compiler and Builder', ...
                '  % tools, or simply to examine the calculations your trained neural', ...
                '  % network performs.', ...
                '  genFunction(net,''myNeuralNetworkFunction'');', ...
                ['  y = myNeuralNetworkFunction(' inputVariables ');'], ...
                'end'
                };
        end
    end
end