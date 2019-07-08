function display(Xobj)
%DISPLAY  Displays the object IntervalAnalysis

%% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' object  -  Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',3);

if isempty(Xobj.Xinput)
    OpenCossan.cossanDisp('* Empty object',1);
    return
end

if isempty(Xobj.Xmodel)
    OpenCossan.cossanDisp('* No Model to be evaluated',3);
else
   OpenCossan.cossanDisp(['* Model to be evaluated'],3);
   OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.Xmodel.Cinputnames{:})],3);
   OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.Xmodel.Coutputnames{:})],3);

end


% Show Design Paremeter
OpenCossan.cossanDisp(['* * Interval Variables: ' sprintf('%s; ',Xobj.CnamesIntervalVariables{:})],2);

%% Interval output
if isempty(Xobj.Xmodel)
    OpenCossan.cossanDisp(['* * Interval output: ' sprintf('%s; ',Xobj.XobjectiveFunction.Coutputnames{:})],3);
else
    OpenCossan.cossanDisp(['* * Interval output: ' sprintf('%s; ',Xobj.Xmodel.Coutputnames{:})],3);
end


    
% if isempty(Xobj.XobjectiveFunction)
%     OpenCossan.cossanDisp('* No objective function defined',3);
% else
%     for n=1:length(Xobj.XobjectiveFunction)
%         OpenCossan.cossanDisp(['* Objective Function #' num2str(n)],3);
%         OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Cinputnames{:})],3);
%         OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Coutputnames{:})],3);
%     end
% end






