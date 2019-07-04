function hints = netHints(net,hints)

% Copyright 2013-2015 The MathWorks, Inc.

net = struct(net);
net = nnet.codegen.weedProcessSteps(net);

% Dimensions
hints.numInputs = net.numInputs;
hints.numLayers = net.numLayers;
hints.numOutputs = net.numOutputs;

hints.allWB = nn.wb_indices(net,hints,true);
hints.learnWB = nn.wb_indices(net,struct,false);
hints.initWB = getwb(net,hints.allWB);

hints.layerOrder = nn.layer_order(net);

elliotsigFcns.apply = {@elliotsig1,@elliotsig2,@elliotsig3,@elliotsig4};
elliotsigFcns.backprop = @elliotsig_backprop;
elliotsigFcns.isArrayFcn = true;
elliot2sigFcns.apply = {@elliot2sig1,@elliot2sig2,@elliot2sig3,@elliot2sig4};
elliot2sigFcns.backprop = @elliot2sig_backprop;
elliot2sigFcns.isArrayFcn = true;
hardlimFcns.apply = {@hardlim1,@hardlim2,@hardlim3,@hardlim4};
hardlimFcns.backprop = @hardlim_backprop;
hardlimFcns.isArrayFcn = true;
hardlimsFcns.apply = {@hardlims1,@hardlims2,@hardlims3,@hardlims4};
hardlimsFcns.backprop = @hardlims_backprop;
hardlimsFcns.isArrayFcn = true;
logsigFcns.apply = {@logsig1,@logsig2,@logsig3,@logsig4};
logsigFcns.backprop = @logsig_backprop;
logsigFcns.isArrayFcn = true;
netinvFcns.apply = {@netinv1,@netinv2,@netinv3,@netinv4};
netinvFcns.backprop = @netinv_backprop;
netInvFcns.isArrayFcn = true;
poslinFcns.apply = {@poslin1,@poslin2,@poslin3,@poslin4};
poslinFcns.backprop = @poslin_backprop;
poslinFcns.isArrayFcn = true;
purelinFcns.apply = {@purelin1,@purelin2,@purelin3,@purelin4};
purelinFcns.backprop = @purelin_backprop;
purelinFcns.isArrayFcn = true;
radbasFcns.apply = {@radbas1,@radbas2,@radbas3,@radbas4};
radbasFcns.backprop = @radbas_backprop;
radbasFcns.isArrayFcn = true;
satlinFcns.apply = {@satlin1,@satlin2,@satlin3,@satlin4};
satlinFcns.backprop = @satlin_backprop;
satlinFcns.isArrayFcn = true;
satlinsFcns.apply = {@satlins1,@satlins2,@satlins3,@satlins4};
satlinsFcns.backprop = @satlins_backprop;
satlinsFcns.isArrayFcn = true;
tansigFcns.apply = {@tansig1,@tansig2,@tansig3,@tansig4};
tansigFcns.backprop = @tansig_backprop;
tansigFcns.isArrayFcn = true;
tribasFcns.apply = {@tribas1,@tribas2,@tribas3,@tribas4};
tribasFcns.backprop = @tribas_backprop;
tribasFcns.isArrayFcn = true;

softmaxFcns.apply = @softmax_apply;
softmaxFcns.backprop = @softmax_backprop;
softmaxFcns.isArrayFcn = false;

mapminmaxFcns.reverse = @mapminmax_reverse;
mapminmaxFcns.backpropReverse = @mapminmax_backprop_reverse;

maeFcns.perf_1mask = @mae_1mask;
maeFcns.perf_3masks = @mae_3masks;
maeFcns.perf_dy_1mask = @mae_dy_1mask;
maeFcns.perf_dy_3masks = @mae_dy_3masks;

mseFcns.perf_1mask = @mse_1mask;
mseFcns.perf_3masks = @mse_3masks;
mseFcns.perf_dy_1mask = @mse_dy_1mask;
mseFcns.perf_dy_3masks = @mse_dy_3masks;

crossentropyFcns.perf_1mask = @crossentropy_1mask;
crossentropyFcns.perf_3masks = @crossentropy_3masks;
crossentropyFcns.perf_dy_1mask = @crossentropy_dy_1mask;
crossentropyFcns.perf_dy_3masks = @crossentropy_dy_3masks;

msesparseFcns.perf_1mask = @msesparse_1mask;
msesparseFcns.perf_3masks = @msesparse_3masks;
msesparseFcns.perf_dy_1mask = @msesparse_dy_1mask;
msesparseFcns.perf_dy_3masks = @msesparse_dy_3masks;
hints.purelinFcns = purelinFcns;

hints.maxZ = 0;
hints.maxOutProc = 0;
hints.layers = cell(net.numLayers,1);
hints.outputs = cell(net.numOutputs,1);
hints.iwzInd = zeros(net.numLayers,net.numInputs);
hints.lwzInd = zeros(net.numLayers,net.numLayers);
hints.output2layer = find(net.outputConnect);
hints.layer2output = cumsum(net.outputConnect);
for i=1:net.numLayers
    
    % Biases
    zpos = 0;
    if net.biasConnect(i)
        zpos = zpos+1;
    end
    
    % Input Weights
    for j=1:net.numInputs
        if net.inputConnect(i,j)
            zpos = zpos+1;
            hints.iwzInd(i,j) = zpos;
        end
    end
    
    % Layer Weights
    for j=1:net.numLayers
        if net.layerConnect(i,j)
            zpos = zpos+1;
            hints.lwzInd(i,j) = zpos;
        end
    end
    hints.maxZ = max(hints.maxZ,sum([net.biasConnect(i) net.inputConnect(i,:) net.layerConnect(i,:)]));
    
    % Net Input and Transfer Functions
    switch net.layers{i}.transferFcn
        case 'elliotsig', fcns = elliotsigFcns;
        case 'elliot2sig', fcns = elliot2sigFcns;
        case 'hardlim', fcns = hardlimFcns;
        case 'hardlims', fcns = hardlimsFcns;
        case 'logsig', fcns = logsigFcns;
        case 'netinv', fcns = netinvFcns;
        case 'poslin', fcns = poslinFcns;
        case 'purelin', fcns = purelinFcns;
        case 'radbas', fcns = radbasFcns;
        case 'satlin', fcns = satlinFcns;
        case 'satlins', fcns = satlinsFcns;
        case 'softmax', fcns = softmaxFcns;
        case 'tansig', fcns = tansigFcns;
        case 'tribas', fcns = tribasFcns;
    end
    hints.layers{i}.numZ = zpos;
    hints.layers{i}.transferFcns = fcns;
    hints.layers{i}.isPurelin = strcmp(net.layers{i}.transferFcn,'purelin');
    
    % Outputs
    if net.outputConnect(i)
        ii = hints.layer2output(i);
        hints.outputs{ii}.numFcns = numel(net.outputs{i}.processFcns);
        for j=1:hints.outputs{ii}.numFcns
            % Only MAPMINMAX supported
            hints.outputs{ii}.processFcns{j} = mapminmaxFcns;
        end
        hints.maxOutProc = max(hints.maxOutProc,hints.outputs{ii}.numFcns);
    end
end

% Performance
switch net.performFcn
    case 'mae', fcns = maeFcns;
    case 'mse', fcns = mseFcns;
    case 'sae', fcns = maeFcns;
    case 'sse', fcns = mseFcns;
    case 'crossentropy', fcns = crossentropyFcns;
    case 'msesparse', fcns = msesparseFcns;
end
hints.performFcns = fcns;
end

% TRANSFER FUNCTION - ARRAY FUNCTIONS

function [n,a] = elliotsig1(z1)
n=z1; a = n ./ (1 + abs(n));
end
function [n,a] = elliotsig2(z1,z2)
n=z1+z2; a = n ./ (1 + abs(n));
end
function [n,a] = elliotsig3(z1,z2,z3)
n=z1+z2+z3; a = n ./ (1 + abs(n));
end
function [n,a] = elliotsig4(z1,z2,z3,z4)
n=z1+z2+z3+z4; a = n ./ (1 + abs(n));
end
function dn = elliotsig_backprop(da,n,a)
dn = da .* (1-abs(a)).^2;
end

function [n,a] = elliot2sig1(z1)
n=z1; n2 = n.*n;  a = sign(n).*n2 ./ (1 + n2);
end
function [n,a] = elliot2sig2(z1,z2)
n=z1+z2; n2 = n.*n;  a = sign(n).*n2 ./ (1 + n2);
end
function [n,a] = elliot2sig3(z1,z2,z3)
n=z1+z2+z3; n2 = n.*n;  a = sign(n).*n2 ./ (1 + n2);
end
function [n,a] = elliot2sig4(z1,z2,z3,z4)
n=z1+z2+z3+z4; n2 = n.*n;  a = sign(n).*n2 ./ (1 + n2);
end
function dn = elliot2sig_backprop(da,n,a)
n2 = n.*n; dn = da .* (2*sign(n).*n ./ ((1+n2).^2));
end

function [n,a] = hardlim1(z1)
n=z1; if (n>=0), a=1; elseif (n<0), a=0; else a=NaN; end
end
function [n,a] = hardlim2(z1,z2)
n=z1+z2; if (n>=0), a=1; elseif (n<0), a=0; else a=NaN; end
end
function [n,a] = hardlim3(z1,z2,z3)
n=z1+z2+z3; if (n>=0), a=1; elseif (n<0), a=0; else a=NaN; end
end
function [n,a] = hardlim4(z1,z2,z3,z4)
n=z1+z2+z3+z4; if (n>=0), a=1; elseif (n<0), a=0; else a=NaN; end
end
function dn = hardlim_backprop(da,n,a)
dn = 0;
end

function [n,a] = hardlims1(z1)
n=z1; if (n>=0), a=1; elseif (n<0), a=-1; else a=NaN; end
end
function [n,a] = hardlims2(z1,z2)
n=z1+z2; if (n>=0), a=1; elseif (n<0), a=-1; else a=NaN; end
end
function [n,a] = hardlims3(z1,z2,z3)
n=z1+z2+z3; if (n>=0), a=1; elseif (n<0), a=-1; else a=NaN; end
end
function [n,a] = hardlims4(z1,z2,z3,z4)
n=z1+z2+z3+z4; if (n>=0), a=1; elseif (n<0), a=-1; else a=NaN; end
end
function dn = hardlims_backprop(da,n,a)
dn = 0;
end

function [n,a] = logsig1(z1)
n=z1; a = 1 ./ (1 + exp(-n));
end
function [n,a] = logsig2(z1,z2)
n=z1+z2; a = 1 ./ (1 + exp(-n));
end
function [n,a] = logsig3(z1,z2,z3)
n=z1+z2+z3; a = 1 ./ (1 + exp(-n));
end
function [n,a] = logsig4(z1,z2,z3,z4)
n=z1+z2+z3+z4; a = 1 ./ (1 + exp(-n));
end
function dn = logsig_backprop(da,n,a)
dn = da .* (a.*(1-a));
end

function [n,a] = netinv1(z1)
n=z1; if (n>=0), e=eps; else e=-eps; end, a=1./(n+e);
end
function[n,a] = netinv2(z1,z2)
n=z1+z2; if (n>=0), e=eps; else e=-eps; end, a=1./(n+e);
end
function[n,a] = netinv3(z1,z2,z3)
n=z1+z2+z3; if (n>=0), e=eps; else e=-eps; end, a=1./(n+e);
end
function[n,a] = netinv4(z1,z2,z3,z4)
n=z1+z2+z3+z4; if (n>=0), e=eps; else e=-eps; end, a=1./(n+e);
end
function dn = netinv_backprop(da,n,a)
if (n>=0), e=eps; else e=-eps; end, dn = da .* -(1./((n+e).^2));
end

function[n,a] = poslin1(z1)
n=z1; if (n<0), a=0; else a=n; end
end
function[n,a] = poslin2(z1,z2)
n=z1+z2; if (n<0), a=0; else a=n; end
end
function[n,a] = poslin3(z1,z2,z3)
n=z1+z2+z3; if (n<0), a=0; else a=n; end
end
function[n,a] = poslin4(z1,z2,z3,z4)
n=z1+z2+z3+z4; if (n<0), a=0; else a=n; end
end
function dn = poslin_backprop(da,n,a)
if (n < 0), dn=0; else dn=da; end
end

function[n,a] = purelin1(z1)
n=z1; a = n;
end
function[n,a] = purelin2(z1,z2)
n=z1+z2; a = n;
end
function[n,a] = purelin3(z1,z2,z3)
n=z1+z2+z3; a = n;
end
function[n,a] = purelin4(z1,z2,z3,z4)
n=z1+z2+z3+z4; a = n;
end
function dn = purelin_backprop(da,n,a)
dn = da;
end

function[n,a] = radbas1(z1)
n=z1; a = exp(-(n.*n));
end
function[n,a] = radbas2(z1,z2)
n=z1+z2; a = exp(-(n.*n));
end
function[n,a] = radbas3(z1,z2,z3)
n=z1+z2+z3; a = exp(-(n.*n));
end
function[n,a] = radbas4(z1,z2,z3,z4)
n=z1+z2+z3+z4; a = exp(-(n.*n));
end
function dn = radbas_backprop(da,n,a)
dn = da .* -2*n.*a;
end

function[n,a] = satlin1(z1)
n=z1; if (n<0), a=0; elseif (n>1), a=1; else a=n; end
end
function[n,a] = satlin2(z1,z2)
n=z1+z2; if (n<0), a=0; elseif (n>1), a=1; else a=n; end
end
function[n,a] = satlin3(z1,z2,z3)
n=z1+z2+z3; if (n<0), a=0; elseif (n>1), a=1; else a=n; end
end
function[n,a] = satlin4(z1,z2,z3,z4)
n=z1+z2+z3+z4; if (n<0), a=0; elseif (n>1), a=1; else a=n; end
end
function dn = satlin_backprop(da,n,a)
if (n>=0) && (n<=1), dn=da; else dn=0; end
end

function[n,a] = satlins1(z1)
n=z1; if (n<-1), a=-1; elseif (n>1), a=1; else a=n; end
end
function[n,a] = satlins2(z1,z2)
n=z1+z2; if (n<-1), a=-1; elseif (n>1), a=1; else a=n; end
end
function[n,a] = satlins3(z1,z2,z3)
n=z1+z2+z3; if (n<-1), a=-1; elseif (n>1), a=1; else a=n; end
end
function[n,a] = satlins4(z1,z2,z3,z4)
n=z1+z2+z3+z4; if (n<-1), a=-1; elseif (n>1), a=1; else a=n; end
end
function dn = satlins_backprop(da,n,a)
if (n>=-1) && (n<=1), dn=da; else dn=0; end
end

function[n,a] = tansig1(z1)
n=z1; a=2./(1+exp(-2*(n)))-1;
end
function[n,a] = tansig2(z1,z2)
n=z1+z2; a=2./(1+exp(-2*(n)))-1;
end
function[n,a] = tansig3(z1,z2,z3)
n=z1+z2+z3; a=2./(1+exp(-2*(n)))-1;
end
function[n,a] = tansig4(z1,z2,z3,z4)
n=z1+z2+z3+z4; a=2./(1+exp(-2*(n)))-1;
end
function dn = tansig_backprop(da,n,a)
dn = da .* (1-(a.*a));
end

function[n,a] = tribas1(z1)
n=z1; if isnan(n), a=NaN; else a=max(0,1-abs(n)); end
end
function[n,a] = tribas2(z1,z2)
n=z1+z2; if isnan(n), a=NaN; else a=max(0,1-abs(n)); end
end
function[n,a] = tribas3(z1,z2,z3)
n=z1+z2+z3; if isnan(n), a=NaN; else a=max(0,1-abs(n)); end
end
function[n,a] = tribas4(z1,z2,z3,z4)
n=z1+z2+z3+z4; if isnan(n), a=NaN; else a=max(0,1-abs(n)); end
end
function dn = tribas_backprop(da,n,a)
if abs(n)>1, dn=0; else dn=-sign(n); end
end

% TRANSFER FUNCTIONS NON-ARRAY FUNCTIONS

function a = softmax_apply(n)
minn = min(n,[],1);
expn = arrayfun(@softmax_apply_helper1,n,minn); % Array
sumexpn = sum(expn,1);
a = bsxfun(@rdivide,expn,sumexpn); % Array
end

function expn = softmax_apply_helper1(n,minn)
expn = exp(n-minn);
end

function dn = softmax_backprop(da,n,a)
[S,Q] = size(a);
a = reshape(a,S,1,Q);
at = permute(a,[2 1 3]);
da = reshape(da,S,1,Q);
eyeS = eye(S);
dn = arrayfun(@softmax_backprop_helper1,da,a,at,eyeS);
dn = sum(dn,1);
dn = reshape(dn,S,Q);
end

function dn = softmax_backprop_helper1(da,a,at,eyeS)
dn = da * (eyeS*a - a*at);
end

% OUTPUT PROCESSING - ARRAY FUNCTIONS

function x = mapminmax_reverse(y,xoffset,gain,ymin)
x = ((y-ymin)./gain)+xoffset;
end
function dy = mapminmax_backprop_reverse(dx,xoffset,gain,ymin)
dy = dx./gain;
end

% PERFORMANCE

function [perfs1,N1] = mse_1mask(t,y,en,ew,mask1,S)
e = (t-y).*en;
perfs1 = (e.^2).*ew.*mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
end

function [perfs1,perfs2,perfs3,N1,N2,N3] = mse_3masks(t,y,en,ew,mask1,mask2,mask3,S)
e = (t-y).*en;
perfs = (e.^2)*ew;
perfs1 = perfs .* mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end

function [perfs1,N1,dy] = mse_dy_1mask(t,y,en,ew,mask1,S)
e = (t-y).*en;
perfs1 = (e.^2).*ew.*mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    dy = 0;
    N1 = 0;
else
    dy = 2.*e.*en.*ew;
    N1 = 1;
end
end

function [perfs1,perfs2,perfs3,N1,N2,N3,dy] = mse_dy_3masks(t,y,en,ew,mask1,mask2,mask3,S)
e = (t-y).*en;
perfs = (e.^2)*ew;
perfs1 = perfs .* mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    dy = 0;
    N1 = 0;
else
    dy = 2.*e.*en.*ew;
    N1 = 1;
end
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end

function [perfs1,N1] = mae_1mask(t,y,en,ew,mask1,S)
e = (t-y).*en;
perfs1 = abs(e).*ew.*mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
end

function [perfs1,perfs2,perfs3,N1,N2,N3] = mae_3masks(t,y,en,ew,mask1,mask2,mask3,S)
e = (t-y).*en;
perfs = abs(e)*ew;
perfs1 = perfs .* mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end

function [perfs1,N1,dy] = mae_dy_1mask(t,y,en,ew,mask1,S)
e = (t-y).*en;
perfs1 = abs(e).*ew.*mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    dy = 0;
    N1 = 0;
else
    dy = sign(e).*en.*ew;
    N1 = 1;
end
end

function [perfs1,perfs2,perfs3,N1,N2,N3,dy] = mae_dy_3masks(t,y,en,ew,mask1,mask2,mask3,S)
e = (t-y).*en;
perfs = abs(e)*ew;
perfs1 = perfs .* mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    dy = 0;
    N1 = 0;
else
    dy = sign(e).*en.*ew;
    N1 = 1;
end
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end

function [perfs1,N1] = crossentropy_1mask(t,y,en,ew,mask1,S)
% Defined range for Y and T
if (y<eps), y = eps; elseif (y>(1-eps)), y = (1-eps); end
if (t<0), t = 0; elseif (t>1), t = 1; end
if (S>1)
  % Standard case: single term 1-of-N crossentropy
  perfs = (-t.*log(y));
else
  % Safe fallback: two term binary crossentropy
  perfs = -t.*log(y) - (1-t).*log(1-y);
end
perfs = perfs .* ew;
perfs1 = perfs.*mask1;
if isnan(perfs1)
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
end

function [perfs1,perfs2,perfs3,N1,N2,N3] = crossentropy_3masks(t,y,en,ew,mask1,mask2,mask3,S)
% Defined range for Y and T
if (y<eps), y = eps; elseif (y>(1-eps)), y = (1-eps); end
if (t<0), t = 0; elseif (t>1), t = 1; end
if (S>1)
  % Standard case: single term 1-of-N crossentropy
  perfs = (-t.*log(y));
else
  % Safe fallback: two term binary crossentropy
  perfs = -t.*log(y) - (1-t).*log(1-y);
end
perfs = perfs .* ew;
perfs1 = perfs .* mask1;
if isnan(perfs1)
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end

function [perfs1,N1,dy] = crossentropy_dy_1mask(t,y,en,ew,mask1,S)
% Defined range for Y and T
if (y<eps), y = eps; elseif (y>(1-eps)), y = (1-eps); end
if (t<0), t = 0; elseif (t>1), t = 1; end
if (S>1)
  % Standard case: single term 1-of-N crossentropy
  perfs = -t.*log(y);
else
  % Safe fallback: two term binary crossentropy
  perfs = -t.*log(y) - (1-t).*log(1-y);
end
perfs = perfs .* ew;
perfs1 = perfs.*mask1;
if isnan(perfs1)
  perfs1 = 0;
  dy = 0;
  N1 = 0;
elseif (S>1)
  % Standard case: single term 1-of-N crossentropy
  dy = (-t./y).*ew;
  N1 = 1;
else
  % Safe fallback: two term binary crossentropy
  dy = (-t./y + (1-t)./(1-y)).*ew;
  N1 = 1;
end
dy = -dy; % To match error convention
end

function [perfs1,perfs2,perfs3,N1,N2,N3,dy] = crossentropy_dy_3masks(t,y,en,ew,mask1,mask2,mask3,S)
% Defined range for Y and T
if (y<eps), y = eps; elseif (y>(1-eps)), y = (1-eps); end
if (t<0), t = 0; elseif (t>1), t = 1; end
if (S>1)
  % Standard case: single term 1-of-N crossentropy
  perfs = -t.*log(y);
else
  % Safe fallback: two term binary crossentropy
  perfs = -t.*log(y) - (1-t).*log(1-y);
end
perfs = perfs .* ew;
perfs1 = perfs .* mask1;
if isnan(perfs1)
    perfs1 = 0;
    dy = 0;
    N1 = 0;
elseif (S>1)
  % Standard case: single term 1-of-N crossentropy
  dy = (-t./y).*ew;
  N1 = 1;
else
  % Safe fallback: two term binary crossentropy
  dy = (-t./y + (1-t)./(1-y)).*ew;
  N1 = 1;
end
dy = -dy; % To match error convention
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end

function [perfs1,N1] = msesparse_1mask(t,y,en,ew,mask1,S)
e = (t-y).*en;
perfs1 = (e.^2).*ew.*mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
end

function [perfs1,perfs2,perfs3,N1,N2,N3] = msesparse_3masks(t,y,en,ew,mask1,mask2,mask3,S)
e = (t-y).*en;
perfs = (e.^2)*ew;
perfs1 = perfs .* mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    N1 = 0;
else
    N1 = 1;
end
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end

function [perfs1,N1,dy] = msesparse_dy_1mask(t,y,en,ew,mask1,S)
e = (t-y).*en;
perfs1 = (e.^2).*ew.*mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    dy = 0;
    N1 = 0;
else
    dy = 2.*e.*en.*ew;
    N1 = 1;
end
end

function [perfs1,perfs2,perfs3,N1,N2,N3,dy] = msesparse_dy_3masks(t,y,en,ew,mask1,mask2,mask3,S)
e = (t-y).*en;
perfs = (e.^2)*ew;
perfs1 = perfs .* mask1;
isNaN = isnan(perfs1);
if isNaN
    perfs1 = 0;
    dy = 0;
    N1 = 0;
else
    dy = 2.*e.*en.*ew;
    N1 = 1;
end
perfs2 = perfs .* mask2;
if isnan(perfs2)
    perfs2 = 0;
    N2 = 0;
else
    N2 = 1;
end
perfs3 = perfs .* mask3;
if isnan(perfs3)
    perfs3 = 0;
    N3 = 0;
else
    N3 = 1;
end
end
