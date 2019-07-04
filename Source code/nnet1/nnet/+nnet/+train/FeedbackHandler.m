classdef (Abstract) FeedbackHandler < handle
% FeedbackHandler Superclass for training feedback handlers

% Copyright 2010-2014 The MathWorks, Inc.

  properties (SetAccess = private)
    % Set to false in override start method to disable.
    Enable = true;
  end
  
  % Call these methods directly to handle feedback during training
  methods (Sealed)

   % Start feedback, for parallel and non-parallel training
   function start(this,useSPMD,data,net,tr,options,status)
      this.Enable = enableImpl(this,useSPMD,data,net,tr,options,status);
      if (this.Enable)
        this.startImpl(useSPMD,data,net,tr,options,status)
      end
   end
  
    % Update feedback, for non-parallel training only
    function update(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      this.updateInsideSPMDImpl(net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues);
      this.updateOutsideSPMDImpl(net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues);
    end
  
    % Update feedback compatible with SPMD, for parallel training
    function stopSPMD = updateInsideSPMD(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      if this.Enable
        stopSPMD = this.updateInsideSPMDImpl(net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues);
      else
        stopSPMD = false;
      end
    end
    
    % Update feedback not compatible with SPMD
    function updateOutsideSPMD(this,net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues)
      if this.Enable
        this.updateOutsideSPMDImpl(net,tr,options,data,calcLib,calcNet,bestNet,status,statusValues);
      end
    end
  end
  
  % Override these methods
  % Do not call directly, they are called indirectly by above methods
  methods
    % Return false if feedback method is not compatible with arguments
    % or some other reason (such as unfulfilled dependency on Java, etc)
    function enable = enableImpl(this,useSPMD,data,net,tr,options,status)
      enable = true;
    end
    
    % Start feedback
    % Always called on main MATLAB thread
    function this = startImpl(this,useSPMD,data,net,tr,options,status)
    end
    
    % Feedback that happens inside SPMD or main MATLAB thread
    % For performance reasons it is preferred that all feedback handling
    % happen here, but behavior which is incompatible with being in an
    % SPMD block must be put into updateOutsideSPMDImpl and triggered
    % by setting stopSPMD to true when it is required.  That will cause
    % the SPMD loop to break and restart. If that happens only every
    % few seconds the performance loss will be negligable.
    function [this,stopSPMD] = updateInsideSPMDImpl(this,net,tr,options,varargin)
      stopSPMD = false;
    end
    
    % Feedback that must only happen outside of SPMD block
    % Always called on MATLAB thread
    function this = updateOutsideSPMDImpl(this,net,tr,options,varargin)
    end
    
  end
end