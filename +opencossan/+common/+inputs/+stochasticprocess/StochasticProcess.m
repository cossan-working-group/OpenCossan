classdef (Abstract) StochasticProcess < opencossan.workers.Mio
    %STOCHASTICPROCESS The abstract class defines a random process (or a
    %random field) to represent the evolution of some random value, or
    %system, over time or space     
    %
    % See also opencossan.workers.mio
    %
    % Author: Edoardo Patelli, Matteo Broggi
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of OpenCossan.  The open general purpose matlab
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
        Distribution(1,1) string ='normal'  % distribution type         
        CoordinateNames string              % name of the coordinates
        CoordinateUnits string              % units of the coordinates
        Coordinates double                  % coordinates at which samples 
                                            % StochaticProcess are evaluated 
        Mean                                % mean values
        CovarianceFunction(1,1) opencossan.common.inputs.stochasticprocess.CovarianceFunction    
                                            % CovarianceFunction object
        CovarianceMatrix double {issymmetric} % Covariance Matrix
        IsHomogeneous(1,1) logical = false  % flag whether stochastic process is homogeneous
    end
    
    properties (SetAccess=private)
        
    end
    
    properties (Dependent)
        IsEquallySpaced                     % Check if the grid points are equally spaced
        Ndimensions                         % Dimension of the Stochastic Process
    end
       
    methods
        
        [SampleObject, DataSeriesObject] = sample(Xobj,varargin)
        
        %% Depent fields
        function IsEquallySpaced=get.IsEquallySpaced(Xobj)
            IsEquallySpaced = opencossan.common.utilities.isequallyspaced(Xobj.Coordinates);
        end
        
        function Ndimensions = get.Ndimensions(Xobj)
            Ndimensions = size(Xobj.Coordinates,1);
        end        
    end
end

