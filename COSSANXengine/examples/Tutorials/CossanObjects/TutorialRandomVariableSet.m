%% TUTORIALRANDOMVARIABLESET
% This tutorial shows the how to use and create a random variable object
%
% See Also:  https://cossan.co.uk/wiki/index.php/@RandomVariableSet
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 

%%   Create random variables
Xrv1    = RandomVariable('Sdescription','rv 1','Sdistribution','gamma',...
            'mean',10,'std',2);       
Xrv2    = RandomVariable('Sdescription','rv 2','Sdistribution','exponential',...                                            % distribution name
            'parameter1',1);

           
%%  Create a random variable set
Mcorrelation    = [1 .1; .1 1];   %define correlation

% In this example, the random variables are passed explicitely
% the RVs are named Xrv1 and Xrv2 (in the workspace) and
% will be named X1 and X2 in the random variable set
Xrvs1           = RandomVariableSet(...
    'Cmembers',{'X1', 'X2'},'Mcorrelation',Mcorrelation,'CXrv',{Xrv1,Xrv2}); 

%% evalpdf

%evaluation of the pdf in the physical space
[Vpdf01, Vpdfrv01] = evalpdf(Xrvs1,'MXsamples',[1 2]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

%evaluation of the pdf in the standard normal space
[Vpdf02, Vpdfrv02] = evalpdf(Xrvs1,'MUsamples',[1 2;2 1]);

%evaluation of the LOGARITM of the pdf in the standard normal space
[Vpdf03, Vpdfrv03] = evalpdf(Xrvs1,'MUsamples',[1 2],'Llog',true);

%% map2physical
%converts the values (given as as an input) from the standard normal space
%to the physical space
map2physical(Xrvs1,[0.6 0.1; .1 .2])
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

%% map2stdnorm
%converts the values (given as as an input) from the physical space 
%to the standtrd normal space
map2physical(Xrvs1,[0.7 0.1 ]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

%% cdf2physical
%converts the values (given as as an input) from the hypercube
%to the physical space
cdf2physical(Xrvs1,[0.7 0.1 ])
%the number of columns of the input matrix must be equal to the number of
%random variables in the set


%% cdf2stdnorm
%converts the values (given as as an input) from the hypercube
%to standtrd normal space
cdf2stdnorm(Xrvs1,[0.7 0.1 ])
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

%% stdnorm2cdf
%converts the values (given as as an input) from the standtrd normal space
%to the spacehypercube
stdnorm2cdf(Xrvs1,[0.7 0.1 ]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set


