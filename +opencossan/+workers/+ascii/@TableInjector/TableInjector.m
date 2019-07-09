classdef TableInjector < opencossan.workers.ascii.Injector
    % class TABLEINJECTOR
    %
    % This class is a child class of Injector and it is used to prepare a
    % input file in a table format.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@TableInjector
    %
    % Copyright~1993-2013,~COSSAN~Working~Group
    %
    % Author:Edoardo Patelli
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
        Cheaderlines         % headerlines
        Vindices             % indices of the dataseries 
        LinjectCoordinates = true  % specify if you want to inject the coordinates of the Dataseries in the table
    end
        
    methods
        function Xobj  = TableInjector(varargin)
            % class TABLEINJECTOR
            %
            % This class is a child class of Injector and it is used to prepare a
            % input file in a table format.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@TableInjector
            %
            % Copyright~1993-2013,~COSSAN~Working~Group
            %
            % Author:Edoardo Patelli
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
            
            if isempty(varargin)
                %compatibility for empty constructor
                return
            end
            
            %% Check Inputs
            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            
            % Set default properties
            Xobj.Stype = 'matlab16';
            
            %% Set options
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'stype'}
                        Xobj.Stype=varargin{k+1};
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'srelativepath'}
                        Xobj.Srelativepath=varargin{k+1};
                        if not(strcmp(Xobj.Srelativepath(end),filesep))
                            Xobj.Srelativepath  = [Xobj.Srelativepath filesep];
                        end
                    case {'sfile'}
                        Xobj.Sfile=varargin{k+1};
                    case {'csheaderlines'}
                        Xobj.Cheaderlines=varargin{k+1};
                    case {'cinputnames'}
                        Xobj.Cinputnames=varargin{k+1};
                    case {'vindices'}
                        Xobj.Vindices=varargin{k+1};
                    case {'linjectcoordinates'}
                        Xobj.LinjectCoordinates=varargin{k+1};
                    case {'sworkingdirectory'}
                        Xobj.Sworkingdirectory=varargin{k+1};
                        if not(strcmp(Xobj.Sscanfilepath(end),filesep))
                            Xobj.Sscanfilepath  = [Xobj.Sscanfilepath filesep];
                        end
                    otherwise
                        error('openCOSSAN:TableInjector:inputValidation',...
                            strcat('PropertyName %s is not a valid input',...
                            'for the TableInjector object'),varargin{k})
                end
            end

        end  
               
        % Other methods
        doInject(Xobj,Tinput) %Inject method        
        display(Xobj) % Display method        

    end
    
    
    
end