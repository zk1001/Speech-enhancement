function y=ind2vec(x,n)
%IND2VEC Convert indices to vectors.
%
%  <a href="matlab:doc ind2vec">ind2vec</a> and <a href="matlab:doc vec2ind">vec2ind</a> allow indices to be represented either directly
%  or as column vectors containing a 1 in the row of the index they
%  represent.
%
%  <a href="matlab:doc ind2vec">ind2vec</a>(indices) takes a 1xM row of indices and returns an NxM
%  matrix, where N is the maximum index value. The result consists of
%  all zeros except a one in each column at the element indicated by
%  the respective index.
%
%  <a href="matlab:doc ind2vec">ind2vec</a>(indices,N) returns an NxM
%  matrix, where N can be equal or greater than the maximum index.
%
%  Here four indices are defined and converted to vectors and back.
%
%    ind = [1 3 2 3]
%    vec = <a href="matlab:doc ind2vec">ind2vec</a>(ind)
%    ind2 = <a href="matlab:doc vec2ind">vec2ind</a>(vec)
%
%  Here a vector with all zeros in the last row is converted to indices
%  and back while preserving the number of rows.
%
%    vec = [0 0 1 0]'
%    [ind,n] = vec2ind(vec)
%    vec2 = full(ind2vec(ind,n))
%
%  See also VEC2IND.

% Mark Beale, 2-15-96.
% Copyright 1992-2010 The MathWorks, Inc.

if nargin < 1,error(message('nnet:Args:NotEnough'));end
wasMatrix = ~iscell(x);
x = nntype.data('format',x,'Argument');
[Nx,Q,TS,M] = nnfast.nnsize(x);
if any(Nx ~= 1)
  error(message('nnet:NNData:DataNotRowVectors'));
end

Ny = zeros(M,1);
for i=1:M
  for ts = 1:TS
    xi = x{i,ts};
    if any(xi ~= floor(xi))
      error(message('nnet:NNData:DataNotInteger'));
    end
    if any(xi < 1)
      error(message('nnet:NNData:DataNotPositive'));
    end
  end
  if nargin < 2
    Ny(i) = max(Ny(i),max(xi));
  elseif isscalar(n)
    Ny(i) = n;
  else
    Ny(i) = n(i);
  end
end

y = cell(M,TS);
for i=1:M
  for ts=1:TS
    y{i,ts} = sparse(x{i,ts},1:Q,ones(1,Q),Ny(i),Q);
  end
end

if wasMatrix, y = y{1}; end
