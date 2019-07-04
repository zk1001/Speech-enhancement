function code = allModuleFunctions(net)

% Copyright 2012-2015 The MathWorks, Inc.

  import nnet.codegen.*;
  skip = {'dotprod','netsum','netprod','purelin'};
  blocks = cell(1,5);
  for i=1:5
    switch i
      case 1
        heading = 'Input Processing Function';
        modules = inputProcessingFcns(net);
        fcn = 'apply';
        structName = 'settings';

      case 2
        heading = 'Weight Function';
        modules = weightFcns(net);
        fcn = 'apply';
        structName = 'param';

      case 3
        heading = 'Net Input Function';
        modules = netInputFcns(net);
        fcn = 'apply';
        structName = 'param';

      case 4
        heading = 'Transfer Function';
        modules = transferFcns(net);
        fcn = 'apply';
        structName = 'param';

      case 5
        heading = 'Output Reverse-Processing Function';
        modules = outputProcessingFcns(net);
        fcn = 'reverse';
        structName = 'settings';
    end

    modules = setdiff(modules,skip);
    block = moduleSubfunctions(heading,modules,fcn,structName);
    blocks{i} = block;
  end
  code = combineTextBlocks(blocks);
end

function code = moduleSubfunctions(heading,modules,fcn,structName)
  import nnet.codegen.*;
  numModules = numel(modules);
  blocks = cell(1,numModules);
  for i=1:numModules
    name = feval([modules{i} '.name']);
    blocks{i} = [ ...
      {['% ' name ' ' heading]} ...
      moduleSubfunction(modules{i},fcn,structName) ...
      ];
  end
  code = combineTextBlocks(blocks);
end
