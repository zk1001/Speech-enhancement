function fig = find_training_plot(name)

% Copyright 2010 The MathWorks, Inc.
fig = nnplots.find_plot(['TRAINING_' upper(name)]);
