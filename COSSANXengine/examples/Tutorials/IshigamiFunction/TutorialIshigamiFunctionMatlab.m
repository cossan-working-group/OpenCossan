X1   = RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
X2   = RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
X3   = RandomVariable('Sdistribution','uniform','lowerbound',-pi,'upperbound',pi);
Xrvset = RandomVariableSet('Cmembers',{'X1','X2','X3'},'CXrandomvariables',{X1,X2,X3});
Xin    = Input('XrandomVariableSet',Xrvset);
Xm2 = Mio('Sscript','Moutput=(sin(Minput(:,1)) + 7*sin(Minput(:,2)).^2 + 0.05*(Minput(:,3)).^4.*sin(Minput(:,1)));', ...
         'Coutputnames',{'Y'},...
         'Cinputnames',{'X1' 'X2' 'X3'},...
         'Liostructure',false,...
         'Liomatrix',true,...
	     'Lfunction',false);  
Xev2    = Evaluator('Xmio',Xm2);
Xmdl2   = Model('Xinput',Xin,'Xevaluator',Xev2);

Xmc=MonteCarlo('Nsamples',10000);
Xgs=GlobalSensitivitySobol('Xmodel',Xmdl2,'Nbootstrap',100,'Xsimulator',Xmc,'Smethod','Jansen1999');
Xsm = Xgs.computeIndices;


Xrbd = GlobalSensitivityRandomBalanceDesign('Xmodel',Xmdl2,'Nsamples',10000);
Xsm2 = Xrbd.computeIndices;

% compare with analytical solution
S1_analytic = (.5+.05*pi^4/5+.05^2*pi^8/50)/(.5+7^2/8+.05*pi^4/5+.05^2*pi^8/18);
S2_analytic = (7^2/8)/(.5+7^2/8+.05*pi^4/5+.05^2*pi^8/18);
S3_analytic = 0;
S13_analytic= (.5+7^2/8+.05*pi^4/5+.05^2*pi^8/18 -7^2/8 -.5 -.05*pi^4/5 -.05^2*pi^8/50 ) /(.5+7^2/8+.05*pi^4/5+.05^2*pi^8/18) ;

FirstAnalytical=[S1_analytic;S2_analytic;S3_analytic];
FirstNumerical=Xsm(1).VsobolFirstIndices';
FirstRBD=Xsm2.VsobolFirstIndices';
TotalAnalytical=[S1_analytic+S13_analytic;S2_analytic;S13_analytic];
TotalNumerical=Xsm(1).VtotalIndices';
Tresults = table(FirstAnalytical,FirstNumerical,FirstRBD,TotalAnalytical,TotalNumerical, ...
    'RowNames',Xgs.Cinputnames)
