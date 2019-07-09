classdef ObjectiveFunction < opencossan.workers.Mio
    %OBJECTIVEFUNCTION The class ObjectiveFunction define the objective
    %function for the optimization problems
    %   This class is a generalization of the Mio class
    
    properties
        Lgradient=false     % Flag to estimate the gradient of the Objective fucntion
        perturbation=1e-3   % Perturbation values used to compute the gradient
        scaling=1           % Scaling parameter for the objective function
    end
    
    methods
        function Xobj= ObjectiveFunction(varargin)
            % ObjectiveFunction constructor.  This method create an object used to compute the
            % objective function for the optiumization toolbox.
            % It requires the same input arguments of a MIO object. The only
            % restriction is that it needs to have only 1 output.
            %
            %
            % See also: https://cossan.co.uk/wiki/index.php/@ObjectiveFunction
            %
            % Author: Edoardo Patelli and Marco de Angelis
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
            
            %% Preprocessing
            % Split user arguments
            CpropertyNames={'lgradient','perturbation','scaling','lmaximise'};
            
            Vindex=true(length(varargin),1);
            for k=1:2:length(varargin),
                if ismember(lower(varargin{k}),CpropertyNames)
                    Vindex(k:k+1)=false;
                end
            end
            
            CmioArguments=varargin(Vindex);
            CobjArguments=varargin(~Vindex);
            %% Reuse the Mio constructor
            Xobj=Xobj@opencossan.workers.Mio(CmioArguments{:});
            
            if nargin==0
                return % allow to create an empty object
            end
            %% PostProcessing
            
            % Set parameters defined by the user
            for k=1:2:length(CobjArguments),
                switch lower(CobjArguments{k})
                    case {'lgradient'}
                        Xobj.Lgradient=CobjArguments{k+1};
                    case {'perturbation'}
                        Xobj.perturbation=CobjArguments{k+1};
                    case {'scaling'}
                        Xobj.scaling=CobjArguments{k+1};
                    otherwise
                        error('openCOSSAN:optimization:ObjectiveFunction',...
                            'The Field name (%s) is not allowed',CobjArguments{k});
                end
            end
            
            % The objective function must have a single output
            assert(length(Xobj.OutputNames)==1,...
                'openCOSSAN:optimization:ObjectiveFunction',...
                'A single output (OutputNames) must be defined');
            
            
        end % constructor
        
        % Other methods
        [Vfobj,Vdfobj] = evaluate(Xobj,varargin) % Evaluate the objective function
    end
    
end

