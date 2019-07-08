%% Tutorial for the SystemReliability object
%
% This tutorial shows how to create and use the SystemReliability object in
% COSSAN-X. Please note that this tutorial presents a very simple and academic
% example. 
%
% The reliability system is composed by a physical model with 2 uncorrelated
% random variables, and a Matlab function and 3 performance functions. 
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SystemReliability
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

%% Definition of the Inputs
% Define the input parameters
% In this section the basic objects required to define a SystemReliability
% object are defined.
% A SystemReliability object contains at least two Performance functions. 
% In this tutorial the performance functions (i.e. limit state functions) are
% based on Matlab script (MIO) objects.
% There are 5 random variables (standard normal) and 2
% limit state functions. 

% Definition of the RandomVariable
RV1=RandomVariable('Sdistribution','normal','mean',0,'std',1); 
RV2=RandomVariable('Sdistribution','normal','mean',0,'std',1); 

% Definition of the Parameters
Par1=Parameter('value',0.5); 
Par2=Parameter('value',1); 

% Definition of the uncorrelated Set of random variables 
Xrvs = RandomVariableSet('CXrv',{RV1 RV2},'CSmembers',{'RV1' 'RV2'});

% Define Input Object
Xin = Input('CXmembers',{Xrvs Par1 Par2},'CSmembers',{'Xrvs' 'Par1' 'Par2'});


%%  Definition of the Model
% In this example the physical model is composed by an empty Evaluator. This
% mean that there is nothing to be computed in advance before evaluate the
% performance functions. 

% The evaluator is empty since there is nothing to be evaluated.
Xev= Evaluator;

% Define the Models
Xmdl= Model('Xevaluator',Xev,'Xinput',Xin);


%% Define a reference Probabilistic Model  with a single performance function 
% this probabilistic model contains the performance function defined by the
% intersection of the performance functions (i.e. max)
%
% This object is used for verification purpose only, we can also create a
% performance function containg all the limit state functions.
% Please note that in this case in not possible to
% compute the pf associate to each performance function.
XmALLmatrix=Mio('Sdescription', 'Performance function', ...
        'Sscript','Moutput=max(Minput(:,3)-Minput(:,1),Minput(:,4)-Minput(:,2));', ...
        'Lfunction',false, ...
        'Liostructure',false, ...
        'Liomatrix',true, ...
        'Coutputnames',{'outALL'},...
        'Cinputnames',{'RV1' 'RV2' 'Par1' 'Par2'});	
    
XpfALL=PerformanceFunction('Xmio',XmALLmatrix);
XpmALL=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',XpfALL);


%% Compute the reference solution 
% The reference solution can be estimated by means of Monte Carlo simulation using only 1
% limit state function (pf=1.2e-4) 

Xmc=MonteCarlo('Nsamples',1e4,'Nbatches',1);
% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

[XpfReference, XsimData] = XpmALL.computeFailureProbability(Xmc); 
display(XpfReference);

%% Plot evaluated points
% Retrive values from the simulation data
Vout=XsimData.getValues('Sname','outALL');
X1=XsimData.getValues('Sname','RV1');
X2=XsimData.getValues('Sname','RV2');

% Plot a scatter plot
h=figure; hold on; box on;
% %display(XpfReferenceM)
scatter(gca(h),X1(Vout<0),X2(Vout<0),'r')
scatter(gca(h),X1(Vout>0),X2(Vout>0),'g')
legend('Points in the failure region','Points in the safe region')
xlabel('RV1');ylabel('RV2');

%% Definition of the SystemReliability Model
% The first step to construct a SystemRealibility model is to define the
% performance functions. Then it is necessary to define a FaultTree object that
% contains the logic (dependecies) of the limit state functions.
% Please refer to the Tutorial of FaultTree for more details

% Define Performance Functions
XpfA=PerformanceFunction('Scapacity','Par1','Sdemand','RV1','Soutputname','Va');
XpfB=PerformanceFunction('Scapacity','Par2','Sdemand','RV2','Soutputname','Vb');

% Fault Tree object. 
CnodeTypes={'Output','AND','Input','Input'};
CnodeNames={'TopEvent','AND gate','XpfA','XpfB'};

% Be carefull with the name of the basic events. They should correspond to
% the name of the performance function.
VnodeConnections=[0 1 2 2];
% Construct a FaultTree object
Xft=FaultTree('CnodeTypes',CnodeTypes,'CnodeNames',CnodeNames,...
               'VnodeConnections',VnodeConnections, ...
               'Sdescription','FaultTree Tutorial of SystemReliability');

% Summary of the FaultTree
display(Xft)

% Display the FaultTree
Xft.plotTree

% Identify the minimal cut-sets
Xft=Xft.findMinimalCutSets;

display(Xft)           

% Now we can construct a SystemReliability object composed by the
% PerformanceFunction objects, a Model and the FaultTree

Xsys=SystemReliability('Cmembers',{'XpfA';'XpfB';},...
     'CXperformanceFunctions',{XpfA XpfB}, ...
     'Xmodel',Xmdl,'XFaultTree',Xft);

% show the System Reliability object  
display(Xsys)

%% Use the SystemReliability object 
% Now we can estimate the failure probability of the System considering 
% separately the contribute of each limit state function

% First at all we use cossan to estimate the design point for each
% performance fucntion and we store the results indide the object
% SystemReliability. This is done automatically invoking the method
% designPointIdentification of the class SystemReliability

Xsys=Xsys.designPointIdentification;
display(Xsys);

%% Add Design plot to the scatter plot
VdpA=Xsys.XdesignPoints{1}.VDesignPointPhysical;
VdpB=Xsys.XdesignPoints{2}.VDesignPointPhysical;

plot(gca(h),VdpA(1),VdpA(2),'ok','MarkerSize',10)
plot(gca(h),VdpB(1),VdpB(2),'dk','MarkerSize',10)


%% Find desing Point of the parallel system
% Find designPoint using linear hypothesis 
% It is not necessary to specify the cut-set since is already defined in
% the FaultTree included in the SystemReliability object
[~, XdpIntersection, Vcoord] = Xsys.findLinearIntersection('tolerance',1e-2);
% 
display(XdpIntersection)

% Add the design Point of the intersection of the performance function. 
% This design point corresponds to the design point that would have been
% identified considering only a single limit state function. 
plot(gca(h),Vcoord(1),Vcoord(2),'pb','MarkerSize',10)

% It is important to notice that although the single limit state function are
% linear and very simple the failure probability of the system component can not
% in general, be estimated with approximate method such as FORM/SORM.
% In fact, the associated failure probability of the parellel system based on
% the FORM method is:
display(sprintf('Failure Probability based on the FORM : %10.3e',XdpIntersection.form))
% that is really far away from the reference solution
display(sprintf('Failure Probability of the reference  : %10.3e',XpfReference.pfhat))

%% Compute the failure probability for each event
% It is possible to compute the failure probability of each individual event
% defined in the SystemRealibility object using 
Xmc=MonteCarlo('Nsamples',1e2);
Xsys=Xsys.pfComponents(Xmc);

% The failure probabilities of the components are stored in the
% SystemReliability object in the field Xsys.XfailureProbability;

% A specific Cutset can be retrieved from the SystemReliability object using the
% method getCutset

Xcs=Xsys.getCutset('VcutsetIndex',[1 2]);
display(Xcs)

%% Compute the failure probability for the cutset 1-2 (i.e. the parallel system)
% In this section the failure probability associate to the cutset 1-2 is
% computed using different sampling strategies
    %% Monte Carlo simulation
    % To begin with, the plain MonteCarlo simulation is used to estimate the failure
    % probability of the cutset 1-2
    Xmc=MonteCarlo('Nsamples',1e3);
    [XpfSystemMCS, XcsSystem, XoutMC]=Xsys.pf('Xsimulations',Xmc,'VcutsetIndex',[1 2]);
    
    % Show results of the failure probability for the cut set 1-2
    display(XpfSystemMCS)
    % the cut set 1-2
    display(XcsSystem)

    % (Ri)Compute the performance function
    [~, Vg1MCS]=Xsys.XperformanceFunctions(1).apply(XoutMC);
    [~, Vg2MCS]=Xsys.XperformanceFunctions(2).apply(XoutMC);
    VmembersMCS=false(XoutMC.Nsamples,1);
    VmembersMCS(Vg2MCS(Vg1MCS<0)<0)=true;

    % Compute fraction of samples in the Failure region
    fMCS=sum(VmembersMCS)/XoutMC.Nsamples*100;

    %% Compute the failure probability using the Importance Sampling
    Xis=ImportanceSampling('Nsamples',1e3,'XdesignPoint',XdpIntersection);
    [XpfSystemIS, ~, XoutIS]=Xsys.pf('Xsimulations',Xis,'VcutsetIndex',[1 2]);
    display(XpfSystemIS)

    % (Ri)Compute the performance function
    [~, Vg1IS]=Xsys.XperformanceFunctions(1).apply(XoutIS);
    [~, Vg2IS]=Xsys.XperformanceFunctions(2).apply(XoutIS);
    VmembersIS=false(XoutMC.Nsamples,1);
    VmembersIS(Vg2IS(Vg1IS<0)<0)=true;

    % Compute fraction of samples in the Failure region
    fIS=sum(VmembersIS)/XoutIS.Nsamples*100;

    display(sprintf('Efficiency of the sample method increased from %5.2f%% to %5.2f%%',...
        fMCS,fIS))

    %% Compute the failure probability using an high performance importance sampling procedure
    [XpfSystemHPIS, ~, XoutHPIS]=Xsys.HPIS('VcutsetIndex',[1 2]);

    display(XpfSystemHPIS)
    % (Ri)Compute the performance function
    [~, Vg1HPIS]=Xsys.XperformanceFunctions(1).apply(XoutHPIS);
    [~, Vg2HPIS]=Xsys.XperformanceFunctions(2).apply(XoutHPIS);

    VmembersHPIS=false(XoutHPIS.Nsamples,1);
    VmembersHPIS(Vg2HPIS(Vg1HPIS<0)<0)=true;

    % Compute fraction of samples in the Failure region
    fHPIS=sum(VmembersHPIS)/XoutHPIS.Nsamples*100;

%% Summarize the results
disp('       Methods       | fraction of samples in the failure region')
disp('----------------------------------------------------------------------')

display(sprintf('%20s      %6.2f%% ','Monte Carlo',fMCS))
display(sprintf('%20s      %6.2f%% ','Importance Sampling',fMCS))
display(sprintf('%20s      %6.2f%% ','High Performance IS',fHPIS))

%% Plot Samples
% Plot a scatter plot
h1=figure; hold on; box on;
xlabel('RV1');ylabel('RV2');
% %display(XpfReferenceM)

X1=XoutMC.getValues('Sname','RV1');
X2=XoutMC.getValues('Sname','RV2');
scatter(gca(h1),X1,X2,'.b')


X1=XoutIS.getValues('Sname','RV1');
X2=XoutIS.getValues('Sname','RV2');
scatter(gca(h1),X1,X2,'+g')

X1=XoutHPIS.getValues('Sname','RV1');
X2=XoutHPIS.getValues('Sname','RV2');

scatter(gca(h1),X1,X2,'or')

legend('MCS','IS','HPIS')
