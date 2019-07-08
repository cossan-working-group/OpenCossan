classdef GlobalSensitivityGivenData < Sensitivity
    %GLOBALSENSITIVITYGIVENDATA Global Sensitivity based on Sobol' indices
    %from exising simulation data
    
    % This is a class for global sensitivity analysis based of Sobol'
    % indices
    %
    % See also: GlobalSensitivityGivenData
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
    
    properties (SetAccess=public,GetAccess=public)
        Nbootstrap=100;
        Xsimulator
        XsimulationData     % Store simulationData for computing Sobol' indices using GivenData method
        Nfrequency          % Required by the Given Data method 
    end
    
    
    methods
        function Xobj=GlobalSensitivityGivenData(varargin)
            %GlobalSensitivitySobol
            % This is the constructor for the GlobalSensitivitySobol object.
            %
            % See also: GlobalSensitivitySobol GlobalSensitivitySobol
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
            
            %% Check inputs
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Process inputs
            for k=1:2:nargin
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'coutputnames' 'csoutputnames' }
                        Xobj.Coutputnames=varargin{k+1};
                    case {'cinputnames' 'csinputnames' }
                        Xobj.Cinputnames=varargin{k+1};
                    case {'nbootstrap'}
                        Xobj.Nbootstrap=varargin{k+1};
                     case {'nfrequency'}
                        Xobj.Nfrequency=varargin{k+1};
                    case {'xsimulationdata'}
                        Xobj.XsimulationData=varargin{k+1};
                    otherwise
                        error('openCOSSAN:GlobalSensitivityGivenData',...
                            'The PropertyName %s is not allowed',varargin{k});
                end
            end
                        
            % Check that the input and output names have been provided
            
            assert(~isempty(Xobj.Coutputnames),...
                    'OpenCossan:GlobalSensitivityGivenData:wrongOutputNames',...
                    'The Coutputnames must be provided')
            assert(~isempty(Xobj.Cinputnames),...
                    'OpenCossan:GlobalSensitivityGivenData:wrongOutputNames',...
                    'The Cinputnames must be provided')
                
        end % end of constructor
    end
    
    methods (Access=private)
        varargout=useRandomSamples(Xobj); % Use Elmar's method Given Data Sensitivity
    end
    
    
    
end

