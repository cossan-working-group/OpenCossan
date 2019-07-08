%% Tutorial for the Global Sensitivity analysis using Random Balance Method
% The tutorial InfectionDynamicModel expains in very details how to use the
% Sensitivity Toolbox. For this reason the uses is invited to check the
% tutorial InfectionDynamicModel. 
%
% In this tutorial a very simplified model is considered.  
% 
% See Also:
% https://cossan.co.uk/wiki/index.php/computeIndices@GlobalSensitivityRandomBalanceDesign
% 
%
% $Copyright~1993-2017,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
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

% The method randomBalanceDesign is a very rubust method to compute the first
% order sensitivity indicies. 

%% Define GlobalSensitivityRandomBalanceDesign object
Xgs=GlobalSensitivityRandomBalanceDesign('Xmodel',Xmdl,'Nbootstrap',10,'Nsamples',50);
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
Xgs=GlobalSensitivityRandomBalanceDesign('nharmonics',10,'Nsamples',1000,'CinputNames',{'X1' 'X2'});
Xsm = Xgs.computeIndices('Xmodel',Xmdl2);

% compare with analytical solution
FirstAnalytical=[4/13;9/13];
FirstNumerical=Xsm.VsobolFirstIndices';
Tresults = table(FirstAnalytical,FirstNumerical,...
    'RowNames',Xgs.Cinputnames)
   