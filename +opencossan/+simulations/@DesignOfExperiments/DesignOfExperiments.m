classdef DesignOfExperiments < opencossan.simulations.Simulations
    %DESIGNOFEXPERIMENTS Class definition
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@DesignOfExperiments
    %
    % Author: Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
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
    properties
        % Type of DOE
        DesignType(1,1) string {mustBeMember(DesignType, {...
            '2LevelFactorial', 'FullFactorial', 'BoxBehnken', 'CentralComposite', ...
            'UserDefined'})} = "2LevelFactorial";
        % Type of the Central-Composite Design
        CentralCompositeType(1,1) string {mustBeMember(CentralCompositeType, {...
            'faced', 'inscribed'})} = 'faced';
        % Matrix containing the coordinates of the input samples
        Factors
        % Parameter multiplied with the Factors matrix
        Perturbance(1,1) double {mustBePositive} = 1;
        % Parameter to use the current values of the DV's or not
        UseCurrentValues(1,1) logical = true;
        % Levels for the continous DVs (required only for FULLFACTORIAL)
        LevelValues = [];
    end
    
    methods
        
        function obj = DesignOfExperiments(varargin)
            %DESIGNOFEXPERIMENTS
            
            if nargin == 0
                super_args = {};
            else
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["designtype", "centralcompositetype", "factors", "perturbance", ...
                    "usecurrentvalues", "levelvalues"], {"2LevelFactorial", "faced", ...
                    [], 1, true, []}, varargin{:});
            end
            
            obj@opencossan.simulations.Simulations(super_args{:});
            
            if nargin > 0
                obj.DesignType = optional.designtype;
                obj.CentralCompositeType = optional.centralcompositetype;
                obj.Perturbance = optional.perturbance;
                obj.UseCurrentValues = optional.usecurrentvalues;
                
                if strcmp(obj.DesignType, "UserDefined")
                    assert(~isempty(optional.factors), 'OpenCossan:DesignOfExperiments', ...
                        "Must supply factors for 'UserDefined' design type.");
                    obj.Factors = optional.factors;
                end
                
                obj.LevelValues = optional.levelvalues;
            end
        end
        
        function computeFailureProbability(Xobj,~)
            error('openCOSSAN:DesignOfExperiments:DesignOfExperiments',...
                ['method computeFailureProbability not available for the ' class(Xobj) ' object \n'])
        end
    end
end
