%% Tutorial for the Global Sensitivity analysis using Sobol' indices
% The tutorial expains the basic usage of the object GlobalSensitivitySobol
%
% Saltelli Exercises 2 and 3 pags 176-177 are used
%
% Saltelli, A.; Ratto, M.; Andres, T.; Campolongo, F.; Cariboni, J.;
% Gatelli, D.; Salsana, M. & Tarantola, S. Global sensitivity analysis -
% The primer Wiley, 2008  
% 
% See Also: https://cossan.co.uk/wiki/index.php/Infection_Dynamic_Model
% 
%
% $Copyright~1993-2017,~COSSAN~Working~Group$
% $Author: Edoardo-Patelli$ 


%% Problem setup
% In this examples we consider only 3 uniform random variables
Xrv1   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrv2   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrv3   = RandomVariable('Sdistribution','uniform','lowerbound',-1,'upperbound',1);
Xrvset = RandomVariableSet('Cmembers',{'Xrv1','Xrv2','Xrv3'},'CXrandomvariables',{Xrv1,Xrv2,Xrv3});
Xin    = Input('XrandomVariableSet',Xrvset);

% The model is defined using a Mio object
Xm = Mio('Sscript','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xrv1^2+2*Tinput(j).Xrv2-Tinput(j).Xrv3; end', ...
         'Coutputnames',{'out1'},...
         'Cinputnames',{'Xrv1' 'Xrv2' 'Xrv3'},...
         'Liostructure',true,...
	     'Lfunction',false); 
     
Xev    = Evaluator('Xmio',Xm);
Xmdl   = Model('Xinput',Xin,'Xevaluator',Xev);


%% Global Sensitivity Analysis
% The global sensitivity analysis is independent of the reference points.
% There are different methods to estimate the global sensitivity analysis.
   
% To compute the Total indices the Saltelli's method must be used. This method
% requires a Simulations object.
Xmc=MonteCarlo('Nsamples',1000);

Xgs=GlobalSensitivitySobol('Xmodel',Xmdl,'Nbootstrap',100,'Xsimulator',Xmc);
display(Xgs)
Xsm = Xgs.computeIndices;
display(Xsm)

%% Saltelli Exercise 2 pag 176
% Pure addictive model with no interaction effect
X1   = RandomVariable('Sdistribution','normal','mean',1,'std',2);
X2   = RandomVariable('Sdistribution','normal','mean',2,'std',3);
Xrvset = RandomVariableSet('Cmembers',{'X1','X2'},'CXrandomvariables',{X1,X2});
Xin    = Input('XrandomVariableSet',Xrvset);
Xm2 = Mio('Sscript','Moutput=Minput(:,1) + Minput(:,2);', ...
         'Coutputnames',{'Y'},...
         'Cinputnames',{'X1' 'X2'},...
         'Liostructure',false,...
         'Liomatrix',true,...
	     'Lfunction',false);  
Xev2    = Evaluator('Xmio',Xm2);
Xmdl2   = Model('Xinput',Xin,'Xevaluator',Xev2);

Xmc=MonteCarlo('Nsamples',10000);
Xgs=GlobalSensitivitySobol('Xmodel',Xmdl2,'Nbootstrap',100,'Xsimulator',Xmc,'Smethod','Saltelli2008');
Xsm = Xgs.computeIndices;

% compare with analytical solution
FirstAnalytical=[4/13;9/13];
FirstNumerical=Xsm.VsobolFirstIndices';
TotalAnalytical=[4/13;9/13];
TotalNumerical=Xsm.VtotalIndices';
Tresults = table(FirstAnalytical,FirstNumerical,TotalAnalytical,TotalNumerical, ...
    'RowNames',Xgs.Cinputnames)

%% Saltelli Exercise 3 pag 177 
% In this examples we consider only 2 normal distributed random variables
X1   = RandomVariable('Sdistribution','normal','mean',1,'std',3);
X2   = RandomVariable('Sdistribution','normal','mean',2,'std',2);
Xrvset = RandomVariableSet('Cmembers',{'X1','X2'},'CXrandomvariables',{X1,X2});
Xin    = Input('XrandomVariableSet',Xrvset);
display(Xsm)
% The model is defined using a Mio object
Xm3 = Mio('Sscript','Moutput=Minput(:,1).*Minput(:,2);', ...
         'Coutputnames',{'Y'},...
         'Cinputnames',{'X1' 'X2'},...
         'Liostructure',false,...
         'Liomatrix',true,...
	     'Lfunction',false); 
     
Xev3    = Evaluator('Xmio',Xm3);
Xmdl3   = Model('Xinput',Xin,'Xevaluator',Xev3);


Xmc=MonteCarlo('Nsamples',10000);
Xgs=GlobalSensitivitySobol('Nbootstrap',100,'Xsimulator',Xmc);
% It is also possible to pass the model directly to the method
% computeIndices
Xsm = Xgs.computeIndices('Xmodel',Xmdl3);

% Show the results using the SensitivityMeasure object
display(Xsm)

% compare with analytical solution
FirstAnalytical=[9/19;1/19];
FirstNumerical=Xsm.VsobolFirstIndices';
TotalAnalytical=[18/19;10/19];
TotalNumerical=Xsm.VtotalIndices';
Tresults = table(FirstAnalytical,FirstNumerical,TotalAnalytical,TotalNumerical, ...
    'RowNames',Xmdl3.Cinputnames)


%% Another example with discontinuos output.  
% In this examples we consider only 2 normal distributed random variables
X1   = RandomVariable('Sdistribution','normal','mean',1,'std',3);
X2   = RandomVariable('Sdistribution','normal','mean',2,'std',2);
X3   = RandomVariable('Sdistribution','normal','mean',0,'std',1);
Xrvset = RandomVariableSet('Cmembers',{'X1','X2','X3'},'CXrandomvariables',{X1,X2,X3});
Xin    = Input('XrandomVariableSet',Xrvset);
% The model is defined using a Mio object
Xm4 = Mio('Sscript','Moutput=Minput(:,1).*Minput(:,2)+max(Minput(:,3),Minput(:,1));', ...
         'Coutputnames',{'Y'},...
         'Cinputnames',{'X1' 'X2' 'X3'},...
         'Liostructure',false,...
         'Liomatrix',true,...
	     'Lfunction',false); 
     
Xev4    = Evaluator('Xmio',Xm4);
Xmdl4   = Model('Xinput',Xin,'Xevaluator',Xev4);

Xmc=MonteCarlo('Nsamples',1000);
Xgs=GlobalSensitivitySobol('Nbootstrap',100,'Xsimulator',Xmc);
% It is also possible to pass the model directly to the method
% computeIndices
Xsm = Xgs.computeIndices('Xmodel',Xmdl4);

%% Select different methods for computing Sobol' indices
Xgs=GlobalSensitivitySobol('Nbootstrap',100,'Xsimulator',Xmc,'Smethod','Jansen1999');
Xsm2 = Xgs.computeIndices('Xmodel',Xmdl4);


%% Sensitivity of a model with multiple outputs
X1   = RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
X2   = RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
X3   = RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
Xrvset = RandomVariableSet('Cmembers',{'X1','X2','X3'},'CXrandomvariables',{X1,X2,X3});
Xin    = Input('XrandomVariableSet',Xrvset);
Xm5 = Mio('Sscript','Moutput=Minput(:,2) + Minput(:,3);Moutput(:,2)=Minput(:,1).*Minput(:,2);', ...
         'Coutputnames',{'Y1','Y2'},...
         'Cinputnames',{'X1' 'X2' 'X3'},...
         'Liostructure',false,...
         'Liomatrix',true,...
	     'Lfunction',false);  
Xev5    = Evaluator('Xmio',Xm5);
Xmdl5   = Model('Xinput',Xin,'Xevaluator',Xev5);

Xmc=MonteCarlo('Nsamples',10000);
Xgs=GlobalSensitivitySobol('Xmodel',Xmdl5,'Nbootstrap',100,'Xsimulator',Xmc,'Smethod','Saltelli2010');
Xsm = Xgs.computeIndices;

% compare with analytical solution
% output Y1 
FirstAnalytical=[0;0.5;0.5];
FirstNumerical=Xsm(1).VsobolFirstIndices';
TotalAnalytical=[0;0.5;0.5];
TotalNumerical=Xsm(1).VtotalIndices';
Tresults = table(FirstAnalytical,FirstNumerical,TotalAnalytical,TotalNumerical, ...
    'RowNames',Xgs.Cinputnames)
% output Y2 
FirstAnalytical=[0;0;0];
FirstNumerical=Xsm(2).VsobolFirstIndices';
TotalAnalytical=[1;1;0];
TotalNumerical=Xsm(2).VtotalIndices';
Tresults = table(FirstAnalytical,FirstNumerical,TotalAnalytical,TotalNumerical, ...
    'RowNames',Xgs.Cinputnames)
