%% Tutorial Small Satellite - Perform PC Analysis with the Static Model
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Small_Satellite_(SFEM_-_Static)

% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $


%% Load the Model - with NASTRAN Connector

Sdirectory = fileparts(which('TutorialSmallSatellitePerformNeumannAnalysis'));
run(fullfile(Sdirectory,'TutorialSmallSatelliteStatic'));

%% Using regular implementation (NASTRAN)

Xsfem = Neumann('Xmodel',Xmodel,...
                'CdensityRVs',{'Dvert','Dhor','Dcyl','Dnozzle',},...
                'CyoungsmodulusRVs',{'Evert','Ehor','Ecyl','Enozzle',},...
                'CthicknessRVs',{'tvert','thor','tcyl','tnozzle',},...
                'Nsimulations',200,'Norder',5);
            
% Fix the seed in order to generate same samples => to validate results
OpenCossan.resetRandomNumberGenerator(1);              
                   
Xout = Xsfem.performAnalysis;

Xout = getResponse(Xout,'Sresponse','specific','MresponseDOFs',[50123 1]);
display(Xout);

%% Validate the results

referenceMean = 2.4343;
referenceCoV  = 0.22895;

assert(abs(Xout.Vresponsemean-referenceMean)<1e-3,'CossanX:Tutorials:TutorialSmallSatelliteNeumann', ...
      'Reference mean value does not match.')

assert(abs(Xout.Vresponsecov-referenceCoV)<1e-3,'CossanX:Tutorials:TutorialSmallSatelliteNeumann', ...
      'Reference CoV value does not match.')


