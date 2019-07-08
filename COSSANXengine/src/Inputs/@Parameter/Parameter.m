classdef Parameter
    %Parameter  This class define an Object of type Parameter
    %
    %   The Parameter object is intended for containing numerical
    %   values. A Parameter object can be then attached to an Input
    %   object.
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@Parameter
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
    
    properties % Public access
        Sdescription       % Description of the parameter
        value              % value(s) of the parameter
    end
    
    properties (Dependent)
        Nelements          % Number of elements defined in the Parameter
    end
    
    methods
        Xo    = get(Xobj,varargin)    %This method allows retrieving properties from the object
        Xo    = set(Xobj,varargin)    %This method allows setting properties of the object
        display(Xobj)                 %This method shows the summary of the Xobj
        
        %% Constructor
        
        function Xpar   = Parameter(varargin)
            % PARAMETER This method define an object of type Parameter
            %
            % Please refer to the Reference Manual for more information
            % See also:
            % https://cossan.co.uk/wiki/index.php/@Parameter
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
            
            if nargin==0
                % Create an empty object
                return
            end
            
            % Process Inputs
            OpenCossan.validateCossanInputs(varargin{:});
            LvalueSet=false;
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xpar.Sdescription=varargin{k+1};
                    case {'value','vvalue','mvalue','vvalues','mvalues'}
                        assert(~LvalueSet,'openCOSSAN:Parameter:MultipleValueDefinition',...
                            'It is not possible to set the parameter values using more then one method')
                            
                        LvalueSet=true;
                        Xpar.value=varargin{k+1};                        
                    case {'cvalue','cvalues'}
                        Xpar.value=cell2mat(varargin{k+1});
                    otherwise
                        error('openCOSSAN:Parameter:wrongArgument',...
                             'PropertyName %s is not valid ', varargin{k});
                end
            end
            
            assert(~isempty(Xpar.value),...
                'openCOSSAN:Parameter',...
                'Field values can not be empty');
        end     %of constructor
        
        % method for dependent field
        
        function Nelements=get.Nelements(Xobj)
            Nelements=numel(Xobj.value);
        end
    end     %of methods
    
end     %of class definition
