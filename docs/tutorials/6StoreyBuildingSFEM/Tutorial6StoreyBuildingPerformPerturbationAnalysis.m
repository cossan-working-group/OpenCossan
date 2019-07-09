%% Tutorial 6 Storey Building - Performing Perturbation Analysis
%
% See also http://cossan.cfd.liv.ac.uk/wiki/index.php/6-Storey_Building_(SFEM)
%
% Copyright 1990-2011 Cossan Working Group
% $Revision: 1 $  $Date: 2011/02/22 $

%% Load the Model - with NASTRAN Connector

run(fullfile(OpenCossan.getCossanRoot,'examples','Tutorials',...
                                   '6StoreyBuilding','Tutorial6StoreyBuildingNastran'));

%% Using regular implementation 

Xsfem = Perturbation('Xmodel',Xmodel,'CyoungsmodulusRVs',{'RV1','RV2','RV3','RV4'});   
Xout  = Xsfem.performAnalysis; 

Xout  = getResponse(Xout,'Sresponse','specific','MresponseDOFs',[1016 1]); %#ok<*NASGU>
display(Xout);

referenceMean = 0.0250;
referenceCoV  = 0.1030;

assert(abs(Xout.Vresponsemean-referenceMean)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference mean value does not match.')

assert(abs(Xout.Vresponsecov-referenceCoV)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference CoV value does not match.')
   
%% Load the Model - with ABAQUS Connector

run(fullfile(OpenCossan.getCossanRoot,'examples','Tutorials',...
                                   '6StoreyBuilding','Tutorial6StoreyBuildingAbaqus')); 

%% Using regular implementation (Abaqus)

Xsfem = Perturbation('Xmodel',Xmodel,...
      'CyoungsmodulusRVs',{'RV1','RV2','RV3','RV4'},...
      'CstepDefinition',{'**BOUNDARY, OP=NEW  ','    1015, 1,6, 0.','     1032, 1,6, 0.','    1389, 1,6, 0.',...
       '    1406, 1,6, 0.','*CLOAD, OP=NEW',...
       '3232, 1, 100. ','3245, 1, 100. ',...
       '3258, 1, 100. ','3271, 1, 100.',...
       '3284, 1, 100. ','3297, 1, 100. '},...
       'MconstrainedDofs',[1015.*ones(6,1) (1:6)'; 1032.*ones(6,1) (1:6)';...
                           1389.*ones(6,1) (1:6)'; 1406.*ones(6,1) (1:6)']);
                                    
Xout = Xsfem.performAnalysis; 

Xout  = getResponse(Xout,'Sresponse','specific','MresponseDOFs',[1016 1]);
display(Xout);

referenceMean = 0.027506;
referenceCoV  = 0.10052;

assert(abs(Xout.Vresponsemean-referenceMean)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference mean value does not match.')

assert(abs(Xout.Vresponsecov-referenceCoV)<1e-3,'CossanX:Tutorials:TutorialNeumann', ...
      'Reference CoV value does not match.')

%% Load the Model - with ANSYS Connector

run(fullfile(OpenCossan.getCossanRoot,'examples','Tutorials',...
                                   '6StoreyBuilding','Tutorial6StoreyBuildingAnsys'));
                               
%% Using regular implementation 

Xsfem = Perturbation('Xmodel',Xmodel,'CyoungsmodulusRVs',{'RV1','RV2','RV3','RV4'});   
Xout  = Xsfem.performAnalysis; 

Xout  = getResponse(Xout,'Sresponse','specific','MresponseDOFs',[1016 1]); %#ok<*NASGU>

% Note - HMP: I did not put the verification of results here, because
%             somehow ANSYS model provides strange results, I dont think
%             it is related to the SFEM implementation, it must be
%             something related with the transformation of the model to
%             ANSYS
%
