function [Y,Af] = y(net,data,hints)

TEMP = zeros(1,ceil(hints.tempSizeYY/8)*8);

if nargout == 2
  [Y,Af] = nnMex2.yy(net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.Q,data.TS,hints,TEMP,hints.batch);
else
  Y = nnMex2.yy(net,data.X,data.Xi,data.Pc,data.Pd,data.Ai,data.Q,data.TS,hints,TEMP,hints.batch);
end

Y = mat2cell(Y,hints.output_sizes,ones(1,data.TS)*data.Q);
if nargout >= 2
  Af = mat2cell(Af,hints.layer_sizes,ones(1,hints.numLayerDelays)*data.Q);
end

TEMP = [];