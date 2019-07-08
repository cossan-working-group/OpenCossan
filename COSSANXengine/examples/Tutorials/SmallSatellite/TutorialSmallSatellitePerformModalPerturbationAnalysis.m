%% Tutorial Small Satellite - Performing Perturbation Analysis
%
% This tutorial shows how to perform SFEM analysis using Perturbation
% method. 
%
% Description of deterministic model:
%
% Tutorial satellite model is constructed in NASTRAN (~5000 DOFs). Modal
% analysis is performed on the structure, where the variation in the
% 2nd natural frequency is sought.
%
% Description of probabilistic model:
%
% The uncertainties in the Young's modulus and density are 
% modeled using independent normal RV's.  
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Small_Satellite_(SFEM - Modal)
%
% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/28 $


%% Load the Model - with NASTRAN Connector

Sdirectory = fileparts(which('TutorialSmallSatellitePerformModalPerturbationAnalysis'));
run(fullfile(Sdirectory,'TutorialSmallSatelliteModal'));
                               
%% Perform SFEM Analysis

Xsfem = Perturbation('Xmodel',Xmodel,'Sanalysis','Modal',...
                     'CdensityRVs',{'Dvert','Dhor','Dcyl','Dnozzle',},...
                     'CyoungsmodulusRVs',{'Evert','Ehor','Ecyl','Enozzle',});

Xout = Xsfem.performAnalysis;

Xout = getResponse(Xout,'Sresponse','specific','Nmode',2);
display(Xout);

%% Validate the results

referenceMean = 408.6050;
referenceCoV  = 0.15613;

assert(abs(Xout.Vresponsemean-referenceMean)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference mean value does not match.')

assert(abs(Xout.Vresponsecov-referenceCoV)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference CoV value does not match.')


