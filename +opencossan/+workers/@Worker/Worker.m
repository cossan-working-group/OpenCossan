classdef Worker < opencossan.common.CossanObject
    %WORKERS Abstract class to define the COSSAN workers.
    %   The class worker provides a common interface for the Worker
    %   objects.
    %
    % See Also: http://cossan.co.uk/wiki/index.php/@Worker
    %
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
        OutputNames cell {opencossan.common.utilities.isunique(OutputNames)}
        InputNames  cell {opencossan.common.utilities.isunique(InputNames)} 
        IsKeepSimulationFiles(1,1) logical = false % Keep simulation files
    end
    
    methods (Abstract)
        % Evaluate the workerObject based on the realizations provided in a
        % Table object 
        TableOutput=evaluate(workerObject,TableInput);        
    end    
end

