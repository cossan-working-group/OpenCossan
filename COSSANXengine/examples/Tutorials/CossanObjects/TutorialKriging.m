%**************************************************************************
% In this tutorial it is shown how to construct a Kriging object and
% how to use it for approximating the response computed by a FE-analysis
%
% Prepared by IM
%
%  Copyright 1993-2012, 
%
% See Also: 
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@Kriging

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%%    Data on model
%   Here, 4 input parameters (namely load, length of the beam, second
%   moment of inertia of cross section of beam and Young's modulus) of the
%   cantilever beam model are defined
Xin = Input('Sdescription','input parameters of cantilever beam model');
XP = RandomVariable('Sdescription','load at tip of beam',...
    'Sdistribution','uniform','par1',0.5e6,'par2',1.5e6);
Xh = RandomVariable('Sdescription','height of cross section of beam',...
    'Sdistribution','uniform','par1',0.2,'par2',0.3);
Xrvset      = RandomVariableSet('Cmembers',{'Xh','XP'});
Xin         = Xin.add('Xmember',Xrvset,'Sname','Xrvset');

XL = Parameter('Sdescription','length of beam','value',1);
Xin = Xin.add('Xmember',XL,'Sname','XL');
XI = Function('Sdescription','second moment of inertia of beam',...
    'Sexpression','<&Xh&>.^4/12');
Xin = Xin.add('Xmember',XI,'Sname','XI');
XE  = Parameter('Sdescription','Young''s modulus of beam','value',2e11);
Xin = Xin.add('Xmember',XE,'Sname','XE');

% this parameters are used in the test computation of pf
Xthreshold1 = Parameter('Sdescription','Define threshold','value',0.016);
Xin = Xin.add('Xmember',Xthreshold1,'Sname','Xthreshold1');
Xthreshold2 = Parameter('Sdescription','Define threshold','value',0.017);
Xin = Xin.add('Xmember',Xthreshold2,'Sname','Xthreshold2');

%%    Evaluator
%   An evaluator based on a mio script is defined. This evaluator
%   calculates the displacement at the tip of a cantilever beam, i.e.
%   displacement = load * length^3 / (3 * Young's modulus * Inertia)
% 
%2.1. Definition of MIO object and construction of evaluator
Xmio = Mio('Sdescription','displacement at tip of cantilever beam', ...
        'SScript','for i=1:length(Tinput),    Toutput(i).disp  = Tinput(i).XP*Tinput(1).XL^3/(3*Tinput(1).XE*Tinput(i).XI);end',...
        'Cinputnames',{'XP','XL','XE','XI'},...
        'Coutputnames',{'disp'},...
        'Liostructure',true,...
        'Lfunction',false);
%2.2. Add MIO to evaluator
Xev = Evaluator('Sdescription','displacement at tip of cantilever beam','XMio',Xmio);
%2.3. Add Evaluator to a model
Xmod = Model('XEvaluator',Xev,'Xinput',Xin);


%%    Construction and Training of Kriging
%   In this step, the response surface model is created
Xkriging = KrigingModel('Sdescription','Kriging of tip displacement of cantilever beam',...
    'SregressionType','regpoly0',...
    'Coutputnames',{'disp'},...  %response to be extracted from full model
    'Cinputnames',{'XP' 'Xh'},...
    'Xfullmodel',Xmod,...
    'Vcorrelationparameter',[0.1 0.1]);

Xmc=LatinHypercubeSampling('Nsamples',200);
Xkriging = Xkriging.calibrate('XSimulator',Xmc);

Xmc=MonteCarlo('Nsamples',40);
Xkriging = Xkriging.validate('XSimulator',Xmc);

display(Xkriging)
%%  Apply trained Kriging meta-model
% the accuracy of the kriging is tested by computing the failure
% probability of the tip-loaded beam. This result is compared with the
% real model
Xpf = PerformanceFunction('Sdemand','disp','Scapacity','Xthreshold1','SoutputName','Vg');
Xpm_real = ProbabilisticModel('XModel',Xmod,'XPerformanceFunction',Xpf);
Xpm_metamodel = ProbabilisticModel('XModel',Xkriging,'XPerformanceFunction',Xpf);

Xmc=MonteCarlo('Sdescription','Mio evaluation','Nsamples',1000,'Nbatches',1);
Xo_real = Xpm_real.computeFailureProbability(Xmc)
Xmc=MonteCarlo('Sdescription','Kriging evaluation','Nsamples',1000,'Nbatches',1);
Xo_metamodel = Xpm_metamodel.computeFailureProbability(Xmc)

%% Apply Kriging
MXX1 = repmat(linspace(0.2,0.3,201)',1,201);
MXX2 = repmat(linspace(0.5e6,1.5e6,201),201,1);
Vx1=MXX1(:); Vx2 = MXX2(:);
Minput = [Vx1,Vx2];
Xs = Samples('Xrvset',Xrvset,'MsamplesPhysicalSpace',Minput);
Xin = Xin.add(Xs);
%%
Xoutreal = Xmio.run(Xin);
Xoutkr = Xkriging.apply(Xin);

f1 = figure(1);
mesh(MXX1,MXX2,reshape(Xoutreal.getValues('Sname','disp'),201,201));
f2 =  figure(2);
mesh(MXX1,MXX2,reshape(Xoutkr.getValues('Sname','disp'),201,201));