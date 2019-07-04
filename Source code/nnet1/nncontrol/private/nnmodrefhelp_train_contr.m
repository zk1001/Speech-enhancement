% TRAINING THE CONTROLLER
% 
% Before training the controller, a neural network plant model must first 
% be correctly identified. If you have not previously identified the plant, 
% then click the Plant Identification button, which will open an identification
% window.
% 
% The controller training algorithm needs the following parameters:
% 
%    1) Size of the Hidden layer: Define how many neurons will be in the hidden
%       layer of the controller.
%    2) Reference Model: A simulink file, with inport and outport blocks, used to
%       generate a reference response to train the controller.
%    3) No. Delayed Reference Inputs: defines how many delays in the reference
%       will be used to feed the controller.
%    4) No. Delayed Controller Outputs: defines how many delays in the controller
%       output will be used to feed the controller.
%    5) No. Delayed Plant Outputs: defines how many delays in the plant output
%       will be used to feed the controller.
%    6) Maximum/Minimum Reference Values: Defines the bounds on the random
%       input to the reference model.
%    7) Maximum/Minimum Interval Values: Defines the bounds on the interval
%       over which the random reference will remain constant.
%    8) Controller Training Samples: Defines the number of random values to
%       be generated to feed the reference model and therefore to be used 
%       in training the controller.
%    9) Controller Training Epochs: Defines how many epochs per segment will
%       be used during training. One segment of data is presented to the network,
%       and then the specified number of epochs of training are performed.
%       The next segment is then presented, and the process is repeated.  This
%       continues until all segments have been presented.
%   10) Controller Training Segments: Defines how many segments the training data
%       is divided into.
%   11) Use Cumulative Training: If selected, the initial training is done with
%       one segment of data.  Future training is performed by adding segments
%       to the previous training data, until the entire training data set is
%       used in the final stage. Use this option carefully due to increased training
%       time.
%   12) Use Current Weights: If selected, the current controller weights
%       are used as the initial weights for controller training.
%       Otherwise, random initial weights are generated.
%       If the controller network structure is modified, this option
%       will be overridden, and random weights will be used.
% 
% The Generate Training Data button generates training data based on the
% reference model file. You can also Import training data.  Once the training 
% data is entered, you can perform one of the following actions:
% 
%    1) Train Controller: Trains the neural network controller using
%       the available data. The previous weights are used as initial weights,
%       if that option is selected.
%    2) Apply: The weights are saved in the Neural Network Controller block.
%       You can simulate the system while this window remains open.
%    3) OK: The weights are saved in the Neural Network Controller block, and
%       the window is closed.
%    4) Cancel: The window is closed, and no values are saved.
%    5) Plant Identification: Opens a Plant Identification window.
%       You should identify the plant before performing controller
%       training.  You may also want to re-identify the plant if the
%       controller training is not satisfactory.  An accurate plant
%       model is needed for accurate controller training.
% 
% During the training process, progress report messages are shown in the
% feedback line.

% Copyright 1992-2013 The MathWorks, Inc.
