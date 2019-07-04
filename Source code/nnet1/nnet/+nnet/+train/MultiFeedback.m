classdef MultiFeedback < nnet.train.FeedbackHandler

% Copyright 2010-2014 The MathWorks, Inc.
  
  properties
    Handlers;
  end
  
  methods
    
    % Constructor
    function this = MultiFeedback(handlers)
      this.Handlers = handlers;
    end
    
    % Override for pre-training setup
    function startImpl(this,useSPMD,data,net,tr,options,status)
      for i=1:numel(this.Handlers)
        this.Handlers{i}.start(useSPMD,data,net,tr,options,status);
      end
    end
    
    % Override for actions at each iteration if they are compatible with
    % happening inside an SPMD block.  Alternately return true when
    % a break from the SPMD block is required for an outside SPMD action.
    function stopSPMD = updateInsideSPMDImpl(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      stopSPMD = false;
      for i=1:numel(this.Handlers)
        s = this.Handlers{i}.updateInsideSPMD(net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues);
        stopSPMD = stopSPMD || s;
      end
    end
    
    % Override for outside SPMD actions
    function updateOutsideSPMDImpl(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      for i=1:numel(this.Handlers)
        this.Handlers{i}.updateOutsideSPMD(net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues);
      end
    end
    
  end % Methods
end