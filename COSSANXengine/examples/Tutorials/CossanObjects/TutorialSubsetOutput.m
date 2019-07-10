%% Tutorial SubsetOutput
%
% This tutorial show how to create a SubsetOutput object

% $Copyright~1993-2011,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli$ 

%% constructor
% definition of the constructor
% The method has four outputs:
% - The name of the performance function (string)
% - The intermediary failure probabilities (numeric)
% - The coefficient of the intermediary failure probabilities (numeric)
% - The rejection rate (numeric)

Xsso1 = SubsetOutput('Sperformancefunctionname','Vg','VsubsetFailureProbability',[.1 .2 .3],'Vsubsetcov',[.1 .2 .3],'Vrejectionrates',[.1 .2 .3],'VsubsetThreshold',[1 2 3]);


%% Invalid calls to the constructor:
% the numeric fields must all be vectors
try
    Xsso2 = SubsetOutput('Sperformancefunctionname','Vg','VsubsetFailureProbability',[.1 .2 .3 ;.4 .5 .3],'VcoVpfl',[.1 .2 .3],'Vrejectionrates',[.1 .2 .3]);
    
catch ME
    OpenCossan.cossanDisp(ME.message)
end

% the numeric fields must all have the same length
try
    Xsso2 = SubsetOutput('Sperformancefunctionname','Vg','VsubsetFailureProbability',[1 2 3 ],'VcoVpfl',[.1 .2 .3],'Vrejectionrates',[1 2 3 4 5 3]);
catch ME
    OpenCossan.cossanDisp(ME.message)
end


%% merge
% The method merge allows to merge a SubsetOutput object with a SimulationData
% object
% the output of the method is an object of kind SubsetOutput

% definition of other objects
A=rand(5,3);
Tstruct=cell2struct(num2cell(A),{'RV1', 'RV2','Xrv3'},2);
Xsd =  SimulationData('Cnames',{'RV1'; 'RV2';'Xrv3'},...
    'Tvalues',Tstruct,'Mvalues',A);

% the SubsetOutput object is merged with a SimulationData object
Xsso2 = merge(Xsso1,Xsd);

% It is not possible to merge two SubsetOutput objects
try
    Xsso2 = merge(Xsso2,Xsso1);
catch ME
    disp(ME)
end
