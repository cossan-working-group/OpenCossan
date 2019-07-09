%% RELIABILITY ANALYSIS using SubSet simulation of a system composed by parallel components. 
% This USE CASE #7 analyze a system composed by parallel components in high dimensional space.
% It is an extension of the Use Case #1 and originally implemented for the
% paper: 
%
%  Patelli, E. Pradlwarter, H. J. & Schuëller, G. I.                      
% "On Multinormal Integrals by Importance Sampling for Parallel System    
%  Reliability Structural Safety, 2011, 33, 1-7                           
%
%
% <html>
% <h3 style="color:#317ECC">Copyright 2006-2014: <b> COSSAN working group</b></h3>
% Author: <b>Edoardo-Patelli</b> <br> 
% <i>Institute for Risk and Uncertainty, University of Liverpool, UK</i>
% <br>COSSAN web site: <a href="http://www.cossan.co.uk">http://www.cossan.co.uk</a>
% <br><br>
% </html>

% Author: Edoardo Patelli

%% Define the problem 

Nrv=100;

UC7_problemDefinition

% Expecting a ProbabilisticModel named XpmALL containg the performance
% function defined by the intersection of the all performance functions
% (i.e. max) 

%% Compute reference solution
% Compute the reference solution by means of MC simulation using only 1
% limit state function

% The reference solution is 2e-4 (computed via MC simulation)
XmonteCarlo=MonteCarlo('Nsamples',1e6, 'Nbatches',10);
tic, [Xpfmc, XoutMC]=XpmG7.computeFailureProbability(XmonteCarlo); toc

% Define Subset simulation 
XssMCMC=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',1000, 'Nbatches',1);

% Performe subset simulation
%tic, [Xpfss, XoutSS]=XpmG7.computeFailureProbability(XssMCMC); toc
%display(Xpfss)
% display(Xo)
% h1=XoutSS.plotLevels('Stitle','MCMC algorithm','Lseeds',false);
% exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC7_t01.fig','SfullPath',pwd);
% exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC7_t01.eps','SfullPath',pwd);

%% Test new subset algorithms
XssCAN=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',900, 'Nbatches',1,'VproposalVariance',0.5);

%tic,[Xpfss2, XoutSSvar]=XpmG7.computeFailureProbability(XssCAN);toc
%display(Xpfss2)

%h2=XoutSSvar.plotLevels('Stitle','Canonical algorithm');
%exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC7_v0.5.eps','SfullPath',pwd);
%exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC7_v0.5.fig','SfullPath',pwd);


% Compute and report summarry summary 
%disp(sprintf('         | Monte Carlo   | SubSet MCMC   | SubSet Canonical'))
%disp(sprintf(' Pf      |%e | %e  | %e ',Xpfmc.pfhat,Xpfss.pfhat,Xpfss2.pfhat))
%disp(sprintf(' CoV     |%e | %e  | %e ',Xpfmc.cov,Xpfss.cov,Xpfss2.cov))
%disp(sprintf(' Samples |%e | %e  | %e ',Xpfmc.Nsamples,Xpfss.Nsamples,Xpfss2.Nsamples))



%% Test convergence
Nrepeat=20;
Mpf=zeros(Nrepeat,2);
Mcov=zeros(Nrepeat,2);
Mcpu=zeros(Nrepeat,2);

    for k=1:Nrepeat
        
        tic,Xpf1=XpmG7.computeFailureProbability(XssCAN);
        Mcpu(k,1)=toc;
        Mpf(k,1)=Xpf1.pfhat;
        Mcov(k,1)=Xpf1.cov;
        
        tic, Xpf2=XpmG7.computeFailureProbability(XssCAN);
        Mcpu(k,2)=toc;
        Mpf(k,2)=Xpf2.pfhat;
        Mcov(k,2)=Xpf2.cov;
    end

Vmin=min(Mpf);
Vmax=max(Mpf);
Vmedian=median(Mpf);
Vcpu=median(Mcpu);

disp(sprintf('Number of variables: %i',Nrv))
disp(sprintf('      Min    | median  | Max | CPUtime (median)'))
disp(sprintf('Subset MCMC      |%e %e %e %e | ',Vmin(1),Vmedian(1),Vmax(1),Vcpu(1)))
disp(sprintf('Subset Canonical |%e %e %e %e | ',Vmin(2),Vmedian(2),Vmax(2),Vcpu(2)))

save Vmin Vmax Vmedian Vcpu

%% Use 1000 variables
Nrv=1000;
UC7_problemDefinition

%% Test convergence
Nrepeat=20;
Mpf1000=zeros(Nrepeat,2);
Mcov1000=zeros(Nrepeat,2);
Mcpu1000=zeros(Nrepeat,2);

    for k=1:Nrepeat
        
        tic,Xpf1=XpmG7.computeFailureProbability(XssCAN);
        Mcpu1000(k,1)=toc;
        Mpf1000(k,1)=Xpf1.pfhat;
        Mcov1000(k,1)=Xpf1.cov;
        
        tic,Xpf2=XpmG7.computeFailureProbability(XssCAN);
        Mcpu1000(k,2)=toc;
        Mpf1000(k,2)=Xpf2.pfhat;
        Mcov1000(k,2)=Xpf2.cov;
    end

Vmin1000=min(Mpf1000);
Vmax1000=max(Mpf1000);
Vmedian1000=median(Mpf1000);
Vcpu1000=median(Mcpu1000);

% The reference solution is 2e-4 (computed via MC simulation)
tic, Xpfmc1000=XpmG7.computeFailureProbability(XmonteCarlo); toc

disp(sprintf('Number of variables: %i',Nrv))
disp(sprintf('      Min    | median  | Max | CPUtime (median)'))
disp(sprintf('Subset MCMC      |%e %e %e %e | ',Vmin1000(1),Vmedian1000(1),Vmax1000(1),Vcpu1000(1)))
disp(sprintf('Subset Canonical |%e %e %e %e | ',Vmin1000(2),Vmedian1000(2),Vmax1000(2),Vcpu1000(2)))
save Vmin1000 Vmax1000 Vmedian1000 Vcpu1000