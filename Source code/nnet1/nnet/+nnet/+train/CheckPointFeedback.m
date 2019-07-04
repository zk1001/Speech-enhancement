classdef CheckPointFeedback < nnet.train.FeedbackHandler

% Copyright 2007-2014 The MathWorks, Inc.

  properties (Access = private)
    CheckpointTime = [];
    CheckpointCount = [];
  end
  
  methods
    function enable = enableImpl(this,useSPMD,data,net,tr,options,status)
      enable = ~isempty(options) && ~isempty(options.CheckpointFile);
    end
    
    function startImpl(this,useSPMD,data,net,tr,options,status)
      this.CheckpointTime = clock;
      this.CheckpointCount = 0;
    end
    
    function stopSPMD = updateInsideSPMDImpl(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      % Stop SPMD if write is required
      firstWrite = (tr.num_epochs == 0);
      intermediateWrite = etime(clock,this.CheckpointTime) > options.CheckpointDelay;
      lastWrite = ~isempty(tr.stop);
      stopSPMD = firstWrite || intermediateWrite || lastWrite;
    end
      
    function updateOutsideSPMDImpl(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      % Perform write outside SPMD
      [this.CheckpointTime,this.CheckpointCount] = ...
        nnet.checkpoint.write(net,calcLib,bestNet,tr,options,this.CheckpointTime,this.CheckpointCount);
    end
    
  end
end

