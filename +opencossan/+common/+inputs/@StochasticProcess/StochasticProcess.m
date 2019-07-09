classdef StochasticProcess
    %STOCHASTICPROCESS The class StochasticProcess is used to define a random
    %process (or a random field) as a collection of random variables and used to
    %represent the evolution of some random value, or system, over time or space    %
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@StochasticProcess
    %
    % Author: Edoardo Patelli, Matteo Broggi
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
        Sdescription              % descriptions of the object
    end
    
    properties (SetAccess=private)
        Sdistribution='normal'          % distribution type
        CScoordinateNames               % name of the coordinates
        CScoordinateUnits               % units of the coordinates
        Mcoord                          % coordinates at which samples StochaticProcess are evaluated
        Vmean                           % mean values
        Xcovariancefunction             % CovarianceFunction object
        Mcovariance                     % Covariance Matrix
        Lhomogeneous = false            % flag whether stochastic process is homogeneous
        McovarianceEigenvectors         % Kept eigenvectors of covariance matrix (for KL-decomposition)
        VcovarianceEigenvalues          % Kept eigenvalues of covariance matrix (for KL-decomposition)
    end
    
    properties (Dependent)
        Lequallyspaced                  % Check if the grid points are equally spaced
        Ndimensions                     % Dimension of the Sotchastic Process
    end
    
    methods
        function Xobj=StochasticProcess(varargin)
            %STOCHASTICPROCESS The class StochasticProcess is used to define a random
            %process (or a random field) as a collection of random variables and used to
            %represent the evolution of some random value, or system, over time or space    %
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@StochasticProcess
            %
            % Author: Edoardo Patelli, Matteo Broggi
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
            
            import opencossan.common.utilities.*
            %% Process inputs
            %
            if nargin==0
                return %% Allow to generate an empty StochasticProcess object
            else
                opencossan.OpenCossan.validateCossanInputs(varargin{:});
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sdistribution'}
                        Xobj.Sdistribution=varargin{k+1};
                    case {'vmean','mean'}
                        Xobj.Vmean=varargin{k+1};
                    case {'cscoordinatenames'}
                        Xobj.CScoordinateNames = varargin{k+1};
                    case {'cscoordinateunits'}
                        Xobj.CScoordinateUnits = varargin{k+1};
                    case {'mcoord','vcoord'}
                        Xobj.Mcoord=varargin{k+1};
                    case {'xcovariancefunction'}
                        Xobj.Xcovariancefunction=varargin{k+1};
                        assert(isa(Xobj.Xcovariancefunction,'opencossan.common.inputs.CovarianceFunction'),'openCOSSAN:StochasticProcess:checkCovarianceFunction',...
                    'an object of class CovarianceFunction is expected. Provided object of class: %s', class(Xobj.Xcovariancefunction));
                    case {'cxcovariancefunction'}
                        Xobj.Xcovariancefunction=varargin{k+1}{1};
                       assert(isa(Xobj.Xcovariancefunction,'opencossan.common.inputs.CovarianceFunction'),'openCOSSAN:StochasticProcess:checkCovarianceFunction',...
                    'an object of class CovarianceFunction is expected. Provided object of class: %s', class(Xobj.Xcovariancefunction));
                    case {'mlbcovariance'}
                        % The GUI provided only the lower bottom part of the
                        % matrix
                        Xobj.Mcovariance=varargin{k+1};
                        % generate the upper triangle of the matrix
                        MupperTriangle=Xobj.Mcovariance';
                        % remove the diagonal
                        MupperTriangle(logical(eye(size(MupperTriangle))))=0;
                        % assemble full covariance
                        Xobj.Mcovariance=Xobj.Mcovariance+MupperTriangle;
                    case {'mcovariance'}
                        Xobj.Mcovariance=varargin{k+1};
                    case {'lhomogeneous'}
                        Xobj.Lhomogeneous=varargin{k+1};
                    case {'mcovarianceeigenvectors'}
                        Xobj.McovarianceEigenvectors=varargin{k+1};
                    case {'vcovarianceeigenvalues'}
                        Xobj.VcovarianceEigenvalues=varargin{k+1};
                    otherwise
                        error('openCOSSAN:StochasticProcess:StochasticProcess',...
                            'Field name %s is not allowed',varargin{k});
                end
            end
            
            % check for mandatory inputs
            assert(~isempty(Xobj.Mcoord),...
                'openCOSSAN:StochasticProcess:StochasticProcess',...
                'It is necessary to specify the matrix of the coordinates Mcoord')
            
            
            % input argument checks
            if length(Xobj.Vmean)==1
                Xobj.Vmean=Xobj.Vmean*ones(1,size(Xobj.Mcoord,2));
            end
            
            % assign default coordinate names
            if isempty(Xobj.CScoordinateNames)
                Xobj.CScoordinateNames = cell(1,Xobj.Ndimensions);
                for idim=1:Xobj.Ndimensions
                    Xobj.CScoordinateNames{1} = strcat('Coordinate',num2str(idim));
                end
            end
            
            % assign default coordinate units
            if isempty(Xobj.CScoordinateUnits)
                Xobj.CScoordinateUnits = cell(1,Xobj.Ndimensions);
                Xobj.CScoordinateUnits(:) = {''};
            end
            
            assert(length(Xobj.Vmean)== size(Xobj.Mcoord,2), ...
                'openCOSSAN:StochasticProcess:StochasticProcess:WrongMeanCoordinate',...
                'Length of mean vector (%d) and no. of columns of Mcoord (%d) are not the same',...
                length(Xobj.Vmean), size(Xobj.Mcoord,2));
            
            assert(length(Xobj.CScoordinateNames)==size(Xobj.Mcoord,1),...
                'openCOSSAN:StochasticProcess:StochasticProcess',...
                'The dimension of the coordinates (%d) names and the number of rows Mcoord (%d) are not the same',...
                length(Xobj.CScoordinateNames), size(Xobj.Mcoord,1))
            
            if ~isempty(Xobj.Mcovariance)
                if size(Xobj.Mcovariance,1)~=size(Xobj.Mcovariance,2) || ...
                        size(Xobj.Mcovariance,1)~=size(Xobj.Mcoord,2)
                    
                    error('openCOSSAN:StochasticProcess:StochasticProcess',...
                        'Size of covariance matrix not correct');
                end
            end
            
            if ~isempty(Xobj.Mcovariance) && ~isempty(Xobj.Xcovariancefunction)
                warning('openCOSSAN:StochasticProcess:StochasticProcess',...
                    'Covariance matrix passed, covariance function will be ignored');
            end
            
            Xobj=checkDistribution(Xobj);
        end % end constructor
        
        %% Depent fields
        function Lequallyspaced=get.Lequallyspaced(Xobj)
            Lequallyspaced = opencossan.common.utilities.isequallyspaced(Xobj.Mcoord);
        end
        
        function Ndimensions = get.Ndimensions(Xobj)
            Ndimensions = size(Xobj.Mcoord,1);
        end
        
    end
    
    methods (Access=private)
        Xobj=checkDistribution(Xobj);
    end
    
    methods (Static)
        b=matvecprodHomogeneous(x,Vx,Xfun);
        b=matvecprodNonhomogeneous(x,Vx,Xfun);
    end
    
end

