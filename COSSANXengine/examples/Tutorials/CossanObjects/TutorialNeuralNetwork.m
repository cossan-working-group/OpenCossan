%   Example on Neural Network 
%
%   A meta model for the displacement at the tip of a cantilever beam is created
%
% TODO: add comments 

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
Xin         = add(Xin,'Xmember',Xrvset,'Sname','Xrvset');
XL = Parameter('Sdescription','length of beam','value',1);
Xin = add(Xin,'Xmember',XL,'Sname','XL');
XI = Function('Sdescription','second moment of inertia of beam',...
    'Sexpression','<&Xh&>.^4/12');
Xin = add(Xin,'Xmember',XI,'Sname','XI');
XE  = Parameter('Sdescription','Young''s modulus of beam','value',2e11);
Xin = add(Xin,'Xmember',XE,'Sname','XE');

% this parameters are used in the test computation of pf
Xthreshold1 = Parameter('Sdescription','Define threshold','value',0.016);
Xin = add(Xin,'Xmember',Xthreshold1,'Sname','Xthreshold1');
Xthreshold2 = Parameter('Sdescription','Define threshold','value',0.017);
Xin = add(Xin,'Xmember',Xthreshold2,'Sname','Xthreshold2');

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


%%    Construction and Training of Neural network
%   In this step, the response surface model is created
Xnn = NeuralNetwork('Sdescription','Neural network of tip displacement of cantilever beam',...
    'Stype','HyperbolicTangent',...
    'Coutputnames',{'disp'},...  %response to be extracted from full model
    'Cinputnames',{'XP' 'Xh'},...
    'Xfullmodel',Xmod,...
    'Vnnodes',[2, 3, 1],...
    'Vnormminmax',[-0.8 0.8]);

Xmc=LatinHypercubeSampling('Nsamples',200);
Xnn = Xnn.calibrate('XSimulator',Xmc);

Xmc=MonteCarlo('Nsamples',40);
Xnn = Xnn.validate('XSimulator',Xmc);

%%  Apply trained Neural network meta-model
% the accuracy of the neural network is tested by computing the failure
% probability of the tip-loaded beam. This result is compared with the
% real model
Xpf = PerformanceFunction('Sdemand','disp','Scapacity','Xthreshold1','SoutputName','Vg');
Xpm_real = ProbabilisticModel('XModel',Xmod,'XPerformanceFunction',Xpf);
Xpm_metamodel = ProbabilisticModel('XModel',Xnn,'XPerformanceFunction',Xpf);

Xmc=MonteCarlo('Sdescription','Mio evaluation','Nsamples',1000,'Nbatches',1);
Xo_real = Xpm_real.computeFailureProbability(Xmc)
Xmc=MonteCarlo('Sdescription','NN evaluation','Nsamples',1000,'Nbatches',1);
Xo_metamodel = Xpm_metamodel.computeFailureProbability(Xmc)
