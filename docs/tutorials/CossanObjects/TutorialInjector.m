%% TUTORIALINJECTOR
% This turorial shows how to create and use an Injector object
% The injector is used to prepare the input files of 3rd party software.
%
% The injector is never used directly but it is embedded in a Connector
% object.
%
% See Also:  TutorialConnector
%
% $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK,EU$
% $Author:~Edoardo~Patelli$
% $email address: openengine@cossan.co.uk$
% $Website: http://www.cossan.co.uk$

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
clear
close all
clc;

%% Example script for the connector
%
% input file name plate.dat and plate.cossan for the injector
% output file name plate.f06
%
% FE CODE: nastran
%
%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/@Connector

% TODO: Add description


%% WARNING
Sfolder=fileparts(mfilename('fullpath'));% returns the current folder

%%  Create the Injector
SfilePath= fullfile(Sfolder,'Connector','NASTRAN');

%% Scan File with "IDENTIFIERS"
% An indentifier is a XLM String Data Type containing variable decraration.
% An example of IDENTIFIER is the following: 
% 
% <cossan name="I" index="1" format="%1d" original="1"/>
%
% where the properties are: 
% * name: the name of the variable to be injected 
% * format: format use to write the variable in the input file
%         (see fscanf for more details about the format string
%          ordinary characters and/or conversion specifications).
% * index: index of the variable. The index identifies the specific value
%          of he multivalue variables 
% * original: original value of the variable (this property is used to
%             reconstruct the original input file without identifiers

% Authomatic identification of the position and format of the variables that
% need to be injected
Xin=opencossan.workers.ascii.Injector('Sscanfilepath',SfilePath,...
    'Sscanfilename','plate.cossan','Sfile','plate.dat');

display(Xin)

%% Example: Random Material
% In this example a random material (i.e. random field) is created
% injecting integer random numbers (1 or 2), and creating a plate where the
% material of the elements is randomly chosen between the two avaialable
% material. 

% Create Parameters
mat1=opencossan.common.inputs.Parameter('value',7E+7);
mat2=opencossan.common.inputs.Parameter('value',2E+7);
% Create uniform discrete random variable with value 1 and 2
rv=opencossan.common.inputs.random.UniformDiscreteRandomVariable('bounds',[0, 2]);
% Create a set of 256 identically distributed random varaibles. The name of
% the random variable is automaticall set adding "_i" to the name of the
% original random variable (in this case rv -> rv_1 ... rv_256)
rvset1=opencossan.common.inputs.random.RandomVariableSet('names',{'rv'},'Nrv',256,'members',[rv]);

Xinp = Input('CXmembers',{mat1,mat2,rvset1},...
    'CSmembers',{'mat1','mat2','rvset1'});
Xinp = Xinp.sample('Nsamples',1);


