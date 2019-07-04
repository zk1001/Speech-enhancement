function hints = codeHints(hints)

B = hints.batch;
switch(hints.precision)
  case 'single', sizeofPRECISION = 4;
  case 'double', sizeofPRECISION = 8;
end
sizeofPointer = 8;
  
% YY Temporary Memory Size
if hints.doProcessInputs
  P_size = sizeofPRECISION * hints.seriesInputProcElements * (hints.numInputDelays + hints.TS);
  Pc_size = sizeofPointer * hints.numInputs * (hints.numInputDelays + hints.TS);
else
  P_size = 0;
  Pc_size = 0;
end
Xd_size = sizeofPRECISION * hints.maxDelayedElements * B;
Z_size = sizeofPRECISION * hints.maxLayerSize * B;
N_size = sizeofPRECISION * hints.maxLayerSize * B;
Ac_size = sizeofPRECISION * hints.numLayerElements * (hints.numLayerDelays + 1) * B;
Ap_size = sizeofPRECISION * hints.maxOutProcXElements * B;
hints.tempSizeYY = P_size + Pc_size + Xd_size + Z_size + N_size + Ac_size + Ap_size;

% PERFS Temporary Memory Size
if hints.doProcessInputs
  P_size = sizeofPRECISION * hints.seriesInputProcElements * (hints.numInputDelays + hints.TS);
  Pc_size = sizeofPointer * hints.numInputs * (hints.numInputDelays + hints.TS);
else
  P_size = 0;
  Pc_size = 0;
end
Xd_size = sizeofPRECISION * hints.maxDelayedElements * B;
Z_size = sizeofPRECISION * hints.maxLayerSize * B;
N_size = sizeofPRECISION * hints.maxLayerSize * B;
Ac_size = sizeofPRECISION * hints.numLayerElements * (hints.numLayerDelays + 1) * B;
Ap_size = sizeofPRECISION * hints.maxOutProcXElements * B;
E_size = sizeofPRECISION * hints.maxOutputSize * B;
PERF_size = sizeofPRECISION * hints.maxOutputSize * B;
hints.tempSizePERFS = P_size + Pc_size + Xd_size + Z_size + N_size + Ac_size + Ap_size + E_size + PERF_size;

% BG Temporary Memory Size
if hints.doProcessInputs
  P_size = sizeofPRECISION * hints.seriesInputProcElements * (hints.numInputDelays + hints.TS) * B;
  Pc_size = sizeofPointer * hints.numInputs*(hints.numInputDelays + hints.TS) * B;
else
  P_size = 0;
  Pc_size = 0;
end
Xd_size = sizeofPRECISION * hints.maxDelayedElements * B;
Z_size = sizeofPRECISION * hints.totalZSize * hints.TS * B;
N_size = sizeofPRECISION * hints.numLayerElements * hints.TS * B;
Ac_size = sizeofPRECISION * hints.numLayerElements * (hints.numLayerDelays + hints.TS) * B;
Ap_size = sizeofPRECISION * hints.maxOutProcXElements * B;
E_size = sizeofPRECISION * hints.maxOutputSize * B;
PERF_size = sizeofPRECISION * hints.maxOutputSize * B;
dY_size = sizeofPRECISION * hints.maxOutputSize * B;
dYp_size = sizeofPRECISION * hints.maxOutProcYElements * B;
dAi_size = sizeofPRECISION * hints.numLayerElements * hints.numLayerDelays * B;
dA_size = sizeofPRECISION * hints.numLayerElements * hints.TS * B;
dN_size = sizeofPRECISION * hints.numLayerElements * B;
dZ_size = sizeofPRECISION * hints.maxLayerSize * B;
dXd_size = sizeofPRECISION * hints.maxDelayedElements * B;
hints.tempSizeBG = P_size + Pc_size + Xd_size + Z_size + N_size + Ac_size + Ap_size + E_size + PERF_size ...
   + dY_size + dYp_size + dAi_size + dA_size + dN_size + dZ_size + dXd_size;
 
% FJ Temporary Memory Size
if hints.doProcessInputs
  P_size = sizeofPRECISION * hints.seriesInputProcElements*(hints.numInputDelays + hints.TS)*B;
  Pc_size = sizeofPointer * hints.numInputs*(hints.numInputDelays + hints.TS)*B;
else
  P_size = 0;
  Pc_size = 0;
end
Xd_size = sizeofPRECISION*hints.maxDelayedElements*B;
Z_size = sizeofPRECISION*hints.maxLayerZSize*B;
N_size = sizeofPRECISION*hints.maxLayerSize*B;
Ac_size = sizeofPRECISION*hints.numLayerElements*(hints.numLayerDelays+1)*B;
Ap_size = sizeofPRECISION*hints.maxOutProcXElements*B;
E_size = sizeofPRECISION*hints.maxOutputSize*B;
PERF_size = sizeofPRECISION*hints.maxOutputSize*B;
dXd_size = sizeofPRECISION*hints.maxDelayedElements*hints.numLearningWeightElements*B;
dIWZ_size = sizeofPRECISION*hints.maxIWSizeByS*B;
dLWZ_size = sizeofPRECISION*hints.maxNumLWByS*hints.numLearningWeightElements*B;
dN_size = sizeofPRECISION*hints.maxLayerSize*hints.numLearningWeightElements*B;
dA_size = sizeofPRECISION*hints.numLayerElements*hints.numLearningWeightElements*(hints.numLayerDelays+1)*B;
dAp_size = sizeofPRECISION*hints.maxOutProcXElements*hints.numLearningWeightElements*B;
hints.tempSizeFJ= P_size + Pc_size + Xd_size + Z_size + N_size + Ac_size + Ap_size + E_size + PERF_size ...
    + dXd_size + dIWZ_size + dLWZ_size + dN_size + dA_size + dAp_size;
  

