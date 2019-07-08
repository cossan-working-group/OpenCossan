% USE CASE # 4 - linear analysis of teh 6-story building
%% Reset
%OpenCossan.reset

OpenCossan.setWorkingPath('/home/epatelli/workspace/OpenCossan/trunk/COSSANXengine/examples/Show_Cases/Reliability/UseCase#4')

SSHConnection('SSSHhost','cossan.cfd','SSSHuser','ep',...
              'SsshPrivateKey','~/.ssh/id_rsa',...
              'SremoteWorkFolder','/home/ep/tmp',...
              'SremoteMCRPath','/usr/software/matlab/MATLAB_Compiler_Runtime/v81/',...
              'SremoteExternalPath','/home/ep/workspace/OpenCossan/trunk/OpenSourceSoftware/')

run('A_define_Input.m')

disp('');
disp('--------------------------------------------------------------------------------------------------');
disp('USE CASE #4: LINEAR ANALYIS 6th story building');
disp('--------------------------------------------------------------------------------------------------');



%% CREATE CONNECTOR
run('B_define_PhysicalModel.m')

%% CREATE XGRID

Xjmi        = JobManagerInterface('Stype','GridEngine');

% Xg          = JobManager('Spostexecmd',Spostexecmd,'Xjobmanagerinterface',Xjmi);

%% CREATE EVALUATOR
Xev  = Evaluator('Xconnector',Xc,'XjobmanagerInterface',Xjmi,...
    'CSqueues',{'all.q'},'Vconcurrent',6,'LremoteInjectExtract',true,'CShostnames',{'cossan.cfd.liv.ac.uk'});

%%  CREATE MODEL
Xmdl  = Model('Xevaluator',Xev,'Xinput',Xinp);

%% Test Physical Model
%Xout=Xmdl.deterministicAnalysis;
%display(Xout)

%% PERFORM MCS
%Xmc  = MonteCarlo('Nsamples',1,'Nbatches',1);
%Xout = Xmc.apply(Xmdl);


Xmio = Mio('Sscript','for i=1:length(Tinput); Toutput(i).Vg1=Tinput(i).Xresistance - max([Tinput(i).C2286_1 Tinput(i).C2286_2 Tinput(i).C2286_3 Tinput(i).C2286_4]);end;',...
           'Cinputnames',{'Xresistance' 'C2286_1' 'C2286_2' 'C2286_3' 'C2286_4'}, ...
           'Coutputnames',{'Vg1'});
       
Xpf=PerformanceFunction('Xmio',Xmio);

Xpm=ProbabilisticModel('Xmodel',Xmdl,'XPerformanceFunction',Xpf);

%% Subset


%% Construct a SubSet simulation objects
% Define the simulation object
XssMCMC=SubSet('Nmaxlevels',6,'target_pf',0.1,'Ninitialsamples',100,...
    'Nbatches',1,'Vdeltaxi',.2);

XssVar=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',100, 'Nbatches',1,'VproposalVariance',0.5);

[XpfMCMC,XoutMCMC]=Xpm.computeFailureProbability(XssMCMC);
[XpfCan,XoutCan]=Xpm.computeFailureProbability(XssVar);


%% Collect results
% i=1;
% Sfilename=['CX_MCS3_' num2str(i) '.mat'];
% XoutTOT=Xoutput;
% while exist(Sfilename,'file')
% 		load(Sfilename);
% 		XoutTOT=add(XoutTOT,'Xoutput',Xo);
% 		i=i+1
% 		Sfilename=['CX_MCS3_' num2str(i) '.mat'];
% end
% 
% Tout=get(XoutTOT,'Toutput');
% 
% Fd=zeros(length(Tout),6);
% for i=1:length(Tout)
% 	Fd(i,1)=Tout(i).max_f1;
% 	Fd(i,2)=Tout(i).max_f2-Tout(i).max_f1;
% 	Fd(i,3)=Tout(i).max_f3-Tout(i).max_f2;
% 	Fd(i,4)=Tout(i).max_f4-Tout(i).max_f3;
% 	Fd(i,5)=Tout(i).max_f5-Tout(i).max_f4;
% 	Fd(i,6)=Tout(i).max_f6-Tout(i).max_f5;
% end
% 
% figure with 
%  plot (Fd)XpfCan
%  
% Vth=[0.01:0.005:0.05];
% 
% pf=zeros(length(Vth),size(Fd,2));
% for it=1:length(Vth)
% 	for j=1:size(Fd,2)
% 		pf(it,j)=length(find(Fd(:,j)>Vth(it)))/size(Fd,1);
% 	end
% end
