function display(Xinput)
%DISPLAY  Displays the object Input
%  This method outputs the summary of the Input object
%
% =======================================================================
% COSSAN - COmputational Simulation and Stochastic ANnalysis
% University of Innsbruck, Copyright 1993-2011 IfM
% =======================================================================


%%  Output to Screen
%   Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xinput) ' Object  - Description: ' Xinput.Sdescription ],2);
OpenCossan.cossanDisp('===================================================================',3);
% 1.2.   main paramenters
Cnames=Xinput.CnamesSet;
if ~isempty(Cnames)
    OpenCossan.cossanDisp(['* ' num2str(length(Cnames)) ' Sets of RandomVariables' ],1);
    OpenCossan.cossanDisp(['** Names: ' sprintf('"%s" ',Cnames{:})],2);
end
%% Show Parameter
Cnames=Xinput.CnamesParameter;
if ~isempty(Cnames)
OpenCossan.cossanDisp(['* ' num2str(length(Cnames)) ' Parameter object(s)' ],1);
    OpenCossan.cossanDisp(['** Names: ' sprintf('"%s" ',Cnames{:})],2);
end

%% Stochastic process
Cnames=Xinput.CnamesStochasticProcess;

if ~isempty(Cnames)
      OpenCossan.cossanDisp(['* ' num2str(length(Cnames)) ' StochasticProcesses object(s)' ],1);
    OpenCossan.cossanDisp(['** Names: ' sprintf('"%s" ',Cnames{:})],2);
end

%% Show Function
Cnames=Xinput.CnamesFunction;
if ~isempty(Cnames)
OpenCossan.cossanDisp(['* ' num2str(length(Cnames)) ' Functions object(s)' ],1);
    OpenCossan.cossanDisp(['** Names: ' sprintf('"%s" ',Cnames{:})],2);
end

%% Show DesignVariable
Cnames=Xinput.CnamesDesignVariable;
if ~isempty(Cnames)
OpenCossan.cossanDisp(['* ' num2str(length(Cnames)) ' DesignVariable object(s)' ],1);
    OpenCossan.cossanDisp(['** Names: ' sprintf('"%s" ',Cnames{:})],2);
end

%% Show Interval Variables
Cnames=Xinput.CnamesBoundedSet;
if ~isempty(Cnames)
    OpenCossan.cossanDisp(['* ' num2str(length(Cnames)) ' Set(s) of Intervals' ],1);
    OpenCossan.cossanDisp(['** Name(s): ' sprintf('"%s" ',Cnames{:})],2);
end


if ~isempty(Xinput.Xsamples)
    OpenCossan.cossanDisp('------------------------------------------',3)
    OpenCossan.cossanDisp ('Sample set present',2)
    Crv=Xinput.CnamesRandomVariable;
    
    if isa(Xinput.Xsamples,'Samples')
        display(Xinput.Xsamples)
    else
        Nsmp=min(5,size(Xinput.Xsamples,1));
        for irv=1:min(length(Crv),10)
            OpenCossan.cossanDisp([Crv{irv} ': ' sprintf('%10.3e',Xinput.Xsamples(1:Nsmp,irv)) ' ...'],3)
        end
        OpenCossan.cossanDisp(['Nsamples=' num2str(get(Xinput,'Nsamples')),2])
    end
end
