%% Tutorial Small Satellite - Perform PC Analysis with the Static Model
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/Satellite_(SFEM)

% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $

%% Load the Model - with NASTRAN Connector

Sdirectory = fileparts(which('TutorialSmallSatellitePerformPCAnalysis'));
run(fullfile(Sdirectory,'TutorialSmallSatelliteStatic'));

%% Using regular implementation (NASTRAN)

Xsfem = SfemPolynomialChaos('Xmodel',Xmodel,'Smethod','Galerkin',...
                'CdensityRVs',{'Dvert','Dhor','Dcyl','Dnozzle',},...
                'CyoungsmodulusRVs',{'Evert','Ehor','Ecyl','Enozzle',},...
                'CthicknessRVs',{'tvert','thor','tcyl','tnozzle',},...
                'Norder',2);
                   
Xout = Xsfem.performAnalysis;

Xout = getResponse(Xout,'Sresponse','specific','MresponseDOFs',[50123 1]);
display(Xout);

%% Validate the results

referenceMean = 2.4863;
referenceCoV  = 0.21413;

assert(abs(Xout.Vresponsemean-referenceMean)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference mean value does not match.')

assert(abs(Xout.Vresponsecov-referenceCoV)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference CoV value does not match.')


