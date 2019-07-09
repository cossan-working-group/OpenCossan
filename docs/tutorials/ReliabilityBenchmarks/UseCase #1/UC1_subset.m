%% RELIABILITY ANALYSIS using SubSet simulation of a system composed by parallel components.
% Author: Edoardo Patelli
%
% <html>
% <h3 style="color:#317ECC">Copyright 2006-2014: <b> COSSAN working group</b></h3>
% Author: <b>Edoardo-Patelli</b> <br>
% <i>Institute for Risk and Uncertainty, University of Liverpool, UK</i>
% <br>COSSAN web site: <a href="http://www.cossan.co.uk">http://www.cossan.co.uk</a>
% <br><br>
% </html>

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example # 5 (pag.271) from the paper:                                   %
% "A benchmark study on importance sampling techniques in structural      %
% reliability" S.Engelung and R. Rackwitz. Structural Safety, 12 (1993)   %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define the problem
UC1_problemDefinition

% Expecting a ProbabilisticModel named XpmALL containg the performance
% function defined by the intersection of the all performance functions
% (i.e. max)

% The reference solution is 1.6e-4 (computed via MC simulation)

% Define Subset simulation
XssMCMC=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',500, 'Nbatches',1);

% Performe subset simulation
tic, [Xpfss, XoutSS]=XpmALL.computeFailureProbability(XssMCMC); toc
display(Xpfss)
% display(Xo)
h1=XoutSS.plotLevels('Stitle','MCMC algorithm','Lseeds',false);
exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC1_t01.fig','SfullPath',pwd);
exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC1_t01.eps','SfullPath',pwd);

%% Subset-infinity algorithms
% use the Sharing sample option
Xsss=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',450, 'Nbatches',1,'VproposalVariance',0.5);

tic,[Xpfss2, XoutSSvar]=XpmALL.computeFailureProbability(Xsss);toc
display(Xpfss2)

h2=XoutSSvar.plotLevels('Stitle','Subset-\infty (shared sample)');
exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC1_v0.5.eps','SfullPath',pwd);
exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC1_v0.5.fig','SfullPath',pwd);

% without the Sharing sample option
XssNs=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',450, 'Nbatches',1,'VproposalVariance',0.2,'LsharedSampling',false);

tic,[Xpfss3, XoutSSvarNoSharing]=XpmALL.computeFailureProbability(XssNs);toc
display(Xpfss3)

h3=XoutSSvarNoSharing.plotLevels('Stitle','Subset-\infty (no shared sample)');
exportFigure('Hfigurehandle',h3,'Sfigurename','SubSet_UC1_v0.5_NoShare.eps','SfullPath',pwd);
exportFigure('Hfigurehandle',h3,'Sfigurename','SubSet_UC1_v0.5_NoShare.fig','SfullPath',pwd);


%% Compute reference solution
% Compute the reference solution by means of MC simulation using only 1
% limit state function
Xmc=MonteCarlo('Nsamples',5e5);
XpfMC=XpmALL.computeFailureProbability(Xmc);


LastName = {'Pf';'CoV';'Samples'};
VariableNames={'MonteCarlo' 'SubsetMCMC' 'SubsetInftyS' 'SubsetInfty'};

MC = [XpfMC.pfhat;XpfMC.cov;XpfMC.Nsamples];
SubsetMCMC =[Xpfss.pfhat;Xpfss.cov;Xpfss.Nsamples];
SubsetInfShared =[Xpfss2.pfhat;Xpfss2.cov;Xpfss2.Nsamples];
SubsetInfNoShared = [Xpfss3.pfhat;Xpfss3.cov;Xpfss3.Nsamples];

T = table(MC,SubsetMCMC,SubsetInfShared,SubsetInfNoShared,...
    'RowNames',LastName,'VariableNames',VariableNames)


%% Test convergence
Nrepeat=20;
Mpf=zeros(Nrepeat,3);
Mcov=zeros(Nrepeat,3);

for k=1:Nrepeat
    
    Xpf1=XpmALL.computeFailureProbability(XssMCMC);
    Mpf(k,1)=Xpf1.pfhat;
    Mcov(k,1)=Xpf1.cov;
    
    Xpf2=XpmALL.computeFailureProbability(Xsss);
    Mpf(k,2)=Xpf2.pfhat;
    Mcov(k,2)=Xpf2.cov;
    
    Xpf3=XpmALL.computeFailureProbability(XssNs);
    Mpf(k,3)=Xpf3.pfhat;
    Mcov(k,3)=Xpf3.cov;
end

LastName={'SubsetMCMC' 'SubsetInftyS' 'SubsetInfty'};
T3 = array2table(Mpf,'VariableNames',LastName);
summary(T3)

%% Study effect of variance on the simulation
Nrepeat=50;

Vvar=[0.1:0.1:1];

MpfSSS=zeros(Nrepeat,length(Vvar));
MpfSSN=zeros(Nrepeat,length(Vvar));

for n=1:length(Vvar)
    for k=1:Nrepeat        
        Xsss=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
            'Ninitialsamples',450, 'Nbatches',1,'VproposalVariance',Vvar(n),'LsharedSampling',true);
        
        Xpf2=XpmALL.computeFailureProbability(Xsss);
        MpfSSS(k,n)=Xpf2.pfhat;        
        
        XssNs=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
            'Ninitialsamples',450, 'Nbatches',1,'VproposalVariance',Vvar(n),'LsharedSampling',false);
        
        Xpf3=XpmALL.computeFailureProbability(XssNs);
        MpfSSN(k,n)=Xpf3.pfhat;
    end
end

h4=figure,
boxplot(MpfSSS,Vvar)
title('SubSim-\infty (shared)')
xlabel('s'), ylabel('Failure probability')
hold on,
plot([0.5 10.5],[XpfMC.pfhat XpfMC.pfhat],':')
Haxes = gca; 
Haxes.YScale='log'
exportFigure('Hfigurehandle',h4,'Sfigurename','SubSet_UC1_Shared_Variance.fig','SfullPath',pwd);


h5=figure,
boxplot(MpfSSN,Vvar)
hold on,
title('SubSim-\infty (non-shared)')
xlabel('s'), ylabel('Failure probability')
Haxes = gca; 
Haxes.YScale='log'
exportFigure('Hfigurehandle',h5,'Sfigurename','SubSet_UC1_NonShared_Variance.fig','SfullPath',pwd);