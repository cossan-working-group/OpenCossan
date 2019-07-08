%% Tutorial for the Sensitivity analysis
% The tutorial InfectionDynamicModel expains in very details how to use the
% Sensitivity Toolbox. For this reason the uses is invited to check the
% tutorial InfectionDynamicModel. 
%
% In this tutorial a very simplified model is considered. The model is
% simply: $y=x_1^2+2x_2-x_3$
%
% A more realistic example is provided in the TutorialInfectionDynamicModel. 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Infection_Dynamic_Model
% 
%
% $Copyright~1993-2017,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$ 


%% Problem setup
% In this examples we consider only 3 uniform random variables
Xrv1   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrv2   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrv3   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrv4   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xpar   = Parameter('value',0);
Xrvset = RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3' 'Xrv4'},'CXrandomvariables',{Xrv1,Xrv2,Xrv3,Xrv4});
Xin    = Input('XrandomVariableSet',Xrvset,'Xparameter',Xpar);

% The model is defined using a Mio object
Xm = Mio('Sscript','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xrv1^2+2*Tinput(j).Xrv2-Tinput(j).Xrv3; end', ...
         'Coutputnames',{'out1'},...
         'Cinputnames',{'Xrv1' 'Xrv2' 'Xrv3'},...
         'Liostructure',true,...
	     'Lfunction',false); 
     
Xev    = Evaluator('Xmio',Xm);
Xmdl   = Model('Xinput',Xin,'Xevaluator',Xev);

Xperfun = PerformanceFunction('Sdemand','Xpar','Scapacity','Xrv4','Soutputname','vg');
Xpm = ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xperfun);

% Here we go!!!
%% Local Sensitivity Analysis
% To start with, we compute the local sensitivity analysis based on Finite
% Differnce Methos
XlsMC = LocalSensitivityMonteCarlo('Xtarget',Xmdl);
XgMC = XlsMC.computeGradientStandardNormalSpace;
display(XgMC)

XlsFD = LocalSensitivityFiniteDifference('Xtarget',Xmdl);
XgFD = XlsFD.computeGradient;
display(XgFD)

% Compute the Local Sensitivity for the probabilistic model
XlsFD2 = LocalSensitivityFiniteDifference('Xtarget',Xpm,'Lperformancefunction',true);
XgFD2 = XlsFD2.computeGradient;
display(XgFD2)

% The only important parameter is Xrv4 
% Xrv1:  0.000e+00 (0.000e+00)
% Xrv2:  0.000e+00 (0.000e+00)
% Xrv3:  0.000e+00 (0.000e+00)
% Xrv4:  1.000e+00 (0.000e+00)


% Plese notice that the Gradient method based on MonteCarlo simulation produces
% an approximate value of the gradient. It should be used only in high space
% (i.e. number of input > 50) since it allows to reduce significantly the
% conputational efforts**

% The localFiniteDifference and the localMonteCarlo methods returns a
% LocalSensitivityMeasure and not a Gradient object. 

Xls = XlsFD.computeIndices;
display(Xls)

XlsFD1 = LocalSensitivityFiniteDifference('Xtarget',Xmdl,....
    'VreferencePoint',[0.5 0.4 0.2 0.1]);
Xls1=XlsFD1.computeIndices;
display(Xls1)
       
%% Global Sensitivity Analysis
% The global sensitivity analysis is independent of the reference points.
% There are different methods to estimate the global sensitivity analysis.

% The method randomBalanceDesign is a very rubust method to compute the first
% order sensitivity indicies. 
XgsRBD = GlobalSensitivityRandomBalanceDesign('Xmodel',Xmdl,'Nbootstrap',100,'Nsamples',1000);
Xsm = XgsRBD.computeIndices;
display(Xsm)
   
% To compute the Total indices the Saltelli's method must be used. This method
% requires a Simulations object.

Xmc=MonteCarlo('Nsamples',2000);
XgsS = GlobalSensitivitySobol('Xmodel',Xmdl,'Xsimulation',Xmc,'Nbootstrap',100);
Xsm = XgsS.computeIndices;
display(Xsm)

% The method upperBounds allows to estimate the upper bounds of the total
% sensitivity indices
XgsUB = GlobalSensitivityUpperBound('Xmodel',Xmdl,'Nbootstrap',3,'Nsamples',50);
Xsm = XgsUB.computeIndices;
display(Xsm)

   
%% Saltelli Exercise 3 pag 177 
% In this examples we consider only 2 uniform random variables
X1   = RandomVariable('Sdistribution','normal','mean',1,'std',3);
X2   = RandomVariable('Sdistribution','normal','mean',2,'std',2);
Xrvset = RandomVariableSet('Cmembers',{'X1','X2'},'CXrandomvariables',{X1,X2});
Xin    = Input('XrandomVariableSet',Xrvset);

% The model is defined using a Mio object
Xm = Mio('Sscript','Moutput=Minput(:,1).*Minput(:,2);', ...
         'Coutputnames',{'Y'},...
         'Cinputnames',{'X1' 'X2'},...
         'Liostructure',false,...
	     'Lfunction',false,'Liomatrix',true); 
     
Xev    = Evaluator('Xmio',Xm);
Xmdl   = Model('Xinput',Xin,'Xevaluator',Xev);

Xmc=MonteCarlo('Nsamples',1000);
XgsS = GlobalSensitivitySobol('Xmodel',Xmdl,'Xsimulation',Xmc);
Xsm = XgsS.computeIndices;

% Show the results
display(Xsm)


%% Multiple outputs
% In this example shows how to perform sensitivity analysis of selected inputs and outputs
X1   = RandomVariable('Sdistribution','normal','mean',1,'std',3);
X2   = RandomVariable('Sdistribution','normal','mean',2,'std',2);
Xrvset = RandomVariableSet('Cmembers',{'X1','X2'},'CXrandomvariables',{X1,X2});
Xin    = Input('XrandomVariableSet',Xrvset);

% The model is defined using a Mio object
Xm = Mio('Sscript','Moutput(:,1)=Minput(:,1).*Minput(:,2);Moutput(:,2)=2*Minput(:,1);', ...
         'Coutputnames',{'Y1' 'Y2'},...
         'Cinputnames',{'X1' 'X2'},...
         'Liostructure',false,...
	     'Lfunction',false,'Liomatrix',true); 
     
Xev    = Evaluator('Xmio',Xm);
Xmdl   = Model('Xinput',Xin,'Xevaluator',Xev);

XgsS = GlobalSensitivitySobol('Xmodel',Xmdl,'Xsimulation',Xmc,'Coutputnames',{'Y1'},'Cinputnames',{'X1'});
Xsm = XgsS.computeIndices;

% Show the results
display(Xsm)


%% Multiple outputs with Dataseries
StutorialPath = fileparts(which('TutorialSensitivity.m'));

RV1   = RandomVariable('Sdistribution','normal','mean',1,'std',3);
RV2   = RandomVariable('Sdistribution','normal','mean',2,'std',2);
Xrvset = RandomVariableSet('Cmembers',{'RV1','RV2'},'CXrandomvariables',{RV1,RV2});
Xin    = Input('XrandomVariableSet',Xrvset);

% The model is defined using a Mio object
Xm  = Mio('Sdescription', 'TestFunction', ...
                'Spath',fullfile(StutorialPath,'Files4Mio'), ...
                'Sfile','ExampleMioStructureDataseries.m', ...
                'Coutputnames',{'Xds1' 'Out2'},... % This field is mandatory
                'Cinputnames',{'RV1' 'RV2'},...    % This field is mandatory
                'Liostructure',true,...     % This flag specify the type of I/O
                'Liomatrix',false, ...  % This flag specify the type of I/O
				'Lfunction',false); % This flag specify if the .m file is a script or a function. 
     
Xev    = Evaluator('Xmio',Xm);
Xmdl   = Model('Xinput',Xin,'Xevaluator',Xev);
Xout=Xmdl.deterministicAnalysis

Xmc=MonteCarlo('Nsamples',1000);
XgsS = GlobalSensitivitySobol('Xmodel',Xmdl,'Xsimulation',Xmc);
% A warning message is returned because it is not possible to compute the
% sensitivity analysis of model returning Dataseries
Xsm = XgsS.computeIndices;

% However it is still possible to perform sensitivity analysis on
% Input/Output that are not Dataseries.
XgsS = GlobalSensitivitySobol('Xmodel',Xmdl,'Xsimulation',Xmc,'Coutputnames',{'Out2'});
Xsm = XgsS.computeIndices;