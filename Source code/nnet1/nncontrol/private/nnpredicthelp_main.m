% OVERVIEW
% 
% The NN Predictive Control GUI is an interactive environment for
% developing neural network predictive controllers. 
% 
% There are two steps in the controller design:
%   1) Identification of a neural network plant model.
%   2) Configuration of the controller parameters.
% 
% Flip through the remaining Topics for a detailed description of how 
% to use these and other NN Predictive Control GUI features.
% 
% MENUS
% 
% The menus provide additional options for setting up and configuring 
% the controller. The menus available are as follows.
% 
% 1) File:
%      a) Import Network: Import neural network plant weights
%      b) Export Network: Export plant weights
%      c) Save: Load all parameters into the Simulink controller block.
%      d) Save and Exit: Load all parameters into the Simulink controller block and close this menu.
%      e) Exit Without Saving: Close the NN Predictive Control GUI and all related windows.
% 
% 2) Window:
%      Show and switch between all the open windows.
% 
% 3) Help:
%      a) Main Help: Open the general NN Predictive Control GUI help text.
%      b) All other Help menus: Open tool specific help text.
% 
% CONTROLLER STRUCTURE
% 
% The neural network predictive controller is an optimization algorithm
% that uses a neural network plant model to predict future plant behavior
% over a specified time horizon.  The optimization algorithm determines
% the control signal that optimizes plant behavior over the time horizon.
% 
% CONTROLLER PARAMETERS
% 
% The controller has six parameters:
% 
%    1)Cost horizon N2. The squared error between the plant output and the
%      reference signal is minimized over the specified cost horizon.
%    2)Controller horizon. The squared controller increments are minimized
%      over the specified controller horizon.
%    3)Control weighting factor. This term multiplies the squared controller
%      increments in the performance index.  As this term is increased, the
%      control signal will become smoother.
%    4)Minimization routine. You can select a line search routine to be used
%      in the optimization process.
%    5)Search parameter alpha.  This specifies how much the performance must
%      be reduced at each iteration of the optimization algorithm.  It should
%      much less than 1.
%    6)Iterations per sample time.  Specified the number of iterations of the
%      optimization algorithm that will be performed at each sampling interval.

% Copyright 1992-2013 The MathWorks, Inc.
