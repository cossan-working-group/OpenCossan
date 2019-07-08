%% Tutorial: create a PerformanceFunction object
% Create a user defined performance function 
% A user defined PerformaceFunction can be defined passing a Function
% object to the constructor of the Performance Function 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@PerformanceFunction
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli~and~Barbara-Goller$ 

%% Create a performance function manipulating variable of the
% SimulationData object

% Create a fake SimulationData object
Toutput.variableA=5;
Toutput.variableB=11;

Xout=SimulationData('Tvalues',Toutput);

% define performace function as variableA-variableB
Xpf=PerformanceFunction('Sdescription','variableA-variableB', ...
                        'Sdemand','variableB','Scapacity','variableA','Soutputname','Vg1');

% Show summary of the PerformanceFunction
display(Xpf)
                
% Evaluate the PerformanceFunction                    
Xout2=Xpf.apply(Xout);

% Show values of the performance function 
Vg=Xout2.getValues('Sname',Xpf.Soutputname)


% Suppose now to have more samples (let say 2). The apply method returs two
% values.

Toutput(2).variableA=10;
Toutput(2).variableB=12;
Xout=SimulationData('Tvalues',Toutput);
Xout2=Xpf.apply(Xout);

% Show results
Vg=Xout2.getValues('Sname',Xpf.Soutputname)

% One more sample
Toutput(3).variableA=11;
Toutput(3).variableB=11;
Xout=SimulationData('Tvalues',Toutput);
Xout2=Xpf.apply(Xout);

% Show results
Vg=Xout2.getValues('Sname',Xpf.Soutputname)

%% Construct User Defined Performance Function
% A Mio object is used to define a PerformanceFunction
Xm=Mio('Sscript','Moutput=Minput(:,1)+Minput(:,2);', ...
      'Cinputnames',{'variableA','variableB'},...
      'Coutputnames',{'Vg'},'Liomatrix',true,'Lfunction',false,'Liostructure',false);
  
% Construct PerformanceFunction  
XpfM1=PerformanceFunction('Sdescription','User defined PerformanceFunction', ...
                        'Xmio',Xm);
% Show summary of the PerformanceFunction
display(XpfM1)   

% Construct PerformanceFunction  
XpfM2=PerformanceFunction('Sdescription','User defined PerformanceFunction', ...
                        'CXmio',{Xm});                 

% Show summary of the PerformanceFunction
display(XpfM2)
                
% Evaluate the PerformanceFunction                    
Xout2=XpfM1.apply(Xout);
display(Xout2)

%% Using smooth indicator function
% This section shows an important feature of the object  "PerformanceFunction"
% that allows calculating the probability of failure using a smooth indicator
% function. 
%
%   The concept of smooth indicator function implies that the traditional
%   indicator function (which is a heaviside or step function) is replaced
%   by a smooth version. The smooth version is modeled using the CDF of a
%   Gaussian distribution. Details on the theoretical aspects of this
%   smooth indicator function can be found at:
%   
%   Taflanidis, A. and J. Beck: 2008, `An efficient framework for optimal 
%   robust stochastic system design using stochastic simulation'. Computer 
%   Methods in Applied Mechanics and Engineering, 198(1), 88-101.

% In order to use the smooth indicator function it is necessary to define the
% field stdDeviationIndicatorFunction in the PerformanceFunction

XpfSmooth     = PerformanceFunction('Scapacity','Xthreshold',...  %indicate threshold to be used
    'Sdemand','out1',...    %indicate parameter modeling the demand
    'Soutputname','Vg',...  %name of performance function
    'stdDeviationIndicatorFunction',0.05);  %this parameter is used to define the standard
    %deviation of the Gaussian CDF used to define the indicator function

display(XpfSmooth)
