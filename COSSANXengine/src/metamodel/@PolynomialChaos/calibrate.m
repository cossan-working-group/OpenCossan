function Xobj = calibrate(Xobj)
%
%   MANDATORY ARGUMENTS: 
%
%   OPTIONAL ARGUMENTS: -
%
%   EXAMPLES:
%                            
%
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =========================================================================

OpenCossan.cossanDisp(['[PolynomialChaos.calibrate] Calculation of P-C coefficients using ' Xobj.Smethod ' method started'],2);

if strcmpi(Xobj.Smethod,'Galerkin')
    
    Xobj = iterativeGalerkin(Xobj);
    
elseif strcmpi(Xobj.Smethod,'Collocation')   
    
    Xobj = collocationPC(Xobj);
    
elseif strcmpi(Xobj.Smethod,'Guyan')   
    
    Xobj = guyanPC(Xobj);

end

OpenCossan.cossanDisp(['[PolynomialChaos.calibrate] Calculation of P-C coefficients using ' Xobj.Smethod ' method completed'],2);

return
