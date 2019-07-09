function varargout=evaluate(Xobj,XtargetObject)
% APPLY This method to evaluate the solution sequence defined in the script.
% It allows the object defined in Cxobjects with the names defined by
% CobjectsNames and returns a variable number of output defined by
% CoutputName
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Apply@SolutionSequence
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli

OpenCossan.setLaptime('description','Starting SolutionSequence')

%% Prepare the inputs
% Retrieve Objects and assign the defiend names
% for iobj=1:length(Xobj.Cxobjects)
%     renameVariable(Xobj.CobjectsNames{iobj},Xobj.Cxobjects{iobj});
% end

if exist('XtargetObject','var')
    OpenCossan.cossanDisp(['[SolutionSequence:apply] Target object of type ' class(XtargetObject) ],4)
else
    OpenCossan.cossanDisp('[SolutionSequence:apply] NO Target object defined',3)
end

switch class(XtargetObject)
    case 'struct'
        Nsamples=length(XtargetObject);
        TableInput=struc2table(XtargetObject);
    case 'Input'
        Nsamples=XtargetObject.Nsamples;
        TableInput=XtargetObject.getTable;
    case 'table'
        Nsamples=height(XtargetObject);
        TableInput=XtargetObject;    
    case 'SimulationData'
        Nsamples=XtargetObject.Nsamples;
        TableInput=XtargetObject.TableValues;
     otherwise
        error('openCOSSAN:SolutionSequence:apply',...
            [' Target object of type ' class(XtargetObject) ' not valid!'])
end


% Preallocate memory
Toutput=cell2struct(cell(length(Xobj.Coutputnames),Nsamples),Xobj.Coutputnames,1);

for n=1:Nsamples
    
    OpenCossan.cossanDisp(['[Status:SolutionSequence]    * Simulation ' num2str(n) '/' num2str(Nsamples)],2)
                       
    %% Prepare variables
    Cinputs=cell(length(Xobj.Cinputnames),1);
    for iinp=1:length(Xobj.Cinputnames)
        Cinputs{iinp}=TableInput.(Xobj.Cinputnames{iinp})(n);
    end
    
    Coutput=Xobj.runScript(Cinputs{:});
    
    if Xobj.LpostProcess
        % Process output
        for iout=1:length(Coutput)
            if isempty(Xobj.Cobject2output{iout})
                Toutput(n).(Xobj.Coutputnames{iout})=Coutput{iout};
            else
                Toutput(n).(Xobj.Coutputnames{iout})=eval(strcat('Coutput{iout}',Xobj.Cobject2output{iout}));
            end
        end
    else
        % Merge SimulationData object
       if n==1
           varargout=Coutput;
       else
           varargout{1}=varargout{1}.merge(Coutput{1});
       end
    end
    
end


%% Prepare the output
if Xobj.LpostProcess
    % Add input to the simulation data object
    XSimOut=opencossan.common.outputs.SimulationData('Table',struct2table(Toutput));
    varargout{1}=XSimOut;
end


OpenCossan.setLaptime('description','End evaluation SolutionSequence')
