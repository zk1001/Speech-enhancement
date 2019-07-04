% OVERVIEW
% 
% The Model Reference Control GUI is an interactive environment for
% developing neural network model reference controllers. 
% 
% There are two steps in the controller design:
%   1) Identification of a neural network plant model
%   2) Training of the neural network controller using the identified plant
%      and a specified reference model.
% 
% Flip through the remaining Topics for a detailed description of how 
% to use these and other Model Reference Control GUI features.
% 
% MENUS
% 
% The menus provide additional options for setting up and configuring 
% the controller. The menus available are as follows.
% 
% 1) File:
%      a) Import Network: Import neural network controller and plant weights
%      b) Export Network: Export controller and plant weights
%      c) Save: Load all parameters into the Simulink controller block.
%      d) Save and Exit: Load all parameters into the Simulink controller block and close this menu.
%      e) Exit Without Saving: Close the Model Reference Control GUI and all related windows.
% 
% 2) Window:
%      Show and switch between all the open windows.
% 
% 3) Help:
%      a) Main Help: Open the general Model Reference Control GUI help text.
%      b) All other Help menus: Open tool specific help text.
% 
% CONTROLLER STRUCTURE
% 
% The two-layer neural network controller has an input layer with a tansig
% transfer function. There are three sets of inputs to the controller:
% delayed reference values, delayed controller outputs and delayed plant 
% outputs. The output layer of the controller network has a purelin 
% transfer function. You can set the size of the hidden layer.
% 
% REFERENCE MODEL
% 
% In order to train the controller, you must first enter the name of a
% simulink file that contains the reference model.  The controller is
% trained so that the plant output will follow the reference model output.
% 
% The reference model must have one inport block and one outport block. The 
% reference model is used to generate training data for the Model 
% Reference Controller training algorithm.
% 
% CONTROLLER INPUTS
% 
% The controller has three inputs available:
% 
%    1)Delayed reference inputs.
%    2)Delayed controller outputs.
%    3)Delayed plant outputs.
% 
% For each input you must specify the number of delays to be used.
% The delays are based on the sample time defined in the Plant Identification
% window. For each controller input, you can select any nonzero value for
% the number of delays.
% 
% MAX/MIN REFERENCE VALUE
% 
% You must define bounds for the random reference to be used
% in the controller training. Those bounds must have a physical relation
% to the plant response obtained in the identification process. If the
% controller reference bounds are outside the range of the plant response 
% during the identification process, the controller training may not converge.
% The random reference will consist of a series of step functions of random
% height and random interval.  In addition to setting the min and max height,
% you also set the minimum and maximum intervals.

% Copyright 1992-2013 The MathWorks, Inc.
