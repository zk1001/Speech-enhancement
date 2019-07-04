classdef CommandLineFeedback < nnet.train.FeedbackHandler

% Copyright 2007-2014 The MathWorks, Inc.

  methods
    function enable = enableImpl(this,useSPMD,data,net,tr,options,status)
      enable = net.trainParam.showCommandLine && ~isnan(net.trainParam.show);
    end
    
    function startImpl(this,useSPMD,data,net,tr,options,status)
      if ~isempty(options) && isfield(options,'calcSummary')
        calcSummary = options.calcSummary;
      else
        calcSummary = 'MATLAB';
      end
      disp(['Calculation mode: ' calcSummary])
      disp(' ')
      disp(['Training ' net.name ' with ' upper(net.trainFcn) '.']);
    end

    function stopSPMD = updateInsideSPMDImpl(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      doStart = (tr.num_epochs == 0);
      doStop = ~isempty(tr.stop);
      doIntemediate = (rem(tr.num_epochs,net.trainParam.show)==0);
      if doStart || doStop || doIntemediate
        disp(status_line(status,statusValues))
      end
      if doStop
        disp(['Training with ' upper(net.trainFcn) ' completed: ' tr.stop])
        disp(' ');
      end
      stopSPMD = false;
    end 
  end
end

function str = status_line(status,statusValues)
  numStatus = length(status);
  s = cell(1,numStatus*2-1);
  for i=1:length(status)
    s{i*2-1} = train_status_str(status(i),statusValues(i));
    if (i < numStatus)
      s{i*2} = ', ';
    end
  end
  str = [s{:}];
end

function str = train_status_str(status,value)
  if ~isfinite(status.max)
    str = [status.name ' ' num2str(value)];
  else
    str = [status.name ' ' num2str(value) '/' num2str(status.max)];
  end
end
