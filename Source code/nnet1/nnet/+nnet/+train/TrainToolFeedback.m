classdef TrainToolFeedback < nnet.train.FeedbackHandler
    
    % Copyright 2007-2014 The MathWorks, Inc.
    
    properties (Access = private)
        LastUpdateTime = [];
        MinDelay = [];
    end
    
    methods
        function enable = enableImpl(this,useSPMD,data,net,tr,options,status)
            enable = (net.trainParam.showWindow) && usejava('swing');
        end
        
        function startImpl(this,useSPMD,data,net,tr,options,status)
            this.LastUpdateTime = [0 0 0 0 0 0];
            if useSPMD
                this.MinDelay = 2;
            else
                this.MinDelay = 0.1;
            end
            algorithms = {net.divideFcn,net.trainFcn};
            if ~isempty(options) && isfield(options,'calcSummary')
                calcSummary = options.calcSummary;
            else
                calcSummary = 'MATLAB';
            end
            nntraintool('start',net,data,algorithms,calcSummary,status);
        end
        
        function stopSPMD = updateInsideSPMDImpl(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
            doStop = ~isempty(tr.stop);
            minDelayExceeded = (etime(clock,this.LastUpdateTime) >= this.MinDelay);
            stopSPMD = doStop || minDelayExceeded;
        end
        
        function updateOutsideSPMDImpl(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
            doStart = (tr.num_epochs == 0);
            doStop = ~isempty(tr.stop);
            newTime = clock;
            if doStart || doStop || (etime(newTime,this.LastUpdateTime) > this.MinDelay)
                nntraintool('update',net,data,calcLib,calcNet,tr,statusValues);
                this.LastUpdateTime = newTime;
            end
        end
        
    end
end
