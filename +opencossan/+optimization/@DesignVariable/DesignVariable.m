classdef DesignVariable
    %DesignVariable    object containing a design variable
    %
    % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@DesignVariable
    %
    % $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
    % Author: Edoardo Patelli and Pierre Beaurepiere
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
    
    properties % Public properties
        Sdescription         % Description of the design variable
        value                % Current value of the design variable
        lowerBound = -Inf    % Lower bound for continous design variable
        upperBound = +Inf    % Upper bound for continous design variable
        Vsupport             % Vector of valid support points for discrete design variable
    end
    
    properties (Dependent = true)
        Ldiscrete           % Flag for discrete/continuos Design variable
    end
    
    %%  Methods
    methods
        
        Vs = sample(Xobj,varargin)    % This method generate samples of the DesignVariable object.
        
        Vs = getValue(Xobj,x)         % Return the value corresponding to a specific percentile
        Vs = getPercentile(Xobj,x)    % return the percentile of the value
        
        function Xobj   = DesignVariable(varargin)
            % DesignVariable
            % DesignVariable is a class that allows to define the so-called Design
            % Variables. These objects are then used by teh Optimization toolbox and
            % the Design of Variable
            %
            % See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@DesignVariable
            
            %   Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            
            if nargin==0
                return
            end
            
            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'value'}
                        Xobj.value=varargin{k+1};
                    case {'vsupport','vvalues'}
                        Xobj.Vsupport=varargin{k+1};
                        Xobj.lowerBound=min(Xobj.Vsupport);
                        Xobj.upperBound=max(Xobj.Vsupport);
                    case {'minvalue','lowerbound'}
                        Xobj.lowerBound=varargin{k+1};
                    case {'maxvalue','upperbound'}
                        Xobj.upperBound=varargin{k+1};
                    otherwise
                        error('openCOSSAN:DesignVariable',...
                            'Property name "%s" is not valid', varargin{k});
                end
            end
            
            %% TO BE COMMENTED
            if ~isempty(Xobj.lowerBound) && ~isempty(Xobj.upperBound)
                if isempty(Xobj.value) && isempty(Xobj.Vsupport)
                    Xobj.value=(Xobj.upperBound+Xobj.lowerBound)/2;
                end
                
            end
            
            if isempty(Xobj.Vsupport)
                % Check validity of the constructor
                assert(~isempty(Xobj.value),...
                    'openCOSSAN:DesignVariable',...
                    'Please specify the value of the Design Variable');
            else
                if isempty(Xobj.value)
                    Xobj.value=Xobj.Vsupport(1);
                    warning('openCOSSAN:DesignVariable',...
                        'Since no current value is assigned to the DV, the smallest support point is assumed as the DV value ');
                end
            end
            if ~isempty(Xobj.Vsupport) && isempty(intersect(Xobj.value,Xobj.Vsupport))
                warning('openCOSSAN:DesignOfExperiments:DesignOfExperiments',...
                    'Assigned value is not within the support points, therefore the minimum supportvalue will be assigned as current value')
                Xobj.value=Xobj.Vsupport(1);
            end
            if Xobj.lowerBound > Xobj.upperBound
                error('openCOSSAN:DesignOfExperiments:DesignOfExperiments',...
                    'Lower Bound cannot be higher than Upper Bound')
            end
            
            assert(Xobj.value>=Xobj.lowerBound && Xobj.value<=Xobj.upperBound,...
                'openCOSSAN:DesignVariable:outOfBound','current value can not be outside the bounds of the DesignVariable')
        end     %of constructor
        
        
        % Dependent properties
        function Ldiscrete=get.Ldiscrete(Xobj)
            if length(Xobj.Vsupport)>1
                Ldiscrete = true;
            else
                Ldiscrete = false;
            end
        end
        
        
        
        
        
    end     %of methods
    
end     %of class definition
