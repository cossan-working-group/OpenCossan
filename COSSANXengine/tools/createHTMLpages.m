function createHTMLpages(Sdist,Levalcode,NverboseLevel)
%% createHTMLpages for the COSSAN documentation
% This function require the full path of the destination folder
%
% Author: Edoardo Patelli
% Cossan Working group
% email address: openengine@cossan.co.uk
% Website: http://www.cossan.co.uk

assert(nargin==3,'openCOSSAN:build', ...
    strcat('The following inputs are required:', ...
    '\n1) The fullpath of the destination folder',...
    '\n2) flag for the evaluation of the Tutorials',...
    '\n3) The verbosity level'))
Spwd=pwd;

mkdir('/tmp/COSSAN')
OpenCossan.setWorkingPath('/tmp/COSSAN');

%% Remove Database storage
global OPENCOSSAN
XoldDriver=OPENCOSSAN.XdatabaseDriver;
OPENCOSSAN.XdatabaseDriver=[];

Ssrc=fullfile(OpenCossan.getCossanRoot,'examples','Tutorials');
disp(['Cossan source folder: ' Ssrc])

%% All the Tutorials must be in the path

disp(['Creating OpenCossan documentation in the foder: ' Sdist])
disp('Creating destination folder...')

%% create the target directory
[~, Smess] = mkdir(Sdist);

if ~isempty(Smess) % if the directory already exist
    disp('Directory already exist in target folder, skipping...')
    disp(Smess)
else
    disp('Destination folder created!')
end


% Updated on 1/05/2011
Cfiles={ ...
% Process CossanObjects Tutorials         
% Common
        'EP' 'CossanObjects/TutorialOpenCossan.m'; ...             % OK
        'BG' 'CossanObjects/TutorialDataseries.m'; ...          % OK
        'EP' 'CossanObjects/TutorialEvaluator.m'; ...           % OK
        'EP' 'CossanObjects/TutorialMarkovChain.m';...          % OK    
        'EP' 'CossanObjects/TutorialModel.m';...                % OK
        'PB' 'CossanObjects/TutorialSamples.m';...              % TBR
        'EP' 'CossanObjects/TutorialSolutionSequence.m';...     % OK
        'MB' 'CossanObjects/TutorialTimer.m';...                % 875    
% Connector       
        'MB'  'CossanObjects/TutorialConnectorABAQUS.m'; ...    % 875   
        'MB'  'CossanObjects/TutorialConnectorANSYS.m'; ...     % 875   
        'MB'  'CossanObjects/TutorialConnectorASTER.m'; ...     % 875   
        'MB'  'CossanObjects/TutorialConnectorNASTRAN.m'; ...   % 875   
        'MB'  'CossanObjects/TutorialConnectorFEAP.m'; ...      % 875   
        'MB' 'CossanObjects/TutorialExtractor.m'; ...           % 875 
        'MB' 'CossanObjects/TutorialHBExtractor.m'; ...         % 875 
        'MB'  'CossanObjects/TutorialIdentifier.m'; ...         % 875 
        'MB'  'CossanObjects/TutorialInjector.m'; ...           % 875     
        'MB'  'CossanObjects/TutorialMappingExtractor.m'; ...   % 875  
        'BG'  'CossanObjects/TutorialMTXExtractor.m'; ...       % OK
        'MB' 'CossanObjects/TutorialOp4Extractor.m'; ...        % 875 
        'MB' 'CossanObjects/TutorialPunchExtractor.m'; ...      % OK
        'MB'  'CossanObjects/TutorialResponse.m'; ...           % OK 
        'MB'  'CossanObjects/TutorialTableExtractor.m'; ...     % OK        
        'MB'  'CossanObjects/TutorialMio.m';...                 % OK
% FatigueFracture 
        'PB'  'CossanObjects/TutorialFatigueFracture.m';...     % 876
        'PB'  'CossanObjects/TutorialFracture.m';...            % 876
        'PB'  'CossanObjects/TutorialCrackGrowth.m';...         % 876
% HighPerformanceComputing
        'MB'  'CossanObjects/TutorialJobManager.m';...          % 877
        'MB'  'CossanObjects/TutorialJobManagerInterface.m';... % 877     
% Input
        'BG'  'CossanObjects/TutorialCovarianceFunction.m';...  % ok
        'PB'  'CossanObjects/TutorialDesignVariable.m';...      % OK
        'PB'  'CossanObjects/TutorialFunction.m';...            % OK
        'PB'  'CossanObjects/TutorialGaussianMixtureRandomVariableSet.m'; ...    OK  
        'PB'  'CossanObjects/TutorialInput.m'; ...              % OK
        'PB'  'CossanObjects/TutorialParameter.m'; ...          % OK
        'PB'  'CossanObjects/TutorialRandomVariable.m';...      % OK
        'PB'  'CossanObjects/TutorialRandomVariableSet.m';...   % OK
        'BG'  'CossanObjects/TutorialStochasticProcess.m';...   % OK
        'PB'  'CossanObjects/TutorialUserDefRandomVariable.m';...% OK
% MetaModel        
        'MB'  'CossanObjects/TutorialMetaModel.m';...           %  878
        'BG'  'CossanObjects/TutorialModeBased.m';...           % ok
        'MB'  'CossanObjects/TutorialNeuralNetwork.m';...       % 878
        'BG' 'CossanObjects/TutorialPolynomialChaos.m';...      % 880
        'MB'  'CossanObjects/TutorialResponseSurface.m';...     % 878
% Optimization         
        'EP'  'CossanObjects/TutorialBFGS.m';...                % OK
        'EP'  'CossanObjects/TutorialCobyla.m';...              % OK
        'EP'  'CossanObjects/TutorialConstraint.m'; ...         % OK
        'EP'  'CossanObjects/TutorialCrossEntropy.m';...        % OK
        'EP'  'CossanObjects/TutorialEvolutionStrategy.m';...   % OK
        'EP'  'CossanObjects/TutorialGeneticAlgorithms.m';...   % OK
        'EP'  'CossanObjects/TutorialMiniMax.m';...             % OK
        'EP'  'CossanObjects/TutorialObjectiveFunction.m';...   % OK
        'EP'  'CossanObjects/TutorialOptimizationProblem.m';... % OK
        'EP'  'CossanObjects/TutorialOptimizer.m';...           % OK
        'EP'  'CossanObjects/TutorialRBOProblem.m';...          % OK
        'EP'  'CossanObjects/TutorialSequentialQuadraticProgramming.m';... OK
        'EP'  'CossanObjects/TutorialSimplex.m';...             % OK
        'EP'  'CossanObjects/TutorialSimulatedAnnealing.m';...  % OK
        'MB'  'CossanObjects/TutorialRobustDesign.m';...        % 879
% Output        
        'EP'  'CossanObjects/TutorialCutSet.m'; ...             % ok 
        'EP'  'CossanObjects/TutorialDesignPoint.m'; ...        % ok
        'EP'  'CossanObjects/TutorialFailureProbability.m'; ... % ok
        'EP'  'CossanObjects/TutorialGradient.m'; ...           % ok
        'PB'  'CossanObjects/TutorialLineSamplingOutput.m'; ... % ok
        'BG'  'CossanObjects/TutorialModes.m'; ...              % ok
        'EP'  'CossanObjects/TutorialOptimum.m'; ...            % ok
        'EP'  'CossanObjects/TutorialSensitivityMeasures.m'; ...%  ok
        'HMP' 'CossanObjects/TutorialSfemOutput.m'; ...         %  ok
        'BG'  'CossanObjects/TutorialSimulationData.m';...      % ok
        'PB'  'CossanObjects/TutorialSubsetOutput.m';...        % 881
% Reliability          
        'EP' 'CossanObjects/TutorialFaultTree.m'; ...           % ok
        'EP' 'CossanObjects/TutorialPerformanceFunction.m'; ... % ok
        'EP' 'CossanObjects/TutorialProbabilisticModel.m'; ...  % ok 
        'EP' 'CossanObjects/TutorialSystemReliability.m';...    % TBR
% Sensitivity     
        'EP' 'CossanObjects/TutorialLocalSensitivityMeasures.m';... OK
        'EP' 'CossanObjects/TutorialSensitivity.m';... OK (TB extended???)
% sfem          
        'BG' 'CossanObjects/TutorialNastsem.m'; ...             % OK
        'BG' 'CossanObjects/TutorialNeumann.m'; ...             % ??
        'BG' 'CossanObjects/TutorialPerturbation.m'; ...        % ??
        'BG' 'CossanObjects/TutorialSfem.m'; ...                % ??
        'BG' 'CossanObjects/TutorialSfemPolynomialChaos.m'; ... % ??       
% simulations
        'HMP' 'CossanObjects/TutorialDesignOfExperiment.m'; ... % OK
        'EP'  'CossanObjects/TutorialHaltonSampling.m'; ...     % OK 
        'EP'  'CossanObjects/TutorialImportanceSampling.m'; ... % OK
        'EP'  'CossanObjects/TutorialLatinHypercubeSampling.m';... % OK
        'EP'  'CossanObjects/TutorialLineSampling.m';...        % OK      
        'EP'  'CossanObjects/TutorialMonteCarlo.m';...          % OK
        'EP'  'CossanObjects/TutorialSimulations.m';...         % ok
        'EP'  'CossanObjects/TutorialSobolSampling.m';...       % ok       
        'EP'  'CossanObjects/TutorialSubSet.m';...              % OK  
% Process real tutorials
        'BG' '6StoreyBuilding/Tutorial6StoreyBuildingAbaqus.m';...
        'BG' '6StoreyBuilding/Tutorial6StoreyBuildingAnsys.m';...
        'BG' '6StoreyBuilding/Tutorial6StoreyBuildingNastran.m';...
        'BG' '6StoreyBuilding/Tutorial6StoreyBuildingFeap.m';...
        'BG' '6StoreyBuilding/Tutorial6StoreyBuildingFeapSensitivityAnalysis.m';...
        'BG' '6StoreyBuilding/Tutorial6StoreyBuildingPerformPerturbationAnalysis.m';...
        'MB'  'AntennaTower/TutorialAntennaTowerSixSigma.m'; ...
        'PB'  'BikeFrame/TutorialBikeFrame.m';...
        'EP'  'BridgeModel/TutorialBridgeModel.m';...
        'EP'  'CantileverBeam/TutorialCantileverBeam.m'; ...
        'EP'  'CantileverBeam/TutorialCantileverBeamAnsys.m'; ...     
        'EP'  'CantileverBeam/TutorialCantileverBeamAnsysOptimization.m'; ...
        'EP'  'CantileverBeam/TutorialCantileverBeamMatlab.m'; ...
        'EP'  'CantileverBeam/TutorialCantileverBeamMatlabOptimization.m'; ...
        'EP'  'CantileverBeam/TutorialCantileverBeamMatlabReliabilityAnalysis.m'; ...  
        'EP'  'CantileverBeam/TutorialCantileverBeamMatlabReliabilityBasedOptimization.m'; ...  
        'EP'  'CantileverBeam/TutorialCantileverBeamOptimization.m'; ...
        'BG'  'CargoCrane/TutorialCargoCrane.m';...
        'MB'  'CarModel/TutorialCarModel.m';...
        'MB'  'CylindricalShell/TutorialCylindricalShell.m';...
        'BG'  'GOCEsatellite/TutorialGOCEsatellite.m';...        
        'EP'  'InfectionDynamicModel/TutorialInfectionDynamicModel.m';...
        'EP'  'InfectionDynamicModel/TutorialInfectionDynamicModelGlobalSensitivityAnalysis.m';...
        'EP'  'ParallelSystem/TutorialParallelSystemReliabilityAnalysis.m';...
        'BG' 'SmallSatellite/TutorialSmallSatelliteModal.m'; ...
        'BG' 'SmallSatellite/TutorialSmallSatelliteStatic.m'; ...
        'PB'  'SuspensionArm/TutorialSuspensionArm.m'; ...
        'BG'  'TrussBridgeStructure/TutorialTrussBridgeStructure.m'; ...
        'BG' 'TurbineBlade/TutorialTurbineBladeAbaqus.m'; ...  
        'BG' 'TurbineBlade/TutorialTurbineBladeNastran.m'; ...  
    };



Toptions.outputDir=Sdist;
Toptions.evalCode=Levalcode;

OpenCossan.setVerbosityLevel(NverboseLevel);
%

for i = 1:length(Cfiles) % first two records are . and .. directories
  disp(['Publishing file:' fullfile(Ssrc,Cfiles{i,2})])
  publish(Cfiles{i,2},Toptions);
  close all
end

%% Restore Database settings
OPENCOSSAN.XdatabaseDriver=XoldDriver;
