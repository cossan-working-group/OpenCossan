function display(Xobj)
%DISPLAY  Displays the object UncertaintyPropagation


%% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' object  -  Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',3);

if isempty(Xobj)
    OpenCossan.cossanDisp('* Empty object',1);
    return
end

OpenCossan.cossanDisp( '* ProbabilistiModel to be evaluated',3);
OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.Xmodel.Cinputnames{:})],3);
OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.Xmodel.Coutputnames{:})],3);

OpenCossan.cossanDisp(['* * Simulation method: ',class(Xobj.Xsimulator)],2);

% Show Design Paremeter
OpenCossan.cossanDisp(['* Design Parameters: ' sprintf('%s; ', Xobj.CintervalVariableNames{:})],2);

% %% Objective function
% if isempty(Xobj.XobjectiveFunction)
%     OpenCossan.cossanDisp('* No objective function defined',3);
% else
%     for n=1:length(Xobj.XobjectiveFunction)
%         OpenCossan.cossanDisp(['* Objective Function #' num2str(n)],3);
%         OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Cinputnames{:})],3);
%         OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Coutputnames{:})],3);
%     end
% end

% %% constraint
% if isempty(Xobj.Xconstraint)
%     OpenCossan.cossanDisp('* No constraints defined',3);
% else
%     for n=1:length(Xop.Xconstraint)
%         OpenCossan.cossanDisp(['* Constraint #' num2str(n)],3);
%         OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.Xconstraint(n).Cinputnames{:})],3);
%         OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.Xconstraint(n).Coutputnames{:})],3);
%     end
% end

% %% Show details for metamodel
% if isempty(Xobj.SmetamodelType)
%    OpenCossan.cossanDisp('* No meta-model type defined',3);
% else
%    OpenCossan.cossanDisp(['* Meta-model type: ' Xobj.SmetamodelType],3);
%     for n=1:2:length(Xobj.CmetamodelProperties)
%         OpenCossan.cossanDisp(['* * Property Name: ' Xobj.CmetamodelProperties{n}],3);
%     end
% end




