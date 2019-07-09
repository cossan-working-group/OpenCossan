classdef CovarianceFunction < opencossan.workers.Mio
    %COVARIANCEFUNCTION This class defines the covariance function for a
    %stochastic process. 
    %
    % See also OPENCOSSAN.WORKERS OPENCOSSAN.WORKERS.MIO
    
    % This file is part of *OpenCossan*: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % *OpenCossan* is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    % You should have received a copy of the GNU General Public License
    % along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    methods
        function Xobj= CovarianceFunction(varargin)
            
            % Call constructor of opencossan.workers.Mio
            
            Xobj = Xobj@opencossan.workers.Mio(varargin{:});
            
            if nargin==0
                return;
            end
            
            %% Check inputs
            
            % The objective function must have a single output
            assert(numel(Xobj.OutputNames)==1,...
                'OpenCossan:CovarianceFunction:wrongNumberOfOutputs',...
                'A single output (OutputNames) must be defined');
            if isempty(Xobj.InputNames)
                Xobj.InputNames={'x_1' 'x_2'};
            else
            % The objective function must have two inputs
            assert(numel(Xobj.InputNames)==2,...
                'OpenCossan:CovarianceFunction:wrongNumberOfInputs',...
                'Two input names (InputNames) must be defined');
            end
        end
        
        % The method compute evaluate the CovarianceFunction using arrays
        % and not Tables.  
        MatrixOutput=compute(workerObject,MatrixInput);
    end
    
end

