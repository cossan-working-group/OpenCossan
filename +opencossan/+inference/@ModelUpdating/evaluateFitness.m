function [Vfobj]=evaluateFitness(Xobj,Mx)
%Objective Function - Summ of the squared errors between predicted and provided
%data over all experimental data

%Input data consistency verification goes here
%

%Number of candidate solutions
Ncandidates=size(Mx,1);       
%Get the regularisation factor from Xobj
Lambda=Xobj.Regularizationfactor;
%Get the Weight error matrix
We=Xobj.Mweighterror;
%Get the Weight regularisation matrix
Wt=Xobj.Mweightregularisation;
%Get the 'Xmodel' from the 'ModelUpdating' Xobj
XmodelUpdated=Xobj.Xmodel;
%Get all the 'Inputnames' used by the previous model (Xmodel)
CfullInputnames=XmodelUpdated.Cinputnames;
%Verify if the names are members of the ModelUpdating input names
CmodelInputnames=CfullInputnames(~ismember(CfullInputnames,Xobj.Cinputnames));
%Get all the 'Outputnames' from the 'ModelUpdating ' class
Coutputnames=Xobj.Coutputnames;
XinputData=Xobj.XupdatingData.split('Cnames',CmodelInputnames);
MoutputProvidedData=Xobj.XupdatingData.getValues('Cnames',Coutputnames);
Vfobj=zeros(Ncandidates,1);
 if Xobj.LuseRegularization
     VinitialValues=Xobj.Xmodel.Xinput.getValues('Cnames',Xobj.Cinputnames);
 end
for n=1:Ncandidates  %Loop over all the candidate solutions
    XinputDataDesignVariable=SimulationData( ...
                                                'Mvalues',repmat(Mx(n,:),XinputData.Nsamples,1),...
                                                'Cnames',Xobj.Cinputnames);
    XfullInputData=XinputData.merge(XinputDataDesignVariable);
    XsimDataPredicted=XmodelUpdated.apply(XfullInputData.Tvalues);
    MoutputPredictedData=XsimDataPredicted.getValues('Cnames',Coutputnames);
    %Vfobj(n)=sum(sum((MoutputProvidedData-MoutputPredictedData).^2));
    Vfobj(n)=sum(sum((MoutputProvidedData-MoutputPredictedData)*We*(MoutputProvidedData-MoutputPredictedData)'));
    if Xobj.LuseRegularization
        %Vregularization=Lambda.^2*sum((Mx(n,:)-VinitialValues).^2);
        Vregularization=Lambda.^2*((Mx(n,:)-VinitialValues)*Wt*(Mx(n,:)-VinitialValues)');
         Vfobj(n)=Vfobj(n)+Vregularization;
    end
end