%% Tutorial Hybrid Model
%
% Reference: Section 5.2, Luo et al., 2009
%
% Overview:
% A cantilever beam subjected to a concentrated force P. 
% The beam has a length of L, a width of b and a height of h.
% The Young modulus of the material is E. The structure becomes
% unsafe when the tip displacement is greater than 0.15 in. 
%
% In this example, E and P are considered as normal random variables,
% whereas L, b and h are represented by uncertain-butbounded
% variables reflecting manufacturing errors.
%
clear
close all
clc;
%% Define the Input
import intervals.*
import common.inputs.* 
import reliability.*

% Define Random Variables Obj
E=opencossan.common.inputs.random.NormalRandomVariable('description','Young modulus', 'mean',1E7,'std',0.05);
P=opencossan.common.inputs.random.NormalRandomVariable('description','Force', 'mean',100,'std',0.1);
Xrvs=opencossan.common.inputs.random.RandomVariableSet('description','Xrvs of HybridModel','names',{'E', 'P'}, 'members',[E; P]);
%Define Intervals Obj
L=opencossan.intervals.Interval('description', 'Length of the beam','centre',30,...
    'lowerbound',28.5,'upperbound',31.5);
B=opencossan.intervals.Interval('description', 'Width of the beam','centre',0.8359,...
    'lowerbound',0.4179,'upperbound',1.2538);
H=opencossan.intervals.Interval('description', 'Height of the beam','centre',2.5093,...
    'lowerbound',1.2547,'upperbound',3.7640);
Xcs=opencossan.intervals.BoundedSet('description','Xcs of HybridModel','CSmembers',{'L' 'B' 'H'},...
    'CXint',[L,B,H],'Lconvex',true,'Mcorrelation',eye(3));
% Define input object
XinHM = Input('Sdescription','Input HybridModel','CSmembers',{'Xcs' 'Xrvs'},'CXmembers',{Xcs  Xrvs});
% Define a PerformanceFunction
Xpar=Parameter('Sdescription','parameter','value',0.15*2);
XinHM = XinHM.add('Xmember',Xpar,'Sname','Xpar');
XinHM = sample(XinHM,'Nsamples',10);
Xperfun=PerformanceFunction('OutputName','Vg','Demand','out1','Capacity','Xpar');
% Define evaluator
Xm=workers.Mio('Sdescription', 'Performance function', ...
                'Sscript','for j=1:length(Tinput),Toutput(j).out1=(4*Tinput(j).P*(Tinput(j).L)^3)/(Tinput(j).E*Tinput(j).B*(Tinput(j).H)^3); end', ...
                'Sformat','structure',...
                'Coutputnames',{'out1'},'Cinputnames',{'E','P','L','H','B'},...
				'Lfunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator
Xeval = workers.Evaluator('Xmio',Xm,'Sdescription','first HM evaluator');
% Define Model
XmdlHM=common.Model('Xinput',XinHM,'Xevaluator',Xeval);    
%% FORM analysis
% %% Construct the first HybridModel
Xhm=HybridModel({Xperfun},'Model',{XmdlHM});
Xsr     = optimization.StochasticRanking('Nmu',5,'Nlambda',20,'Vsigma',2*ones(5,1));
[Xdp, OptValues, Cnames]=Xhm.computeReliability('Xoptimizer', Xsr); 
display(Xdp.form)

%% SOLUTION according to Luo et al.
                                %E*         P*          L*      b*      h*      
                    % beta      %(10E6psi.) (lb.)       (in.)   (in.)   (in.)
% By MP             2.8853      9.194       123.926     31.5    0.823   2.390
% By iteration      2.8853      9.194       123.930     31.5    0.823   2.390

% Cobyla Cossan     9.9999E-3   10004654    99          31.03   0.631   2.115
% SR Cossan         4.4169e-05  1.00e+07    99.9999     29.390  0.8548  2.4678
