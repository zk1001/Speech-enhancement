% OVERVIEW
% 
% The Plant Identification GUI is an interactive environment for developing
% a Neural Network capable of modeling a given plant. 
% 
% Flip through the remaining Topics for a detailed description of how 
% to use these and other Plant Identification GUI features.
% 
% MENUS
% 
% The menus provide additional options for setting up and configuring 
% the controller. The menus available are as follows.
% 
% 1) File:
%      a) Import Network: Import neural network plant model weights.
%      b) Export Network: Export neural network plant model weights.
%      c) Save: Load all parameters into the Simulink controller block.
%      d) Save and Exit: Load all parameters into the Simulink controller block and close this menu.
%      e) Exit Without Saving: Close the Plant Identification GUI and all related windows.
% 
% 2) Window:
%      Show and switch between all the open windows.
% 
% 3) Help:
%      a) Main Help: Open the general Indirect Adaptive Control GUI help text.
%      b) All other Help menus: Open tool specific help text.
% 
% NEURAL NETWORK PLANT STRUCTURE
% 
% The two-layer neural network plant has an input layer with a tansig transfer
% function. There are two sets of inputs to the plant model: delayed values of
% the plant output and delayed values of the controller output. The output 
% layer has a purelin transfer function. You can set the size of the hidden
% layer.
% For the NARMA-L2 controller, the plant model has a more complex structure.
% The inputs to the network are the same, but the network has four layers
% instead of two.  See the User's Guide for a complete description.
% 
% SIMULINK PLANT MODEL
% 
% You enter the name of a simulink file that has the plant model to be
% used in the identification process.
% 
% The Simulink model must have one inport block and one outport block.
% The Simulink model will be used to generate data for the plant
% identification.  Random inputs will be applied to the model to
% generate the training data.
% 
% NEURAL NETWORK INPUTS
% 
% The neural network plant model has two inputs available:
% 
%    1)Delayed Controller Outputs.
%    2)Delayed Plant Outputs.
% 
% For each input you must specify the number of delays to be used.
% The delays are based on the sample time defined in the Sampling Interval
% field. For each plant input, you can select any nonzero value for
% the number of delays.
% 
% The sampling time is given in seconds.
% 
% TRAINING FUNCTION
% 
% The Plant Identification algorithm has the following algorithms available
% for training:
% 
%    1) trainbfg: BFGS quasi-Newton backpropagation
%    2) trainbr:  Bayesian regularization backpropagation
%    3) traincgb: Conjugate gradient backpropagation with Powell-Beale
%                 restarts.
%    4) traincgf: Conjugate gradient backpropagation with Fletcher-Reeves
%                 updates.
%    5) traincgp: Conjugate gradient backpropagation with Polak-Ribiere
%                 updates.
%    6) traingd:  Gradient descent backpropagation.
%    7) traingdm: Gradient descent with momentum backpropagation.
%    8) traingda: Gradient descent with adaptive learning rate backpropagation.
%    9) traingdx: Gradient descent with momentum & adaptive learning rate
%                 backpropagation.
%   10) trainlm:  Levenberg-Marquardt backpropagation.
%   11) trainoss: One step secant backpropagation.
%   12) trainrp:  Resilient backpropagation algorithm (RPROP).
%   13) trainscg: Scaled conjugate gradient backpropagation.
% 
% TRAINING DATA
% 
% You have two options for obtaining the data used to train the neural
% network plant model:
% 
%    1) Import Training Data: Here you have a file with the data
%       used for training. The data is retrieved from a .mat file whose name
%       you enter in the appropriate field. The data file can contain a structure
%       with fields named U and Y for the input and output of the plant, respectively.
%       It can also obtain two individual arrays.
% 
%    2) Generate Training Data: You allow the GUI to generate the random
%       training data to be used in the identification process. You must
%       define the minimum and maximum values of the random control signal. 
%       The simulink file with the plant model is used to generate the targets.
%       If the user selects Limit Output Data, the GUI will stop the target
%       generation process each time a limit is violated. The simulation
%       process will then continue with new initial conditions. The number of
%       training samples will define how many random inputs will be applied
%       to the simulink plant to generate the targets.
% 
% The data will be normalized to a range 0-1 if you select the Normalize 
% Training Data option. This option is preferred when trainbr is used as the
% training function.
% 
% TRAINING EPOCHS
% 
% Defines the number of iterations that will be applied to train the neural
% network plant model.
% 
% USE VALIDATION/TESTING DATA
% 
% The Validation option is used to stop training early if the network
% performance on the validation data fails to improve or remains the same
% for 5 epochs in a row. 
% 
% The Testing option is used to test the generalization capability of the
% trained network.  The error on a test data set is monitored and displayed
% during training.
% 
% If any of these options are selected, 25 % of the data is used for each 
% (validation or testing) option, allowing a minmum of 50 % for training
% if both options are selected. After training, graphs are created to present
% the training data (and the validation and testing data if selected). You can
% then continue training or repeat the training with new random initial weights.

% Copyright 1992-2013 The MathWorks, Inc.
