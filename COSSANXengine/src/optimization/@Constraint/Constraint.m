classdef Constraint < Mio
    %CONSTRAIN The class Constrain defines the constrains for the
    %optimization problem.
    %   This class is a generalization of the Mio class
    
    properties (SetAccess=protected)
        Linequality=true % Flag to define whether a constrain is an
        % inequality (TRUE) or an equality (FALSE)
    end
    
    properties
        Lgradient=false     % Flag to estimate the gradient of the Objective fucntion
        perturbation=1e-3   % Perturbation values used to compute the gradient
        scaling=1           % Scaling parameter for the objective function
    end
    
    methods
        function Xobj= Constraint(varargin)
            % CONSTRAINT This constructor defines an object Constraint. It is a
            % sub-class of Mio and hinerite from this class all the properties
            % and methods. The only restriction is that it needs to have only 1 output.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@Constraint
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
            
            %% Preprocessing
            % Split user arguments
            CpropertyNames={'lgradient','perturbation','scaling','linequality'};
            
            Vindex=true(length(varargin),1);
            for k=1:2:length(varargin),
                if ismember(lower(varargin{k}),CpropertyNames)
                    Vindex(k:k+1)=false;
                end
            end
            
            CmioArguments=varargin(Vindex);
            CobjArguments=varargin(~Vindex);
            %% Reuse the Mio constructor
            Xobj=Xobj@Mio(CmioArguments{:});
            
            if nargin==0
                return % allow to create an empty object
            else
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
                        case {'linequality'}
                            Xobj.Linequality=CobjArguments{k+1};
                        otherwise
                            error('openCOSSAN:optimization:Constraint',...
                                'The Field name (%s) is not allowed',varargin{k});
                    end
                end
                
                %% Add values of the flag for the inequality
                
                % The constraint must have a single output
                assert(length(Xobj.Coutputnames)==1,...
                    'openCOSSAN:optimization:Constraint',...
                    'A single output (Coutputnames) must be defined');
            end
        end % constructor
        
        [Vin,Veq,MinGrad,MeqGrad] =evaluate(Xobj,varargin) % Evaluate constrains
        
        
        %         function Nconstrains=get.Nconstrains(Xobj)
        %             Nconstrains=length(Xobj.Linequality);
        %         end
        %
        %         function NinequalityConstrains=get.NinequalityConstrains(Xobj)
        %             NinequalityConstrains=sum(Xobj.Linequality);
        %         end
        %
        %         function NequalityConstrains=get.NequalityConstrains(Xobj)
        %             NequalityConstrains=sum(~Xobj.Linequality);
        %         end
        
    end
end
