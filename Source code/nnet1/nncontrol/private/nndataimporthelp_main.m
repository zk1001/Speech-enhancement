% OVERVIEW
% 
% The Import Data window allows you to import training data from the
% workspace or from a file. The data can be imported in a structure that
% contains two fields: the input (struct.U) and the output (struct.Y).
% It can also be imported as two arrays, an input array and an output array.
% 
% Flip through the remaining Topics for a detailed description of how 
% to use the Import Data window.
% 
% SELECTIONS
% 
% There are four selections in the Import Data window:
% 
% 1) Structures:
%      If this is selected, the data will be expected in structure format.
%      The input data should be stored in name.U, and the output data
%      should be stored in name.Y
% 
% 2) Arrays:
%      If this is selected, the data will be expected in array format.
%      The input data should be stored one array, and the output data
%      should be stored in another array.  The two arrays should have
%      the same dimensions.
% 
% 3) Workspace:
%      If you select Workspace, then you will retrieve the data
%      from the workspace.  The workspace contents will be displayed
%      (if it contains valid structures or arrays), and you can select any 
%      available structure (or input and output arrays).
% 
% 4) MAT-file:
%      With this option selected, you will retrieve the data from
%      a disk file in .mat format.  You can enter the filename, or
%      Browse the disk to locate a file.  After you select a file,
%      the contents of the file are displayed (if it contains valid
%      structures or arrays).  Then you select the appropriate structure
%      or arrays by clicking the corresponding arrow button.

% Copyright 1992-2013 The MathWorks, Inc.
