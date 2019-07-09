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

disp('');
disp('--------------------------------------------------------------------------------------------------');
disp('USE CASE #7: Parallel system in high dimensional space');
disp('--------------------------------------------------------------------------------------------------');

SpathU7  = fileparts(which('UC7_problemDefinition.m'));% returns the current folder

%% Define the input parameters
% In this example there are 5 random variable (standard normal) and 4
% limit state functions. 



Xrv=RandomVariable('Sdistribution','normal','mean',0,'std',1); 
XrvsetIID=RandomVariableSet('Nrviid',Nrv,'Xrandomvariable',Xrv);

Xinput=Input('Xrandomvariableset',XrvsetIID);

% using and empty evaluator
Xmodel=Model('Xinput',Xinput,'Xevaluator',Evaluator);

% Create a probabilistic model
%%  Definition of Mio objects
% The mio object contains the performance fucntion 
XmG7=Mio('Sdescription', 'Performance function g7', ...
        'Spath',SpathU7, ...
        'Sfile','performanceFunctionG7', ...
        'Liostructure',false, ...
        'Lfunction',true, ...
        'Liomatrix',true, ...
        'Coutputnames',{'g7'},...
        'Cinputnames',Xinput.CnamesRandomVariable);		

    
% Define Performance Functions
XperfunG7=PerformanceFunction('Xmio',XmG7);

% Define ProbabilisticModel
XpmG7=ProbabilisticModel('Xmodel',Xmodel,'XperformanceFunction',XperfunG7);
