clear
close all
clc;

%%OpenCossan.resetRandomNumberGenerator(75329517);

%% Define the required object
% Construct a Mio object
casestudy = input('Enter a case-study number between 1 and 6:');

switch casestudy
    case 1
        Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','Moutput=-Minput(:,1).*Minput(:,2);', ...
...                'Liostructure',false,...
...                'Liomatrix',true,...
                'OutputNames',{'out1'},'InputNames',{'RV1','RV2'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
                % Construct the Evaluator
                Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');
                % In order to be able to construct our Model an Input object must be defined

        %% Define an Input
        % Define RVs
        RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',78064.4,'std',11709.7);  %#ok<SNASGU>
        RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0.0104,'std',0.00156);   %#ok<SNASGU>
        % Define the RVset
        Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);  
        % Define Xinput
        Xin = opencossan.common.inputs.Input('description','Input satellite_inp','membersnames',{'Xrvs1'},'members',{Xrvs1});
        %% Define a PerformanceFunction 
        Xpar=opencossan.common.inputs.Parameter('description','Define Capacity','value',-146.14);
        Xin = add(Xin,'member',Xpar,'name','Xpar');
        % Xin = sample(Xin,'Nsamples',10);
        Xperfun=opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xpar','Demand','out1');
        exactpf=1.46e-07;
    case 2
        Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','Moutput=-Minput(:,2)+(Minput(:,1)^2)*0.1-(Minput(:,1)^3)*0.06;', ...
...                'Liostructure',false,...
...                'Liomatrix',true,...
                'OutputNames',{'out1'},'InputNames',{'RV1','RV2'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
                % Construct the Evaluator
                Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');
                % In order to be able to construct our Model an Input object must be defined

        %% Define an Input
        % Define RVs
        RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);  %#ok<SNASGU>
        RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);   %#ok<SNASGU>
        % Define the RVset
        Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);  
        % Define Xinput
        Xin = opencossan.common.inputs.Input('description','Input satellite_inp','membersnames',{'Xrvs1'},'members',{Xrvs1});
        %% Define a PerformanceFunction 
        Xpar=opencossan.common.inputs.Parameter('description','Define Capacity','value',2);
        Xin = Xin.add('member',Xpar,'name','Xpar');
        % Xin = sample(Xin,'Nsamples',10);
        Xperfun=opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xpar','Demand','out1');
        exactpf=3.47e-02;
    case 3
        Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','Moutput=-0.1*(Minput(:,1)-Minput(:,2))^2+(Minput(:,1)+Minput(:,2))/sqrt(2);', ...
...                'Liostructure',false,...
...                'Liomatrix',true,...
                'OutputNames',{'out1'},'InputNames',{'RV1','RV2'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
                % Construct the Evaluator
                Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');
                % In order to be able to construct our Model an Input object must be defined

        %% Define an Input
        % Define RVs
        RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);  %#ok<SNASGU>
        RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);   %#ok<SNASGU>
        % Define the RVset
        Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);  
        % Define Xinput
        Xin = opencossan.common.inputs.Input('description','Input satellite_inp','membersnames',{'Xrvs1'},'members',{Xrvs1});
        %% Define a PerformanceFunction 
        Xpar=opencossan.common.inputs.Parameter('description','Define Capacity','value',2.5);
        Xin = Xin.add('member',Xpar,'name','Xpar');
        % Xin = sample(Xin,'Nsamples',10);
        Xperfun=opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xpar','Demand','out1');
        exactpf=4.16e-03;
    case 4
        Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','Moutput=0.5*(Minput(:,1)-Minput(:,2))^2+(Minput(:,1)+Minput(:,2))/sqrt(2);', ...
...                'Liostructure',false,...
...                'Liomatrix',true,...
                'OutputNames',{'out1'},'InputNames',{'RV1','RV2'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
                % Construct the Evaluator
                Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');
                % In order to be able to construct our Model an Input object must be defined

        %% Define an Input
        % Define RVs
        RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);  %#ok<SNASGU>
        RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);   %#ok<SNASGU>
        % Define the RVset
        Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);  
        % Define Xinput
        Xin = opencossan.common.inputs.Input('description','Input satellite_inp','membersnames',{'Xrvs1'},'members',{Xrvs1});
        %% Define a PerformanceFunction 
        Xpar=opencossan.common.inputs.Parameter('description','Define Capacity','value',3);
        Xin = Xin.add('member',Xpar,'name','Xpar');
        % Xin = sample(Xin,'Nsamples',10);
        Xperfun=opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xpar','Demand','out1');
        exactpf=1.05e-01; 
        case 5
            Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','Moutput=0.2357*(Minput(:,1)-Minput(:,2))+(Minput(:,1)+0.00463*Minput(:,2)-20)^4;', ...
...                'Liostructure',false,...
...                'Liomatrix',true,...
                'OutputNames',{'out1'},'InputNames',{'RV1','RV2'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
                % Construct the Evaluator
                Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');
                % In order to be able to construct our Model an Input object must be defined

        %% Define an Input
        % Define RVs
        RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',10,'std',3);  %#ok<SNASGU>
        RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',10,'std',3);   %#ok<SNASGU>
        % Define the RVset
        Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);  
        % Define Xinput
        Xin = opencossan.common.inputs.Input('description','Input satellite_inp','membersnames',{'Xrvs1'},'members',{Xrvs1});
        %% Define a PerformanceFunction 
        Xpar=opencossan.common.inputs.Parameter('description','Define Capacity','value',3);
        Xin = Xin.add('member',Xpar,'name','Xpar');
        % Xin = sample(Xin,'Nsamples',10);
        Xperfun=opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xpar','Demand','out1');
        exactpf=2.86e-03;
        case 6
                Xm=opencossan.workers.Mio('description', 'Performance function', ...
                'Script','Moutput=Minput(:,2)-(4*Minput(:,1))^4;', ...
...                'Liostructure',false,...
...                'Liomatrix',true,...
                'OutputNames',{'out1'},'InputNames',{'RV1','RV2'},...
				'IsFunction',false); % This flag specify if the .m file is a script or a function. 
                % Construct the Evaluator
                Xeval1 = opencossan.workers.Evaluator('Xmio',Xm,'Sdescription','first Evaluator');
                % In order to be able to construct our Model an Input object must be defined

        %% Define an Input
        % Define RVs
        RV1=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);  %#ok<SNASGU>
        RV2=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);   %#ok<SNASGU>
        % Define the RVset
        Xrvs1=opencossan.common.inputs.random.RandomVariableSet('names',{'RV1', 'RV2'},'members',[RV1;RV2]);  
        % Define Xinput
        Xin = opencossan.common.inputs.Input('description','Input satellite_inp','membersnames',{'Xrvs1'},'members',{Xrvs1});
        %% Define a PerformanceFunction 
        Xpar=opencossan.common.inputs.Parameter('description','Define Capacity','value',3);
        Xin = Xin.add('member',Xpar,'name','Xpar');
        % Xin = sample(Xin,'Nsamples',10);
        Xperfun=opencossan.reliability.PerformanceFunction('OutputName','Vg1','Capacity','Xpar','Demand','out1');
        exactpf=1.8e-04; 
    otherwise
        disp('other value');
end



%%  Construct the Model
Xmdl=opencossan.common.Model('Cmembers',{'Xin','Xeval1'}); 

%% Now we can construct our first ProbabilisticModel
Xpm=ProbabilisticModel('Sdescription','my first Prob.Model',...
    'CXperformanceFunction',{Xperfun},'CXmodel',{Xmdl});
display(Xpm)
%%
XRBIS = RadialBasedImportanceSampling('MVdirection',randn(5,2));
Xpf = XRBIS.pf(Xpm);
display(Xpf)
disp('Exact Pf value')
disp(exactpf)
%% validate RBIS
 % Xmc = MonteCarlo('Nsamples',100000);
 % Xpf_MC = Xmc.pf(Xpm);
