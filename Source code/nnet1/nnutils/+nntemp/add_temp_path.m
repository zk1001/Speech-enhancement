function add_temp_path
%ADD_TEMP_PATH Add temporary NNET directory to path.

% Copyright 1992-2011 The MathWorks, Inc.
  
%persistent done
%if isempty(done)
    nntempdir=fullfile(tempdir,'matlab_nnet');
    if ~exist(nntempdir,'dir')
        mkdir(tempdir,'matlab_nnet')
    end
    if isempty(strfind(path,nntempdir))
        path(path,nntempdir);
    end
%    done=1;
%end
