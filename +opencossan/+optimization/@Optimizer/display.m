function display(Xobj)
%DISPLAY  Displays the summary of the Optimizer object
%
%
%   display(Xobj) will output the summary of the object Xobj
%
% Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria

OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' ' class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

%% Swow Termination criteria 
OpenCossan.cossanDisp('* Termination criteria ',2);
OpenCossan.cossanDisp(['** Timeout                     : ' num2str(Xobj.timeout)],1);
OpenCossan.cossanDisp(['** Iterations                  : ' num2str(Xobj.NmaxIterations)],1);
OpenCossan.cossanDisp(['** Function Evaluation         : ' num2str(Xobj.Nmax)],1)
OpenCossan.cossanDisp(['** Limit Objective Function    : ' num2str(Xobj.objectiveLimit)],1)
OpenCossan.cossanDisp(['** Tolerance Objective Function: ' num2str(Xobj.toleranceObjectiveFunction)],1)
OpenCossan.cossanDisp(['** Tolerance Constraint        : ' num2str(Xobj.toleranceConstraint)],1)
OpenCossan.cossanDisp(['** Tolerance Design Variables  : ' num2str(Xobj.toleranceDesignVariables)],1)

% Class Specific Termination Field
OpenCossan.cossanDisp('* Main Settings  : ',2)
switch class(Xobj)
    case 'Cobyla'
        OpenCossan.cossanDisp(strcat('** Initial trust region         : ',sprintf('%10.3e',Xobj.rho_ini)),1) 
        OpenCossan.cossanDisp(strcat('** Final trust region           : ',sprintf('%10.3e',Xobj.rho_end)),1) 
    case 'CrossEntropy'
              OpenCossan.cossanDisp(['** tolerance Sigma              : ' num2str(Xobj.tolSigma)],1)
        OpenCossan.cossanDisp(strcat('** model evaluation x iteration : ',sprintf('%i',Xobj.NFunEvalsIter)),1) 
        OpenCossan.cossanDisp(strcat('** Update samples size          : ',sprintf('%i',Xobj.NUpdate)),1) 
    case 'EvolutionStrategy'
        OpenCossan.cossanDisp(strcat('** parent population            : ',sprintf('%i',Xobj.Nmu)),1) 
        OpenCossan.cossanDisp(strcat('** offspring population         : ',sprintf('%i',Xobj.Nlambda)),1) 
        OpenCossan.cossanDisp(strcat('** Recombination size           : ',sprintf('%i',Xobj.Nrho)),1) 
        OpenCossan.cossanDisp(strcat('** Recombination function       : ',Xobj.Srecombination),1) 
        OpenCossan.cossanDisp(strcat('** Selection function           : ',Xobj.Sselection),1)         
        OpenCossan.cossanDisp(strcat('** Vsigma                       : ',sprintf('%10.3e',Xobj.Vsigma)),1) 
    case 'SequentialQuadraticProgramming'
        OpenCossan.cossanDisp(strcat('** finiteDifferencePerturbation : ',sprintf('%10.3e',Xobj.finiteDifferencePerturbation)),1) 
    case 'SimulatedAnnealing'
        OpenCossan.cossanDisp(strcat('** Annealing Function           : ',Xobj.SannealingFunction),1) 
        OpenCossan.cossanDisp(strcat('** Temperature Function         : ',Xobj.StemperatureFunction),1) 
        OpenCossan.cossanDisp(strcat('** Reanniling interval          : ',sprintf('%i',Xobj.NreannealInterval)),1) 
        OpenCossan.cossanDisp(strcat('* Initial Temperature          : ',sprintf('%10.3e',Xobj.initialTemperature)),1) 
    case 'GeneticAlgorithms'
        OpenCossan.cossanDisp(strcat('** Fitness scaling function     : ',Xobj.SFitnessScalingFcn),1) 
        OpenCossan.cossanDisp(strcat('** Selection function           : ',Xobj.SSelectionFcn),1) 
        OpenCossan.cossanDisp(strcat('** Crossover function           : ',Xobj.SCrossoverFcn),1) 
        OpenCossan.cossanDisp(strcat('** Mutation function            : ',Xobj.SMutationFcn),1) 
        OpenCossan.cossanDisp(strcat('** Creation function            : ',Xobj.SCreationFcn),1) 
        OpenCossan.cossanDisp(strcat('** Population Size              : ',sprintf('%i',Xobj.NPopulationSize)),1) 
        OpenCossan.cossanDisp(strcat('** number of elite individuals  : ',sprintf('%i',Xobj.NEliteCount)),1) 
        OpenCossan.cossanDisp(strcat('** crossover fraction           : ',sprintf('%10.3e',Xobj.crossoverFraction)),1) 
        OpenCossan.cossanDisp(strcat('** mutation rate                : ',sprintf('%10.3e',Xobj.mutationRate)),1) 
    case 'BFGS'
       OpenCossan.cossanDisp(strcat('** Finite difference method    : ',Xobj.SfiniteDifferenceType),1) 
       OpenCossan.cossanDisp(strcat('** Perturbation used           : ',sprintf('%10.3e',Xobj.finiteDifferencePerturbation)),1) 
   
end

% Class Specific Termination Field
OpenCossan.cossanDisp('* Other Settings  ',2)
%% Other fields
              OpenCossan.cossanDisp(['** Scaling factor               : ' num2str(Xobj.scalingFactor)],2)
              OpenCossan.cossanDisp(['** penalty factor               : ' num2str(Xobj.penaltyFactor)],2)
if Xobj.Lintermediateresults
              OpenCossan.cossanDisp(['* Simulation Output stored in  : ' Xobj.SiterationFolder],2) 
end
    
