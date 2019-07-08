% Thi USE CASE #1 analyze a system composed by parallel components. 
% Author: Edoardo Patelli
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example # 5 (pag.271) from the paper:
% "A benchmark study on importance sampling techniques in structural
% reliability" S.Engelung and R. Rackwitz. Structural Safety, 12 (1993)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Define the problem 
UC1_problemDefinition



% Compute the reference solution by means of MC simulation using only 1
% limit state function
Xmc=MonteCarlo('Nsamples',1e5);

Xpf=XpmALL.computeFailureProbability(Xmc);

disp('====================================================================');
disp('The reference solution has been computed by means of direct MC')
display(Xpf)

% Compute the design point of the Reliability Model
XdpALL=XpmALL.designPointIdentification('VinitialSolution',[2 2 2 2 2]);

% compute the failure probability with the Importance sampling method
Xis=ImportanceSampling('Nsamples', 1e4,'XdesignPoint',XdpALL);

XpfIS= XpmALL.pf(Xis);

disp('====================================================================');
disp('The reference solution has been computed by means of the IS')
display(XpfIS)

% Now we can estimate the failure probability of the system consider
% separately the contribute of each limit state functions

% First at all we use cossan to estimate the design point for each
% performance fucntion and we store the resultls indide the object
% SystemReliability. This is done automatically invoking the method
% designPointIdentification of the class SystemReliability

Xsys=Xsys.designPointIdentification;
display(Xsys);

% Now we can see which variable contributes most to the failure 
% Retrieve the important direction of each component

for i=1:length(Xsys.Cnames)
        Y(i,:)=Xsys.XdesignPoints{i}.VDirectionDesignPointStdNormal;
    disp(['Performance Function #' num2str(i) ])
	disp(['Direction        : ' sprintf('%8.3e ',Y(i,:)) ])
	disp(['Design Point     : ' sprintf('%8.3e ',Xsys.XdesignPoints{i}.VDesignPointStdNormal) ])
	disp(['Reliability Index: ' sprintf('%8.3e', Xsys.XdesignPoints{i}.ReliabilityIndex) ])

end
createbarfigureU1(Y,{'g1';'g2';'g3';'g4'},'Important direction of the System components')

% Find designPoint using linear hypothesis 
% It is not necessary to specify the cut-set since is already defined in
% the FaultTree included in the SystemReliability object

[Xcs,Mintersection] = Xsys.findLinearIntersection('tolerance',1e-2, ...
                      'Ccutset',{[1 2 3 4]});

display(Xcs)

%% Compute the failure probability for each event
Xmc=MonteCarlo('Nsamples',1e4);
Xsys=Xsys.pfComponents('Xsimulations',Xmc);

%% Compute the bounds of the cut set
Xcs= Xsys.computeBounds;

display(Xcs)
