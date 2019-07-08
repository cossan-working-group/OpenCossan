 %% Tutorial for the ProbabilisticModel object 
%
% The tutorial shows how to define a ProbabilisticModel and to exaluate the 
% failure probability associeted to it.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@ProbabilisticModel
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli~and~Barbara-Goller$ 

% TODO: VERIFY OUTPUT


%% Overview
% The ProbabilisticModel requires a Model (i.e. Physical Model) and a
% PerformaceFunction
% The Model is defined used a matlab function (see Mio Tutorial)

%% Define the required object
% Construct a Mio object
Xm=Mio('Sdescription', 'Performance function', ...
                'Sscript','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
                'Liostructure',true,...
                'Coutputnames',{'out1'},'Cinputnames',{'RV1','RV2'},...
				'Lfunction',false); % This flag specify if the .m file is a script or a function. 
% Construct the Evaluator
Xeval1 = Evaluator('Xmio',Xm,'Sdescription','first Evaluator');

% In order to be able to construct our Model an Input object must be
% defined

%% Define an Input
% Define RVs
RV1=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);  %#ok<SNASGU>
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);   %#ok<SNASGU>
% Define the RVset
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'});  
% Define Xinput
Xin = Input('Sdescription','Input satellite_inp','CSmembers',{'Xrvs1'},'CXmembers',{Xrvs1});


%% Define a PerformanceFunction 
Xpar=Parameter('Sdescription','Define Capacity','value',1);
Xin = Xin.add('Xmember',Xpar,'Sname','Xpar');
Xin = sample(Xin,'Nsamples',10);

Xperfun=PerformanceFunction('Scapacity','Xpar','Sdemand','out1','Soutputname','Vg1');

%%  Construct the Model
Xmdl=Model('Cmembers',{'Xin','Xeval1'}); 

%% Now we can construct our first ProbabilisticModel
Xpm=ProbabilisticModel('Sdescription','my first Prob.Model',...
    'CXperformanceFunction',{Xperfun},'CXmodel',{Xmdl});
display(Xpm)


%% Analysis
% Deterministic Analysis
XsimOut=Xpm.deterministicAnalysis;
display(XsimOut)


% The ProbabilisticModel can also be constructed passing the object by
% references

Xpm=ProbabilisticModel('Sdescription','my first Prob.Model','Xmodel',Xmdl,'XperformanceFunction',Xperfun);
display(Xpm)

% Let now evaluate the ProbabilisticModel

Xout=Xpm.apply(Xin); 

% The SimulationData will contains 10 model evaluation and 10 performance
% function evaluation

% If you want compute the Failure probability, the method
% computeFailureProbability must be applied to a Simulation object
Xmc=MonteCarlo('Nsamples',10000);
Xpf=Xpm.computeFailureProbability(Xmc); 
% see turorial of Failure Probability 
display(Xpf)



