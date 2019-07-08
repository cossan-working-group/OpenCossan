% Tutorial for the JobManager Object
% This tutorial shows how to create and use a JobManager object

% This tutorial shows only the most basic commands and features of
% JobMangarer.

Xjm = JobManagerInterface('Stype','GridEngine');

    Xg = JobManager('Sdescription','test #1',...
        'Squeue','pizzas64.q',...
        'Xjobmanagerinterface',Xjm);
    
        Xg = JobManager('Sdescription','test #1',...
        'Squeue','pizzas64.q',...
        'Xjobmanagerinterface',Xjm,...
        'SpreExeCmd','echo preexecmd ', ...
        'SpostExeCmd','echo postexecmd ');
    [~,SuserName] = system('whoami'); SuserName=SuserName(1:end-1);
    CSjobID(1)=Xg.submitJob;
      

    %% Run a model
    
    
    RV1=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);  %#ok<SNASGU>
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);  %#ok<SNASGU>
% Define the RVset
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'}); 
% Define Xinput
Xin = Input('Sdescription','Input satellite_inp');
Xin = add(Xin,Xrvs1);


Xm=Mio( 'Sdescription', 'This is our Model', ...
    'Sscript','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2; end', ...
    'Liostructure',true,...
    'Coutputnames',{'out'},...
    'Cinputnames',{'RV1','RV2'},...
    'Lfunction',false); % This flag specify if the .m file is a script or a function.
            
%% Construct the Evaluator
% First mode (The object are passed by reference) 

Xeval1 = Evaluator('CXmembers',{Xm}, ...
                       'Xjobmanagerinterface',Xjm,...
                       'CSqueues',{'MatlabPool',''},...
                       'Vconcurrent',[6]);

Xmdl=Model('Xinput',Xin,'Xevaluator',Xeval1,'Sdescription','The Model');
    % Construct a Mio object
