function Xrvset_IS=defineImportanceSamplingDensity(Xinput,XrvsetUD,Cmapping)
% This function prepare the RandomVariableSet for the Importance Sampling
% based on the user defined RandomVariableSet (XrvsetUD) and the Input object
% (Xinput) defined in the problem. 

%  Check whether or not the RandomVariables in the Importance Sampling
%  density function are defined in the Xinput
%
%   Extract all random variables present in Xtarget object
%
%   The idea of this step is extracting all random variables and
%   correlations present in the target object; this information is modified
%   later on based on the Importance Sampling Density (ISD) function
%   defined by the user
%
Nrv=Xinput.NrandomVariables; % Number of RV defined in the Input object


CNamesRVSet = Xinput.CnamesRandomVariableSet; % names of RandomVariableSet 
                                              % contained in Input object
Nrvset=length(CNamesRVSet);                                     
                                              
CXrv        = cell(Nrv,1);                    % empty cell vector to store 
                                              % random variables of ISD function
                                              
Mcorrelation    = sparse(Nrv,Nrv);    %empty matrix to store correlations of ISD function

Cmembers        = cell(Nrv,1);   %empty cell to store names of random variables of ISD function

Nrvs1           = 0;    %auxiliary variable to keep track of total number of RV's processed

for irv=1:Nrvset
    Nrvs2       = length(Xinput.Xrvset.(CNamesRVSet{irv}).Cmembers);      %number of random variables to be processed
    CXrv(Nrvs1+(1:Nrvs2)) = Xinput.Xrvset.(CNamesRVSet{irv}).Xrv;        %collect random variables
    Cmembers(Nrvs1+(1:Nrvs2))  = Xinput.Xrvset.(CNamesRVSet{irv}).Cmembers;   %collect names of random variables
    Vaux        = Nrvs1+1:Nrvs1+Nrvs2;  %auxiliary vector for inserting entries of correlation matrix
    Mcorrelation(Vaux,Vaux)   = Xinput.Xrvset.(CNamesRVSet{irv}).Mcorrelation;    %correlation matrix
    Nrvs1       = Nrvs1+Nrvs2;
end
%   Prepare ISD function defined by the user
%
%   The objective of this step is define the ISD function defined by the
%   used; this is performed by inserting the data on the ISD function in
%   the variables created in the previous step
%
CRVNamesProposal    = XrvsetUD.Cmembers;   %names of random variables associated with ISD function

for i=1:length(CRVNamesProposal),   %iterate over the RV's of the proposal ISD function
    CRVName = CRVNamesProposal(i);      %current RV of the ISD being processed
    Npos    = strmatch(Cmapping(i),Cmembers,'exact');   %position of random variable
    if ~isempty(Npos),
        CXrv(Npos)  = XrvsetUD.Xrv(i);   %insert RV defined by user
        CNamesCorr  = setdiff(CRVNamesProposal,CRVName);     %check correlations between current RV and other RV's of the ISD function defined by the user
        for j=1:length(CNamesCorr),
           Nind1    = strmatch(CNamesCorr{j},Cmembers,'exact');     %check position of rv within Cmembers
           Nind2    = strmatch(CNamesCorr{j},CRVNamesProposal,'exact');     %check position of rv within CRVNamesProposal
           Mcorrelation(Npos,Nind1) = XrvsetUD.Mcorrelation(i,Nind2);    %fill correlation with corresponding data
           Mcorrelation(Nind1,Npos) = Mcorrelation(Npos,Nind1);             %fill correlation with corresponding data
        end
    else
        warning('openCOSSAN:simulations:ImportanceSampling:defineImportanceSamplingDensity',...
        ['random variable ' CRVNamesProposal{i}...
        ' defined by the user for performing Importance Sampling is ignored']);
    end
end
%   Generate RVSet modeling the ISD function defined by the user
Xrvset_IS   = RandomVariableSet('Cmembers',Cmembers,...     %members of the RV set
                'CXrv',CXrv,...     %random variables
                'Mcorrelation',Mcorrelation);   %correlations
