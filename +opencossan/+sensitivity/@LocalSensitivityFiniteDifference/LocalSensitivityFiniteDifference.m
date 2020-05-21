classdef LocalSensitivityFiniteDifference < opencossan.sensitivity.Sensitivity
    %LOCALSENSITIVITY Sensitivity Toolbox for COSSAN-X
    % This class contains the methods for performing local sensitivity
    % analysis based on finite difference. 
    % See also: https://cossan.co.uk/wiki/index.php/LocalFiniteDifferences@Sensitivity
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
        perturbation
        VreferencePoint
    end
        
    methods
        function Xobj=LocalSensitivityFiniteDifference(varargin)
            % OpenCossan This class defines the sensitivity object. It
            % contains the globlal parameters and settings.
            %
            % See also: http://cossan.co.uk/wiki/index.php/LocalFiniteDifferences@Sensitivity
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
            
            %% Process inputs
            for k=1:2:nargin
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'coutputnames' 'csoutputnames','coutputname','csoutputname'}
                        Xobj.OutputNames = varargin{k+1};
                    case {'cinputnames' 'csinputnames' }
                        Xobj.InputNames = varargin{k+1};
                    case {'sevaluatedobjectname'}
                        Xobj.Sevaluatedobjectname=varargin{k+1};
                    case {'lperformancefunction'}
                        Xobj.LperformanceFunction=varargin{k+1};
                    case {'xtarget','xmodel'}
                        Xmodel=varargin{k+1};
                    case {'cxtarget','cxmodel'}
                        Xmodel=varargin{k+1}{1};
                    case {'vreferencepoint'}
                        % Reference Point in PhysicalSpace
                        Xobj.VreferencePoint=varargin{k+1};
                    case {'perturbation'}
                        Xobj.perturbation=varargin{k+1};
                    otherwise
                        error('openCOSSAN:LocalSensitivityFiniteDifference',...
                            'The PropertyName %s is not allowed',varargin{k});
                end
            end
            
            if exist('Xmodel','var')
                Xobj=Xobj.addModel(Xmodel);
            end
            
        end % end of constructor
    end
    
    methods (Access=public)
        varargout=computeGradient(Xobj,varargin) % Perform Local Sensitivity (returning gradient)
        varargout=computeGradientStandardNormalSpace(Xobj,varargin) % Perform Local Sensitivity (returning gradient)
    end
    
    methods (Access=protected)
        varargout=doFiniteDifferences(Xobj)    % Core function for FD methods
    end
end

