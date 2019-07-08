function display(Xobj)
%DISPLAY   Displays the information related to the RandomVariableSet
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

for irvset=1:length(Xobj)
    
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([' ' class(Xobj) ' Description: ' Xobj.Sdescription ] ,3);
    OpenCossan.cossanDisp('===================================================================',3);
    
    NmaxShowRV=10;
    
    if Xobj(irvset).Lindependence
    OpenCossan.cossanDisp([' Set of ' num2str(Xobj(irvset).Nrv) ' independent Random Variables'],2)
    else
      OpenCossan.cossanDisp([' Set of ' num2str(Xobj(irvset).Nrv) ' CORRELATED Random Variables'],2)  
      
    end
    
    if length(Xobj(irvset).Cmembers)<=NmaxShowRV
        OpenCossan.cossanDisp([' * Names: ' ...
            sprintf('"%s" ',Xobj(irvset).Cmembers{:}) ],3);
    end
    
    if ~Xobj(irvset).Lindependence    
        if Xobj(irvset).LanalyticalCopula
            OpenCossan.cossanDisp(' * Copula used: Analytical ',2);
        else
            OpenCossan.cossanDisp(' * Copula used: Numerical',2);
        end
        % Show Correlation Matrix
        OpenCossan.cossanDisp(' * Correlation Matrix',2);
        disp(Xobj.Mcorrelation(1:min(end,NmaxShowRV),1:min(end,NmaxShowRV)));
    end
end


