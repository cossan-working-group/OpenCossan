%% Problem Definition
RV1 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV2 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV3 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV4 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV5 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV6 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV7 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV8 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV9 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV10 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV11 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV12 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV13 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV14 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV15 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV16 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV17 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV18 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV19 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);
RV20 = RandomVariable('Sdistribution','exponential', 'mean',1,'std',1);

% Define the RVset
Xrvs = RandomVariableSet(...
    'Cmembers',{'RV1','RV2','RV3','RV4','RV5','RV6','RV7','RV8','RV9','RV10',...
                'RV11','RV12','RV13','RV14','RV15','RV16','RV17','RV18','RV19','RV20'},...
    'CXrv',{RV1 RV2 RV3 RV4 RV5 RV6 RV7 RV8 RV9 RV10 ...
            RV11 RV12 RV13 RV14 RV15 RV16 RV17 RV18 RV19 RV20}); %% Define the evaluator
% Construct a Mio object
Xm=Mio(         'Sdescription', 'Performance function', ...
                ...'Sscript','for j=1:length(Tinput), Toutput(j).out1=sqrt(Tinput(j).RV1^2+Tinput(j).RV2^2); end', ...
                'Spath',pwd,...
                'Sfile',[specs.Problem,'_mio'],...
                'Liostructure',true,...
                'Coutputnames',{'out'},...
                'Cinputnames',{'RV1','RV2','RV3','RV4','RV5','RV6','RV7','RV8','RV9','RV10',...
                'RV11','RV12','RV13','RV14','RV15','RV16','RV17','RV18','RV19','RV20'},...
				'Lfunction',false); % This flag specify if the .m file is a script or a function.

% Construct the Evaluator
Xeval = Evaluator('Xmio',Xm,'Sdescription','Evaluator xmio');
% Define Input object
Xin = Input('Sdescription','Blackbox reliability challenge');
Xthreshold = Parameter('value',0);
Xin = Xin.add('Xmember',Xrvs,'Sname','Xrvs');
Xin = Xin.add('Xmember',Xthreshold,'Sname','Xthreshold');
% Define a Model
Xmdl=Model('Xevaluator',Xeval,'Xinput',Xin);
% Define performance function
Xpf=PerformanceFunction('Scapacity','out','Sdemand','Xthreshold','Soutputname','Vg');
% Construct the model
Xpm=ProbabilisticModel('Xmodel',Xmdl,'XperformanceFunction',Xpf);

Xsimulator = constructSimulator(specs,Xpm);
%%
[XpF, Xoutput] = Xpm.computeFailureProbability(Xsimulator);

makePlots
