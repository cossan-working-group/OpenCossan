function display(Xobj)
%DISPLAY  Displays the summary of the  SolutionSequence object 
%
% =========================================================================
% COSSAN - Computational Stochastic Simulation Analysis
% University of Innsbruck, Austria, European Union
% Copyright 1993-2011
% =========================================================================

%%  Output to Screen
%  Name and description
OpenCossan.cossanDisp('===================================================================',2);
OpenCossan.cossanDisp([ class(Xobj) ' - Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',2);


if ~isempty(Xobj.Cinputnames)
    OpenCossan.cossanDisp([' * Input Variables: ' sprintf('%s; ',Xobj.Cinputnames{:})],2)
end
if ~isempty(Xobj.Coutputnames)
    OpenCossan.cossanDisp([' * Output Variables: ' sprintf('%s; ',Xobj.Coutputnames{:})],2)
end

if isempty(Xobj.CobjectsNames)
   OpenCossan.cossanDisp(' * No COSSAN object(s) required to evaluate the SolutionSequence',2) 
else
   OpenCossan.cossanDisp(' * Cossan Objects included:',2) 
    for n=1:length(Xobj.CobjectsNames)
        OpenCossan.cossanDisp(sprintf('   * %s of type %s',Xobj.CobjectsNames{n},Xobj.CobjectsTypes{n}),2)
    end
end

if isempty(Xobj.XjobManager)
    OpenCossan.cossanDisp(' * No Job Managar defined',2) 
else
    OpenCossan.cossanDisp(' * Solution Sequence evaluated using JobManager',2) 
    Stext=[' * Queue: ',Xobj.XjobManager.Squeue];
    if ~isempty(Xobj.XjobManager.Shostname)
        Stext=[Stext,'; Hostname: ',Xobj.XjobManager.Shostname];
    end
    OpenCossan.cossanDisp(Stext,2) 
end



