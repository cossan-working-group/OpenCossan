classdef Gradient
    %GRADIENT object
    % This class defines the gradient output object. It can be constructed
    % automatically invoking the  methods computeGradient and
    % computeGradientStandardNormalSpace of the object
    % LocalSensitivityFiniteDifference and LocalSensitivityMonteCarlo
    %
    % See also: http://cossan.co.uk/wiki/index.php/@Gradient
    %
    % $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
    % $Author: Edoardo-Patelli$
    
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
        Cnames              % name of the components of the Vgradient
        Vgradient           % Values of the components
        VreferencePoint     % Reference Point, i.e. point where the gradient is computed
        Nsamples            % Store the number of funtion evaluation (samples)
        SfunctionName       % Name of the quantity of interest (output factor)
        LstandardNormalSpace = false; % Flag to discriminate whether the
        % gradient has been evaluated in the
        % physical space or in the standard normal space
    end
    
    properties
        Sdescription % description of the object
    end
    
    properties (Dependent=true, SetAccess = protected)
        Valpha              % Important direction
    end
    
    methods
        
        function Xobj=Gradient(varargin)
            % Gradient Constructor of the Gradient object
            
            %% Create an empty object
            if nargin==0
                return
            end
            %% Validate input arguments
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'vgradient'}
                        Xobj.Vgradient=varargin{k+1};
                    case {'nfunctionevaluation','nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'vreferencepoint'}
                        Xobj.VreferencePoint=varargin{k+1};
                    case {'sfunctionname'}
                        Xobj.SfunctionName=varargin{k+1};
                    case {'cnames','cmembers'}
                        Xobj.Cnames=varargin{k+1};
                    case {'lstandardnormalspace','lsns'}
                        Xobj.LstandardNormalSpace=varargin{k+1};
                    otherwise
                        error('openCOSSAN:outputs:Gradient',...
                            ['Field name (' varargin{k} ') not allowed']);
                end
            end
            
            %% Check the passed inputs
            if isempty (Xobj.Vgradient)
                error('openCOSSAN:outputs:Gradient',...
                    'The components of the gradient must be defined');
            elseif length(Xobj.Vgradient)~=length(Xobj.Cnames)
                error('openCOSSAN:outputs:Gradient',...
                    ['The length of the field name Vgradient (' ...
                    num2str(length(Xobj.Vgradient))  ') must be equal to ' ...
                    'length of the field Cnames ' ...
                    num2str(length(Xobj.Cnames)) ]);
            end
            
            if isempty(Xobj.VreferencePoint)
                Xobj.VreferencePoint=zeros(size(Xobj.Vgradient));
            end
            
        end
        
        % show summary of the object
        display(Xobj)
        
        [varargout]=plotComponents(Xobj,varargin) % Show the components in a bar figure
        
        [varargout]=plotPie(Xobj,varargin) % Show the components in a pie char
        %Other methods go here
        
        % Dependent properties
        function Valpha = get.Valpha(Xobj)
            Valpha = Xobj.Vgradient/norm(Xobj.Vgradient);
        end
        
    end
    
end

