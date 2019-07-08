function display(XsensitivityMeasure)
%DISPLAY  Displays the summary of the LocalSensitivityMeasures object
%
% =======================================================================
% COSSAN - COmputational Simulation and Stochastic ANnalysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================

for n=1:length(XsensitivityMeasure)
    Xobj=XsensitivityMeasure(n);
    
    %%  Output to Screen
    %   Class and description
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([ class(Xobj) ' -  Description: ' Xobj.Sdescription ],1);
    OpenCossan.cossanDisp('===================================================================',3);
    
    %% Set parameters
    Nmaxcomponents=5;
    
    OpenCossan.cossanDisp(['* Function Name: ' Xobj.SfunctionName],1);
    
    [~, Vindex]=sort(abs(Xobj.Vgradient),'descend');
    
    OpenCossan.cossanDisp('* Sensitivity measures (reference coordinate): ',2);
    for ik=1:min(Nmaxcomponents,length(Xobj.Cnames))
        OpenCossan.cossanDisp(['** ' Xobj.Cnames{Vindex(ik)} ': '  ...
            sprintf('%10.3e',Xobj.Vgradient(Vindex(ik))) ...
            ' (' sprintf('%9.3e',Xobj.VreferencePoint(Vindex(ik))) ')' ],2);
    end
    
    if length(Xobj.Cnames)>Nmaxcomponents
        OpenCossan.cossanDisp(['* ' num2str(length(Xobj.Cnames)) ' components presents' ],2);
    end
    
    OpenCossan.cossanDisp(['* Function evaluations: ' num2str(Xobj.Nsamples) ],2);
    
    if Xobj.Lnormalized
        OpenCossan.cossanDisp('* sensitivity measure normalized',2);
    else
        OpenCossan.cossanDisp('* sensitivity measure NOT normalized',2);
    end
end
