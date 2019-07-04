% PLANT IDENTIFICATION
% 
% The Plant Identification process allows you to train a neural network
% that models the plant.  If the neural network plant model is to be used
% in training a controller, you should identify the plant before training
% the controller, and you may want to re-identify the plant when controller
% training is not satisfactory.
% 
% Plant Identification requires the following parameters:
% 
%    1) Size of the Hidden Layer: Define how many neurons will be in the hidden
%       layer of the neural network plant model.
%    2) Simulink Plant Model: A simulink file, with inport and
%       outport blocks, used to generate a plant response to train the
%       neural network plant model.
%    3) No. Delayed Controller Outputs: defines how many delays in the controller output
%        will be used to feed the NN plant model.
%    4) No. Delayed Plant Outputs: defines how many delays in the plant output will be
%       used to feed the NN plant model.
%    5) Sampling Interval (in seconds): defines the sampling interval used to collect
%       data to be used in the training process.
%    6) Training function: The training function to be used in the identification
%       process.
%    7.1) Import Training Data: If you select this option, you
%         enter a valid data file with the input-output values from the
%         plant to be used for training.
%    7.2) Generate Training Data: If you select this option, you 
%         define the range of the input, the limit on the output signal
%         (if any), and the number of training samples.
%    8) Normalize Training Data: If you select this option, the input-output 
%       data is normalized to a range 0-1.
%    9) Training Epochs: Defines how many epochs will be used during training.
%   10) Use Validation/Testing for Training: If selected, 25 % of the training
%       data will be used for validation and/or testing.
% 
% The Generate Training Data button generates training data based on the simulink plant
% model file (if selected). The input-output data will be displayed
% in another window. You can accept or refuse the data. If refused, the
% new window is closed and you can adjust parameters on the Plant
% Identification window to generate data again. If the data is accepted, you
% can then Train the Network. Once the training is concluded you can perform one
% of the following actions:
% 
%    1) Generate more data: New training data based on the simulink plant 
%       model file are generated. You can then continue training. 
%    2) Train Network: The same training data set is used, and the
%       training continues using the last generated weights.
%    3) Apply: The weights are saved in the Neural Network Plant Model block.
%       You can simulate the system while this window remains open.
%    4) OK: The weights are saved in the Neural Network Plant Model block and
%       the window is closed.
%    5) Cancel: The window is closed and no vales are saved.
% 
% During the training process, progress report messages are shown in the
% feedback line.

% Copyright 1992-2013 The MathWorks, Inc.
