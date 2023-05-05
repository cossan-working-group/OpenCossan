classdef GlobalSensitivityRandomBalanceDesign < opencossan.sensitivity.Sensitivity
    %GLOBALSENSITIVITYRANDOMBALANCEDESIGN Sensitivity Toolbox for
    %OpenCossan
    
    % This is a class for calculation gradient and local sensitivity
    % indices adopting Monte Carlo simulation
    % See also: https://cossan.co.uk/wiki/
    %
    % Author: Edoardo Patelli
    % Cossan Working Group 
    % Email address: openengine@cossan.co.uk
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
        Nbootstrap {mustBeNumeric} = 100;
        Nsamples {mustBeNumeric} = 100;
        Nharmonics {mustBeNumeric} = 6;
    end
    
    methods
        function Xobj=GlobalSensitivityRandomBalanceDesign(varargin)
            %GLOBALSENSITIVITYRANDOMBALANCEDESIGN
            % This is a class for calculation gradient and local sensitivity
            % indices adopting Monte Carlo simulation
            % See also: https://cossan.co.uk/wiki/index.php/@GlobalSensitivityRandomBalanceDesign
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
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            %% Process inputs
            for k=1:2:nargin
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'coutputnames' 'csoutputnames' }
                        Xobj.Coutputnames=varargin{k+1};
                    case {'cinputnames' 'csinputnames' }
                        Xobj.Cinputnames=varargin{k+1};
                    case {'lperformancefunction'}
                        Xobj.LperformanceFunction=varargin{k+1};
                    case {'xtarget','xmodel'}
                        Xmodel=varargin{k+1};
                    case {'cxtarget','cxmodel'}
                        Xmodel=varargin{k+1}{1};
                    case {'nbootstrap'}
                        Xobj.Nbootstrap=varargin{k+1};
                    case {'nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'nharmonics'}
                        Xobj.Nharmonics=varargin{k+1};
                    case {'sevaluatedobjectname'}
                        Xobj.Sevaluatedobjectname=varargin{k+1};
                    otherwise
                        error('openCOSSAN:LocalSensitivityMonteCarlo',...
                            'The PropertyName %s is not allowed',varargin{k});
                end
            end
            
            if exist('Xmodel','var')
                Xobj=Xobj.addModel(Xmodel);
            end
            
        end % end of constructor
    end
    
    methods (Access=protected)
        varargout=doMonteCarlo(Xobj)    % Core function for MC methods
    end
end

