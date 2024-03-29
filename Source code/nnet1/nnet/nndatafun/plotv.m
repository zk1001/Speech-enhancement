function plotv(m,t)
%PLOTV Plot vectors as lines from the origin.
%
%  <a href="matlab:doc plotv">plotv</a>(M,T) takes a matrix M and optionally the plotting type T
%  (default = '-') and plots the columns of M.
%  
%  The matrix must have 2 or more rows.  If it has more than two rows,
%  only the first two are used.
%
%  For example, here is a plot of three 2-element vectors.
%
%    M = [-.4 0.7 .2; -0.5 .1 0.5];
%    <a href="matlab:doc plotv">plotv</a>(M,'-')

% Mark Beale, 1-31-92
% Copyright 1992-2014 The MathWorks, Inc.

if nargin < 1,error(message('nnet:Args:NotEnough'));end

[mr,mc] = size(m);
if mr < 2
  error(message('nnet:plotv:MatrixNot2GRows'));
end

if nargin == 1
  t = '-';
end

xy0 = zeros(1,mc);
plot([xy0 ;m(1,:)],[xy0 ;m(2,:)],t);
