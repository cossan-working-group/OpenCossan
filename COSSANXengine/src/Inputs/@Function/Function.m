classdef Function
    % FUNCTION The class Function is designed to provide a means for
    % defining functions within Cossan-X. In other words, it provides a
    % mathematical abstraction between different input components of Cossan-X.
    %
    %The object Function provides two important capabilities, i.e.:
    %   (1) When evaluating a Function object, it is possible to retrieve
    %   objects involved in the definition of the function from the
    %   workspace.
    %   (2) It is possible to define nested functions
    %These capabilities are exemplified in the corresponding tutorials
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
        Sdescription        % Description of the performance function
        Sfield              % Out variable of the Function object
    end
    
    properties (SetAccess=protected)
        Sexpression     % string containing the expression to be evaluated
        Ctoken          % identified Token
    end
    
    properties (Dependent)
        Cinputnames     % variables required to evaluate the function
    end
    
    properties (SetAccess=private, Hidden=true)
        Sidentifier='<&([^&<>+-*\/]*)&>'  % interal variable used by the
        % regular expression adopted to find the identifiers
        Vindex      %index when only some elements of an array are used
    end
    
    methods
        function Xobj= Function(varargin)
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
            %   - Sdescription:     Description of the performance function
            %   - Sfield:           field (or variable name) to be extracted after
            %   evaluation of Sexpression
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
            %   Xfun1   = Function('Sdescription','objective function', ...
            %       'Sexpression','apply(<&Xobj1&>,<&Xobj2&>)','Sfield','out1';
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Set parameters
            for k=1:2:length(varargin),
                switch lower(varargin{k}),
                    case {'sdescription'} % Description of the object
                        Xobj.Sdescription   = varargin{k+1};
                    case {'sexpression'} % Expression to be evaluated
                        Xobj.Sexpression    = varargin{k+1};
                    otherwise
                        error('openCOSSAN:Function',...
                            'Property name %s is not allowed',varargin{k});
                end
            end
        end % constructor
        
        %****************************************************************
        %   This method evaluate the function using the values stored in
        %   the Samples object 
        %****************************************************************        
        Xo  = evaluate(Xobj,Xinput)
        
        %****************************************************************
        %   This method shows the summary of the Xobj
        %****************************************************************
        display(Xobj)
        
        %****************************************************************
        %   This method sets up the field "Sexpression"
        %****************************************************************
        function Xobj = set.Sexpression(Xobj,Sexpression)
            Xobj.Sexpression = Sexpression;
            Xobj=findToken(Xobj);
        end
        
        %****************************************************************
        %   Method to get members associated with object Function
        %****************************************************************
        varargout = getMembers(Xobj);
        
        function Cinputnames=get.Cinputnames(Xobj)
            if isempty(Xobj.Ctoken)
                Cinputnames={};
            else
                Ntoken=length(Xobj.Ctoken);
                Cinputnames=cell(Ntoken,1);
                for n=1:Ntoken
                    Cinputnames(n)=Xobj.Ctoken{n};
                end
            end
        end
        
    end
    
    methods (Access=protected)
        %****************************************************************
        %   Method for finding tokens of object Function
        %****************************************************************
        function Xobj=findToken(Xobj)
            token = regexp(Xobj.Sexpression,Xobj.Sidentifier,'tokens');   %find tokens in Sexpression
            
            for i=1:length(token)
                a=regexp(token{i},'(\w+)','tokens');
                
                if length(a{1})==1
                    Xobj.Ctoken{i} = a{1}{1};
                    Xobj.Vindex(i) = NaN;
                elseif length(a{1})==2
                    Xobj.Ctoken{i} = a{1}{1};
                    Xobj.Vindex(i) = str2double(a{1}{2});
                    
                else
                    error('openCOSSAN:Function',...
                        ['Bad token syntax, only one index must be given as an input in ' token{i}{1}]);
                end
            end
            
            
        end % get Ctoken
        
    end % methods
    
end

