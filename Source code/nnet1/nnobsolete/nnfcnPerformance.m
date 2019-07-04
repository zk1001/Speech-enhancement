classdef nnfcnPerformance < nnfcnInfo
%NNPERFORMANCEFCNINFO Data Division function info.

% Copyright 2010-2012 The MathWorks, Inc.

  properties (SetAccess = private)
  end
  
  methods
    
    function x = nnfcnPerformance(name,title,version,subfunctions,param)
      
      if nargin < 5, error(message('nnet:Args:NotEnough')); end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        error(message('nnet:nnfcnPerformance:ParamsNotArray'));
      end
      
      x = x@nnfcnInfo(name,title,'nntype.performance_fcn',version,subfunctions);
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
    end
    
  end
  
end

