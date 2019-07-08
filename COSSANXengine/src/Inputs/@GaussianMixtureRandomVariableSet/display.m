function display(Xobj)
%DISPLAY Displays the information related to the
%        GaussianMixtureRandomVariableSet
%
%  Usage: display(Xobj)
%
%  Edited by EP
% ===========================================================
% COSSAN - COmputational Stochastic and Simulation  Analysis
% ===========================================================

OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' ' class(Xobj) ' Description: ' Xobj.Sdescription ] ,1);
OpenCossan.cossanDisp('===================================================================',3);

NmaxShowRV=5;
NmaxShowComponents=10;

if isempty(Xobj.gmDistribution)
    OpenCossan.cossanDisp('Empty object',1);
    return
end

if length(Xobj.Ncomponents)<=NmaxShowComponents
    disp(Xobj.gmDistribution);
else
    OpenCossan.cossanDisp([' Gaussian mixture distribution with ' ...
     sprintf('%i',Xobj.Ncomponents) ' components in ' ...
     sprintf('%i',Xobj.Nrv) ' dimensions'],1);
end

if length(Xobj.Cmembers)<=NmaxShowRV
    OpenCossan.cossanDisp(' * List of random variables: ',2);
    OpenCossan.cossanDisp(Xobj.Cmembers);
end




