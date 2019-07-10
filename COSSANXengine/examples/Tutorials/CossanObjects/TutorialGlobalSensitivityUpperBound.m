%% Tutorial for the Sensitivity analysis
% The tutorial InfectionDynamicModel expains in very details how to use the
% Sensitivity Toolbox. For this reason the uses is invited to check the
% tutorial InfectionDynamicModel. 
%
% In this tutorial a very simplified model is considered.  
% 
% See Also: http://cossan.co.uk/wiki/index.php/Infection_Dynamic_Model
% 
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
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

% The method upperBounds allows to estimate the upper bounds of teh total
% sensitivity indices

Xgs=GlobalSensitivityUpperBound('Xmodel',Xmdl,'Nbootstrap',3,'Nsamples',4);
display(Xgs)
Xsm = Xgs.computeIndices;
display(Xsm)

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

Xgs=GlobalSensitivityUpperBound('Nbootstrap',100,'CinputNames',{'X1','X2'},'Nsamples',5);
% It is also possible to pass the model directly to the method
% computeIndices
Xsm = Xgs.computeIndices('Xmodel',Xmdl3);

% Show the results using the SensitivityMeasure object
display(Xsm)

Xgs2=GlobalSensitivityUpperBound('Nbootstrap',100,'CinputNames',{'X1','X2'},'Lfinitedifference',true);
Xsm2 = Xgs.computeIndices('Xmodel',Xmdl3);

% compare with analytical solution
TotalAnalytical=[18/19;10/19];
TotalNumerical=Xsm.VupperBounds';
Tresults = table(TotalAnalytical,TotalNumerical, ...
    'RowNames',Xgs.Cinputnames)

   