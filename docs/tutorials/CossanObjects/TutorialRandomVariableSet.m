%% TUTORIALRANDOMVARIABLESET
% This tutorial shows the how to use and create a random variable object
%
% See Also:  http://cossan.co.uk/wiki/index.php/@RandomVariableSet
%
% Author: Pierre Beaurepaire
% Revised by: Edoardo Patelli
%
% Copyright 1993-2015, COSSAN Working Group
% Institute for Risk and Uncertainty, University of Liverpool, UK
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk
clear
close all
clc;
% =====================================================================
% This file is part of openCOSSAN.  The open general purpose matlab
% toolbox for numerical analysis, risk and uncertainty quantification.
%
% openCOSSAN is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License.
%
% openCOSSAN is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%  You should have received a copy of the GNU General Public License
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
% =====================================================================

% This tutorial shows how to use the class RandomVariableSet
% RandomVariableSet containes one or more RandomVariable objects and it is
% used to define correlation among random variables. In is also used to
% group the random variables in a single object. 
% Please note that it is not possible to pass directly RandomVariable to a
% Input object. RandomVariable must be included in a RandomVariableset. 

%   Create random variables
Xrv1    = opencossan.common.inputs.random.GammaRandomVariable('K',10,'Theta',2);
Xrv2    = opencossan.common.inputs.random.ExponentialRandomVariable('Lambda',1);
Xrv3    = opencossan.common.inputs.random.BinomialRandomVariable();


%  Create correlation matrix
Mcorrelation    = [1 .1; .1 1];   %define correlation

%% Contructor
% In this example, the random variables are passed explicitely
% the RVs are named Xrv1 and Xrv2 (in the workspace) and
% will be automatically named RV_1 and RV_2 in the random variable set
Xrvs1           = opencossan.common.inputs.random.RandomVariableSet(...
    'Members',[Xrv1 Xrv2],'names',{'Xrv1' , 'Xrv2'},'Correlation',Mcorrelation);
%In this example the RVs will be manually named according to the type of
%distribution
Xrvs2           = opencossan.common.inputs.random.RandomVariableSet(...
    'Members',[Xrv1 Xrv2],'Names',["GammaRVs" "NormalRVs"],'Correlation',Mcorrelation);

% Create a lower triangular correlation matrix
TriLoMatrix     =[1 0 0; 0.1 1 0; 0.2 0.3 1];
%It is sufficient to pass only a lower triangular coefficient matrix
Xrvs3           = opencossan.common.inputs.random.RandomVariableSet(...
    'Members',[Xrv1 Xrv2 Xrv3],'Names',["GammaRVs" "NormalRVs" "BinomialRVs"],'Correlation',TriLoMatrix);
%The RandomVariableSet will always automatically use the full Correlation
%Matrix and compute the Covariance.
Xrvs3_CorrMtrx  = full(Xrvs3.Correlation);
Xrvs3_CovMtrx   = full(Xrvs3.Covariance);

%% Methods

% evaluation of the pdf in the physical space
[Vpdf01, Vpdfrv01] = evalpdf(Xrvs1,'MXSamples',[1 2 ]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

%evaluation of the pdf in the standard normal space
[Vpdf02, Vpdfrv02] = evalpdf(Xrvs1,'MUSamples',[1 2;2 1]);

%evaluation of the LOGARITHM of the pdf in the standard normal space
[Vpdf03, Vpdfrv03] = evalpdf(Xrvs1,'MUSamples',[1 2],'Llog',true);

% map2physical:converts the values (given as as an input) from the standard normal space
% to the physical space
MsamplePhysical=map2physical(Xrvs1,[0.6 0.1; .1 .2]); 

%the number of columns of the input matrix must be equal to the number of
%random variables in the set

% map2stdnorm: converts the values (given as as an input) from the physical space
%to the standtrd normal space
MsampleStandarNormal=map2stdnorm(Xrvs1,[0.7 0.1 ]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

% cdf2physical: converts the values (given as as an input) from the hypercube
%to the physical space
MsamplePhysical=cdf2physical(Xrvs1,[0.7 0.1 ]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set


% cdf2stdnorm: converts the values (given as as an input) from the hypercube
%to standtrd normal space
MsampleStandarNormal=cdf2stdnorm(Xrvs1,[0.7 0.1]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

% stdnorm2cdf
%converts the values (given as as an input) from the standard normal space
%to the hypercube space
MsampleHyperCube=stdnorm2cdf(Xrvs1,[0.7 0.1 ]);
%the number of columns of the input matrix must be equal to the number of
%random variables in the set

%% Define Set of IID random Variables
% A set of independend identical distributed random varible can be create
% easily using the flag Nrviid and defining a 'base' random variable
XrvIID=opencossan.common.inputs.random.NormalRandomVariable('mean',0,'std',1);
XrvsetIID=opencossan.common.inputs.random.RandomVariableSet.fromIidRandomVariables(XrvIID,10,'baseName',"X");
% The names of the random variable are devined ad the name of the 'base'
% random varible plus '_XX' where XX is the number of the random variables.

% the names of the random variables can be retrieved accessing the field
% Names

Cname=XrvsetIID.Names

