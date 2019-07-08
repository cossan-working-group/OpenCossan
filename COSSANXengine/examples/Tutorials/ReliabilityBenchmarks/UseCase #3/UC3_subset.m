%% RELIABILITY ANALYSIS using SubSet simulation of a non linear system
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
% Example from the paper:                                                 %
%  Patelli, E. Pradlwarter, H. J. & Schuëller, G. I.                      %
% "On Multinormal Integrals by Importance Sampling for Parallel System    %
%  Reliability Structural Safety, 2011, 33, 1-7                           %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define the problem 
UC3_problemDefinition

% Expecting a ProbabilisticModel named Xpm1or3 containg the performance
% function defined by the intersection of the all performance functions
% (i.e. max) 

% The reference solution is 1.6e-4 (computed via MC simulation)

% Define Subset simulation 
XssMCMC=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',500, 'Nbatches',1);

% Performe subset simulation
tic, [Xpfss, XoutSS]=Xpm1or3.computeFailureProbability(XssMCMC); toc
display(Xpfss)
% display(Xo)
h1=XoutSS.plotLevels('Stitle','MCMC algorithm','Lseeds',false);
exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC1_t01.fig','SfullPath',pwd);
exportFigure('Hfigurehandle',h1,'Sfigurename','SubSet_UC1_t01.eps','SfullPath',pwd);

%% Test new subset algorithms
XssCAN=SubSet('Nmaxlevels',6,'target_pf',0.1, ...
    'Ninitialsamples',450, 'Nbatches',1,'VproposalVariance',0.5);

tic,[Xpfss2, XoutSSvar]=Xpm1or3.computeFailureProbability(XssCAN);toc
display(Xpfss2)

h2=XoutSSvar.plotLevels('Stitle','Canonical algorithm');
exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC1_v0.5.eps','SfullPath',pwd);
exportFigure('Hfigurehandle',h2,'Sfigurename','SubSet_UC1_v0.5.fig','SfullPath',pwd);

%% Compute reference solution
% Compute the reference solution by means of MC simulation using only 1
% limit state function
Xmc=MonteCarlo('Nsamples',1e3);
[XpfMC, XoutMC]=Xpm1or3.computeFailureProbability(Xmc);

% Compute and report summarry summary 
disp(sprintf('         | Monte Carlo   | SubSet MCMC   | SubSet Canonical'))
disp(sprintf(' Pf      |%e | %e  | %e ',XpfMC.pfhat,Xpfss.pfhat,Xpfss2.pfhat))
disp(sprintf(' CoV     |%e | %e  | %e ',XpfMC.cov,Xpfss.cov,Xpfss2.cov))
disp(sprintf(' Samples |%e | %e  | %e ',XpfMC.Nsamples,Xpfss.Nsamples,Xpfss2.Nsamples))


%% Plot samples

Msamples=XoutMC.getValues;

Vindex=Msamples(:,3)>0;

figure
plot(x1,y1or3,'r'); hold on;
scatter(Msamples(Vindex,1),Msamples(Vindex,2),'.k')
scatter(Msamples(~Vindex,1),Msamples(~Vindex,2),'.r')

% %% Test convergence
% Nrepeat=20;
% Mpf=zeros(Nrepeat,2);
% Mcov=zeros(Nrepeat,2);
% 
% 
%     for k=1:Nrepeat
%         
%         Xpf1=XpmALL.computeFailureProbability(XssCAN);
%         Mpf(k,1)=Xpf1.pfhat;
%         Mcov(k,1)=Xpf1.cov;
%         
%         Xpf2=XpmALL.computeFailureProbability(XssCAN);
%         Mpf(k,2)=Xpf2.pfhat;
%         Mcov(k,2)=Xpf2.cov;
%     end
% 
% Vmin=min(Mpf);
% Vmax=max(Mpf);
% Vmedian=median(Mpf);
% 
% disp(sprintf('      Min    | median  | Max'))
% disp(sprintf('Subset MCMC      |%e %e %e | ',Vmin(1),Vmedian(1),Vmax(1)))
% disp(sprintf('Subset Canonical |%e %e %e | ',Vmin(2),Vmedian(2),Vmax(2)))

