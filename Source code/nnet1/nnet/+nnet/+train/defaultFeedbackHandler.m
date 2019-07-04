function handler = defaultFeedbackHandler

% Copyright 2014 The MathWorks, Inc.

handlers = {...
  nnet.train.CommandLineFeedback;
  nnet.train.TrainToolFeedback;
  nnet.train.CheckPointFeedback;
  };

handler = nnet.train.MultiFeedback(handlers);
