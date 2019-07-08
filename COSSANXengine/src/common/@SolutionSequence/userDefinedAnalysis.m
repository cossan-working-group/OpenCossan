function varargout=userDefinedAnalysis(Xobj,XtargetObject)
% USERDEFINEDANALYSIS This method is used to perform a user defined anylysis
% using the object passed as argument. 
% Furthermore, it allows to use the object defined in Cxobjects with the names
% defined by CobjectsNames and returns a variable number of outputs defined by
% CoutputName
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/userDefinedAnalysis@SolutionSequence
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

OpenCossan.setLaptime('Sdescription','Starting User Defined Analysis')

%% Prepare the inputs
% Retrieve Objects and assign the defiend names
for iobj=1:length(Xobj.Cxobjects)
    renameVariable(Xobj.CobjectsNames{iobj},Xobj.Cxobjects{iobj});
end

if exist('XtargetObject','var')
    OpenCossan.cossanDisp(['[SolutionSequence:userDefinedAnalysis] Target object of type ' class(XtargetObject) ],4)
else
    OpenCossan.cossanDisp('[SolutionSequence:userDefinedAnalysis] NO Target object defined',3)
end


%% Execute the script
Coutput=Xobj.runScript;

%% Assing the created object in the base workspace with the correct name
for n=1:length(Coutput)
    OpenCossan.cossanDisp(['[SolutionSequence:userDefinedAnalysis] Assign variable ' ...
        Xobj.Coutputnames{n} ' to the base workspace '],3)
    assignin('base',Xobj.Coutputnames{n},Coutput{n});
    varargout{n}=Coutput{n};
end


OpenCossan.setLaptime('Sdescription','End SolutionSequence')
