function [Vfobj,Mdfobj]=objfunc(Xobj,varargin)

% Define global variable to store the optimum
global XoptGlobal XsimOutGlobal

% Process inputs
OpenCossan.validateCossanInputs(varargin{:})

Xmodel=Xobj.Xmodel;
Cinputnames=Xobj.Cinputnames;

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'xmodel'
            Xmodel=varargin{k+1};
        case 'xoptimizationproblem'
            XoptProb=varargin{k+1};
        case 'mreferencepoints'
            Mx=varargin{k+1};
        otherwise
            error('openCOSSAN:ObjectiveFunction:evaluate',...
                'PropertyName %s not valid', varargin{k});
    end
end


if exist('Mx','var')
    NdesignVariables = size(Mx,2); %number of design variables
    Ncandidates=size(Mx,1); % Number of candidate solutions
    
    assert(XoptProb.NdesignVariables==NdesignVariables, ...
        'openCOSSAN:ObjectiveFunction:evaluate',...
        'Number of design Variables %i does not match with the dimension of the referece point (%i)', ...
        XoptProb.NdesignVariables,NdesignVariables);
else
    NdesignVariables=0;
end

%
XinputData=Xobj.XupdatingData.split('Cnames',Cinputnames);
MoutputProvidedData=Xobj.XupdatingData.getValues('Cnames',Coutputnames);


for n=1:Ncandidates
    % Set model
    XinputUpdated=Xmodel.Xinput;
    for iDV=1:NdesignVariables
        XinputUpdated.set('Sname',Cinputnames{iDV},'CparameterValue',Mx(iDV,n));
    end
    Xmodel.Xinput=XinputUpdated;
    
    XsimDataPredicted=Xmodel.apply(XinputData.Tinput);
    MoutputPredictedData=XsimDataPredicted.getValues('Cnames',Coutputnames);
    Vfobj(n)=sum(sum((MoutputProvidedData-MoutputPredictedData).^2));
end


for iobj=1:length(Xobj)
    
    TinputSolver=Evaluator.addField2Structure(Xobj(iobj),XsimOutGlobal,Tinput);
    
    % Evalutate Obj.Function
    XoutObjective = run(Xobj(iobj),TinputSolver);
    
    % keep only the variables defined in the Coutputnames
    Mfobj(:,iobj)=XoutObjective.getValues('Cnames',Xobj(iobj).Coutputnames);
    
end



end