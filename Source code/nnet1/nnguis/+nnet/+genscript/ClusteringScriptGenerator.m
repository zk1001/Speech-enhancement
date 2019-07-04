classdef (Sealed) ClusteringScriptGenerator < nnet.genscript.ScriptGenerator
    % CLUSTERINGSCRIPTGENERATOR - This class is used to generate training
    % scripts for "nctool" when clicking the "Simple Script" or "Advanced
    % Script" buttons on the "Save Results" page.
    
    % Copyright 2014 The MathWorks, Inc.
    
    properties(Access = private)
        InputName
        HiddenLayerDimensions
        SampleByColumn
    end
    
    properties(Access = private, Constant)
        CodeForPlotFunctionsForClusteringNetwork = {
            'net.plotFcns = {''plotsomtop'',''plotsomnc'',''plotsomnd'', ...', ...
            '  ''plotsomplanes'', ''plotsomhits'', ''plotsompos''};', ...
            ''
            };
        CodeForTrainingAndTestingClusteringNetwork = {
            '% Train the Network', ...
            '[net,tr] = train(net,x);', ...
            '', ...
            '% Test the Network', ...
            'y = net(x);', ...
            ''
            };
        CodeForPlotsForClusteringNetwork = {
            '%figure, plotsomtop(net)', ...
            '%figure, plotsomnc(net)', ...
            '%figure, plotsomnd(net)', ...
            '%figure, plotsomplanes(net)', ...
            '%figure, plotsomhits(net,x)', ...
            '%figure, plotsompos(net,x)', ...
            ''
            };
    end
    
    properties(Access = private, Dependent)
        CodeForInputDataForClusteringNetwork
        CodeForDataDefinitionForClusteringNetwork
        CodeForCreationOfClusteringNetwork
        AdvancedCodeForTrainingClusteringNetwork
    end
    
    methods
        function this = ClusteringScriptGenerator( state )
            this.InputName = state.inputName;
            this.HiddenLayerDimensions = state.net2.layers{1}.dimensions;
            this.SampleByColumn = state.sampleByColumn;
        end
        
        function code = generateSimpleScript(this)
            code = [
                this.CodeForInputDataForClusteringNetwork, ...
                this.CodeForCreationOfClusteringNetwork, ...
                this.CodeForTrainingAndTestingClusteringNetwork, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForClusteringNetwork
                ];
        end
        
        function code = generateAdvancedScript(this)
            code = [
                this.CodeForInputDataForClusteringNetwork, ...
                this.CodeForCreationOfClusteringNetwork, ...
                this.AdvancedCodeForTrainingClusteringNetwork, ...
                this.CodeForTrainingAndTestingClusteringNetwork, ...
                this.CodeForViewingNetwork, ...
                this.CommentForPlots, ...
                this.CodeForPlotsForClusteringNetwork, ...
                this.AdvancedCodeForDeploymentForStaticNetwork
                ];
        end
        
        function code = get.CodeForInputDataForClusteringNetwork(this)
            code = {
                '% Solve a Clustering Problem with a Self-Organizing Map', ...
                '% Script generated by Neural Clustering app', ...
                this.generateCommentForDateOfCreation(), ...
                '%', ...
                '% This script assumes these variables are defined:', ...
                '%', ...
                ['%   ' this.InputName ' - input data.'], ...
                '', ...
                this.CodeForDataDefinitionForClusteringNetwork, ...
                ''
                };
        end
        
        function code = get.CodeForDataDefinitionForClusteringNetwork(this)
            transpose = '''';
            if this.SampleByColumn
                code = ['x = ' this.InputName ';'];
            else
                code = ['x = ' this.InputName transpose ';'];
            end
        end
        
        function code = get.CodeForCreationOfClusteringNetwork(this)
            code = {
                '% Create a Self-Organizing Map', ...
                ['dimension1 = ' mat2str(this.HiddenLayerDimensions(1)) ';'], ...
                ['dimension2 = ' mat2str(this.HiddenLayerDimensions(2)) ';'], ...
                'net = selforgmap([dimension1 dimension2]);', ...
                ''
                };
        end
        
        function code = get.AdvancedCodeForTrainingClusteringNetwork(this)
            code = [
                this.CommentForPlotFunctions, ...
                this.CodeForPlotFunctionsForClusteringNetwork
                ];
        end
    end
end