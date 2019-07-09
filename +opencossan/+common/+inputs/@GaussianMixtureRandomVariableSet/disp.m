function disp(Xobj)
%DISPLAY Displays the information related to the
%        GaussianMixtureRandomVariableSet
%
%  Usage: display(Xobj)
%
%  Edited by EP
% ===========================================================
% COSSAN - COmputational Stochastic and Simulation  Analysis
% ===========================================================

opencossan.OpenCossan.cossanDisp('===================================================================',3);
opencossan.OpenCossan.cossanDisp([' ' class(Xobj) ' Description: ' Xobj.Sdescription ] ,1);
opencossan.OpenCossan.cossanDisp('===================================================================',3);

NmaxShowRV=5;
NmaxShowComponents=10;

if isempty(Xobj.gmDistribution)
    opencossan.OpenCossan.cossanDisp('Empty object',1);
    return
end

if length(Xobj.Ncomponents)<=NmaxShowComponents
    disp(Xobj.gmDistribution);
else
    opencossan.OpenCossan.cossanDisp([' Gaussian mixture distribution with ' ...
     sprintf('%i',Xobj.Ncomponents) ' components in ' ...
     sprintf('%i',Xobj.Nrv) ' dimensions'],1);
end

if length(Xobj.Cmembers)<=NmaxShowRV
    opencossan.OpenCossan.cossanDisp(' * List of random variables: ',2);
    opencossan.OpenCossan.cossanDisp(Xobj.Cmembers);
end




