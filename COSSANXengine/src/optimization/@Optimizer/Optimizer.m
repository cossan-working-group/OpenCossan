classdef Optimizer
    %OPTIMIZER    Abstract class Optimizer
    %
    %   Optimizer:  This is the abstract class Optimizer; this class is
    %   intented to be a super class, grouping all different optimization
    %   algorithms available in Cossan-X.
    %
    % See Also: TutorialOptimizer
    %
    % Author: Edoardo Patelli
    % Website: http://www.cossan.co.uk
    

%{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.
    
    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}
    
    %% Properties of the object
    properties % Public access
        Sdescription                % Description of the object
        Nmax   = Inf                % Maximum number of model evaluations
        NmaxFunctions  = Inf        % Maximum number of function evaluations
        NmaxIterations = Inf        % Maximum number of iterations
        objectiveLimit=-Inf         % Minimum objective function value desired
        timeout = Inf               % Maximum execution time
        toleranceObjectiveFunction = 1e-6     %Termination tolerance on the value of the objective function.
        toleranceConstraint        = 0.001 %Termination tolerance on the constrains violation.
        toleranceDesignVariables   = 0.001 %Termination tolerance on the design variable vector
        Lintermediateresults=true    % save SimulationData object after each iteration
        scalingFactor           = 1 % scale objective function
        scalingFactorConstraints =1 % scaling factor for Constraints 
        penaltyFactor          = 100 % for constraint
        XjobManager                 % Job Manager object
        XrandomNumberGenerator      % field containing RandStream object for generating random numbers
    end
    
    properties (Dependent = true, SetAccess = protected)
        SiterationName  % Define the name of the folder used to store intermediated results
    end
    
    properties (Hidden, SetAccess = protected)
        SiterationFileNames='SimulationData_iteration_' % Define the name of the
        SiterationFolder=[];
        % intermediated results
        initialLaptime     % Store the initial laptime number of the optimization
        iIterations = 0;   % Number of iterations processed
    end
    
    %% Methods of the class
    methods (Abstract)
        Xo    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
    end
    
    methods
        display(Xobj)                 %This method shows the summary of the Xobj
        
        function SiterationName = get.SiterationName(Xobj)
            SiterationName =  [Xobj.SiterationFileNames ...
                num2str(Xobj.iIterations) '_(' class(Xobj) ')'];
        end % Modulus get method
        
        [Ldone,Sflag]=checkTermination(Xobj,Xresults) % Check the termination criteria
        
        Lstop=outputFunctionOptimiser(Xobj,x,optimValues,state)        
    end
    
    methods (Access=protected)
        XRandomNumberGenerator = initializeUserDefinedRandomNumberGenerator(Xobj)
        exportResults(Xobj,varargin)  % This method is used to export the SimulationData
        [Xobj, Xinput]=initializeOptimizer(Xobj,Xtarget)
    end
    
end
