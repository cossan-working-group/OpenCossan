%% Tutorial Convex Model
%
clear;
close all
clc;
% Reference: Case b, Numerical Example 4, Jiang et al., 2011 (see pg 2540)
import intervals.*
import common.inputs.*
% Define the Input
%Define Intervals Obj
Xbv1=opencossan.intervals.Interval('Description', 'Xbv1','lowerbound',0,'upperbound',2);
Xbv2=opencossan.intervals.Interval('Description', 'Xbv2','lowerbound',0.5,'upperbound',1.5);
%Define ConvexSet Obj
Xcs1=opencossan.intervals.BoundedSet('Sdescription','First Convex Set','Cmembers',{'Xbv1', 'Xbv2'},'CXint',{Xbv1 Xbv2 }, 'Mcorrelation',[1,0;0 1],'Lconvex',true);

% Define input object
Xin = Input('Sdescription','Input ConvexModel','CSmembers',{'Xcs1'},'CXmembers',{Xcs1});
% Define a PerformanceFunction
Xpar= Parameter('Sdescription','parameter','value',1);
Xin = Xin.add('Xmember',Xpar,'Sname','Xpar');
Xin = sample(Xin,'Nsamples',1000);
Xperfun=reliability.PerformanceFunction('OutputName','Vg','Capacity','Xpar','Demand','out1');
% Define evaluator
Xm=workers.Mio('Sdescription', 'Performance function', ...
                'Sscript','for j=1:length(Tinput), Toutput(j).out1=Tinput(j).Xbv2-Tinput(j).Xbv1; end', ...
                'Sformat','structure',...
                'Coutputnames',{'out1'},'Cinputnames',{'Xbv1','Xbv2'},...
				'Lfunction',false); % This flag specify if the .m file is a script or a function.
% Construct the Evaluator
Xeval = workers.Evaluator('Xmio',Xm,'Sdescription','first CM evaluator');
% Define Model
Xmdl=common.Model('Xinput',Xin,'Xevaluator',Xeval);
% Construct the first ConvexModel
Xcm=reliability.ConvexModel('PerformanceFunction',{Xperfun},'Model',{Xmdl});
disp(Xcm)
% Analysis
% You can also introduce your own optimizer.
Xco = optimization.Cobyla('initialTrustRegion',1,'finalTrustRegion',0.001);  
% [beta, Vp] = computeReliability(Xcm,'Lgrad',false,'Xoptim',Xco)
Xga     = optimization.GeneticAlgorithms('NPopulationSize',10);
[beta,Vp] = computeReliability(Xcm,'Xoptimizer',Xco);
display(beta)
display(Vp)



%% Case 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Define the Input
%Define Intervals Obj
XbvPx = Interval('Sdescription','Px','lowerbound',45000,'upperbound',55000);
XbvPy = Interval('Sdescription','Py','lowerbound',22500,'upperbound',27500);
XbvL  = Interval('Sdescription', 'L','lowerbound',900,'upperbound',1100);
Xbvh  = Interval('Sdescription', 'h','lowerbound',180,'upperbound',220);
Xbvb  = Interval('Sdescription', 'b','lowerbound',90,'upperbound',110);
%Define ConvexSet Obj
corr_coef = 0.96;
Mcorrelation1=[1     corr_coef   corr_coef    0 0 ;
              corr_coef     1   corr_coef    0 0  ;
              corr_coef   corr_coef     1     0 0 ;
               0 0 0                          1     corr_coef;
               0 0 0                          corr_coef 1];
Xcs1=BoundedSet('Sdescription','First Convex Set','CSmembers',{'XbvL', 'Xbvh','Xbvb','XbvPx','XbvPy'},...
    'CXint',{XbvL Xbvh Xbvb XbvPx XbvPy}, 'Mcorrelation',Mcorrelation1);
% Mcorrelation2=[1     corr_coef     ;
%               corr_coef     1      ];
% Xcs2=ConvexSet('Sdescription','First Convex Set','Cmembers',{'XbvPx','XbvPy'},...
%     'Xbv',[XbvPx XbvPy], 'Mcorrelation',Mcorrelation2);
% Define input object
% Xin = Input('Sdescription','Input ConvexModel','CSmembers',{'Xcs1' 'Xcs2'},'CXmembers',{Xcs1,Xcs2});
Xin = Input('Sdescription','Input ConvexModel','CSmembers',{'Xcs1'},'CXmembers',{Xcs1});
% Define a PerformanceFunction
Xpar=Parameter('Sdescription','S','value',320);
Xin = Xin.add('Xmember',Xpar,'Sname','Xpar');
Xin = sample(Xin,'Nsamples',1);
Xperfun=reliability.PerformanceFunction('OutputName','Vg','Capacity','Xpar','Demand','out1');
% Define evaluator
Xm=workers.Mio('Sdescription', 'Performance function', ...
                'Sscript','for j=1:length(Tinput), Toutput(j).out1=(6*Tinput(j).XbvPx*Tinput(j).XbvL/(Tinput(j).Xbvb^2*Tinput(j).Xbvh))+(6*Tinput(j).XbvPy*Tinput(j).XbvL)/(Tinput(j).Xbvb*Tinput(j).Xbvh^2); end', ...
                'Sformat','structure',...
                'Coutputnames',{'out1'},'Cinputnames',{'XbvL', 'Xbvh','Xbvb','XbvPx','XbvPy'},...
				'Lfunction',false); 
% Construct the Evaluator
Xeval = workers.Evaluator('Xmio',Xm,'Sdescription','first CM evaluator');
% Define Model
Xmdl=common.Model('Xinput',Xin,'Xevaluator',Xeval);
% Construct the first ConvexModel
Xcm=reliability.ConvexModel('PerformanceFunction',{Xperfun},'Model',{Xmdl});
disp(Xcm)
% Analysis
% The HLRF method is apply to compute the minimaldistance 
% from the origin point to the failure region of the space 
[beta, Vp] = computeReliability(Xcm,'Xoptimizer',optimization.Cobyla);
display(beta)
display(Vp)