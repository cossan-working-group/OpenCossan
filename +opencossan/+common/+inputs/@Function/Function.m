classdef Function < opencossan.common.CossanObject
    %FUNCTION This class defines an Object of type Function
    %
    %   The class Function is designed to provide a means for
    %   defining simple functions within input quantities in OpenCossan. 
    %   In other words, it provides a mathematical abstraction between the 
    %   values generated from different input objects.
    %
    %   The object Function provides two important capabilities, i.e.:
    %     (1) When evaluating a Function object, it is possible to retrieve
    %     objects involved in the definition of the function from the
    %     workspace.
    %     (2) It is possible to define nested functions
    %    These capabilities are exemplified in the corresponding tutorials
    %
    %    For more detailed information, see <https://cossan.co.uk/wiki/index.php/@Function>.
    %
    %
    %    FUNCTION Properties:
    %       Expression - Value(s) of the parameter.
    %       Nelements - Number of elements defined in value.
    
    % ===================================================================== 
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
    
    
    properties % Public access
        
    end
    
    properties (SetAccess=protected)
        Expression(1,1) string    % string containing the expression to be evaluated
    end
    
    properties (Dependent)
        InputNames(:,1) string  % variables required to evaluate the function
    end
    
    properties (SetAccess=private, Hidden=true)
        Identifier='<&([^&<>+-*\/]*)&>'  % interal variable used by the
        % regular expression adopted to find the identifiers
        Index(:,1)      %index when only some elements of an array are used
        Tokens{}          % identified Token
    end
    
    methods
        function obj= Function(varargin)
            %FUNCTION The class Function is designed to provide a means for
            %defining functions within Cossan-X. In other words, it provides a
            %mathematical abstraction between different components of Cossan-X.
            %
            %The object Function provides two important capabilities, i.e.:
            %   (1) When evaluating a Function object, it is possible to retrieve
            %   objects involved in the definition of the function from the
            %   workspace.
            %   (2) It is possible to define nested functions
            %These capabilities are exemplified in the corresponding tutorials
            %
            %   MANDATORY ARGUMENTS
            %
            %
            %   OPTIONAL ARGUMENTS
            %
            %   - Sexpression:  a string containing the expression to be evaluated. The
            %   characters show in bold are used to delimitate the object name:
            %               <& ObjectName &>
            %   - CUseObject: this field is used to define objects that should
            %   be used for evaluating the function numerically. The
            %   information associated with this field is a cell that contains
            %   in the first position the name of the object/variable (as a
            %   string) and in the second position, the actual object. Note
            %   that more than one 'CUseObject ' may be defined when creating a
            %   function
            %
            %   USAGE:
            %
            %   Xfun  = Function('Sdescription','My first Xfunction', ...
            %                                'Sexpression','<&Xobj1&>*<&Xobj2&>+5')
            %
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
  

            %% Process inputs
            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.common.inputs.Function';
                
                % Use default values
                p.addParameter('Description',obj.Description);
                p.addParameter('Expression',obj.Expression);
                
                p.parse(varargin{:});
                
                % Assign input to objects properties
                obj.Description = p.Results.Description;
                obj.Expression = p.Results.Expression;
            end            
            
            %% Process inputs
            if nargin == 0
                % Create empty object
                return
            else
                % process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.common.inputs.Function';
                
                % Use default values
                p.addParameter('Description',obj.Description);
                p.addParameter('Expression',obj.Expression);
                
                p.parse(varargin{:});
                
                % Assign input to objects properties
                obj.Description = p.Results.Description;
                obj.Expression = p.Results.Expression;
            end

        end % constructor
        
        %****************************************************************
        %   This method sets up the field "Sexpression"
        %****************************************************************
        function obj = set.Expression(obj,Sexpression)
            obj.Expression = Sexpression;
            obj=findToken(obj);
        end
    end
    
    methods (Access=protected)
        %****************************************************************
        %   Method for finding tokens of object Function
        %****************************************************************
        function obj=findToken(obj)
            token = regexp(obj.Expression,obj.Identifier,'tokens');   %find tokens in Sexpression
            
            for i=1:length(token)
                a=regexp(token{i},'(\w+)','tokens');
                
                if length(a{1})==1
                    obj.Tokens{i} = a{1}{1};
                    obj.Index(i) = NaN;
                elseif length(a{1})==2
                    obj.Tokens{i} = a{1}{1};
                    obj.Index(i) = str2double(a{1}{2});
                    
                else
                    error('openCOSSAN:Function',...
                        ['Bad token syntax, only one index must be given as an input in ' token{i}{1}]);
                end
            end
            
            
        end % get Tokens
        
    end % methods
    
end

