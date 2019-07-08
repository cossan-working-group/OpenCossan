classdef LocalSensitivityMeasures < Gradient
    %LocalSensitivityMeasures class
    % This class defines the local sensitivity measures output object. It can be constructed
    % automatically invoking the static methods
    % Sensitivity.localMonteCarlo and Sensitivity.localFiniteDiffences
    
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
    properties (SetAccess = protected)
        totalVariance % total variance of the outputs
    end
    
    properties (Dependent=true, SetAccess = protected)
        VnormalizedMeasures % values of the sensitivity measures
        Lnormalized % flag to identify wheater of not the sensitivity measures have been normalized
    end
    
    methods
        
        function Xobj=LocalSensitivityMeasures(varargin)
            % LocalSensitivityMeasures
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@LocalSensitivityMeasures
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
            
            %% Create an empty object
            if nargin==0
                return
            end
            
            %% Validate input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Process inputs parameters
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'vmeasures'} % Not normalized values
                        Xobj.Vgradient=varargin{k+1};
                    case {'nfunctionevaluation','nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'vreferencepoint'}
                        Xobj.VreferencePoint=varargin{k+1};
                    case {'sfunctionname'}
                        Xobj.SfunctionName=varargin{k+1};
                    case {'cnames','cmembers'}
                        assert(length(unique(varargin{k+1}))==length(varargin{k+1}), ...
                            'openCOSSAN:outputs:LocalSensitivityMeasures',...
                            ['The names after the PropertyName ' varargin{k} ' must be unique']);
                        Xobj.Cnames=varargin{k+1};
                    case {'totalvariance'}
                        Xobj.totalVariance=varargin{k+1};
                    otherwise
                        error('openCOSSAN:outputs:LocalSensitivityMeasures',...
                            ['Field name (' varargin{k} ') not allowed']);
                end
            end
            
            
            %% Check the passed inputs
            assert(~isempty (Xobj.Vgradient), ...
                'openCOSSAN:outputs:LocalSensitivityMeasures',...
                'The values of the importance measure must be defined');
            
            assert(length(Xobj.Vgradient)==length(Xobj.Cnames), ...
                'openCOSSAN:outputs:LocalSensitivityMeasures',...
                ['The length of the field name Vmeasures (' ...
                num2str(length(Xobj.Vgradient))  ') must be equal to ' ...
                'length of the field Cnames ' ...
                num2str(length(Xobj.Cnames)) ]);
            
            assert(~isempty(Xobj.VreferencePoint), ...
                'openCOSSAN:outputs:LocalSensitivityMeasures',...
                'It is necessary to specify the reference point')
            
            assert(length(Xobj.VreferencePoint)==length(Xobj.Vgradient), ...
                'openCOSSAN:outputs:LocalSensitivityMeasures',...
                ['Length of the referencePoint (' num2str(length(Xobj.VreferencePoint)) ...
                ' must be equal to the length of the sensitivity measures (' ...
                num2str(length(Xobj.Vgradient)) ')'])
            
        end % end constructor
        
        % show summary of the object
        display(Xobj)
        
        % The following method are inherited from the Gradient object
        % [varargout]=plotComponents(Xobj,varargin) % Show the components in a bar figure
        % [varargout]=plotPie(Xobj,varargin) % Show the components in a pie char
        
        
        % Dependent properties
        function VnormalizedMeasures = get.VnormalizedMeasures(Xobj)
            if Xobj.Lnormalized
                VnormalizedMeasures=Xobj.Vgradient/Xobj.totalVariance;
            else
                VnormalizedMeasures=[];
            end
        end
        
        % Dependent properties
        function Lnormalized = get.Lnormalized(Xobj)
            if isempty(Xobj.totalVariance)
                Lnormalized=false;
            else
                Lnormalized=true;
            end
        end
        
    end
    
end

