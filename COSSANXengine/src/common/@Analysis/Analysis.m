classdef Analysis < handle
    %ANALYSIS This class defines collects some information about the
    %current analysis. The object is then added to the OpenCossan object
    %
    % See also: https://cossan.co.uk/wiki/index.php/@Analysis
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
    
    properties
        SprojectName           % Name of the current project
        SanalysisName          % Name of the analysis (for Database and GUI)
        Sdescription=''
        SworkingPath=userpath  % Path of the working folder
        Xtimer                 % Timer object
        SrandomNumberAlgorithm='mt19937ar'; % Random Number generetor Algorithms
        Nseed                  % Seed number for the random number generator
        XrandomStream          % Store the current Random stream 
    end    
    
    properties(Hidden=true)
        NanalysisID            % ID of the current analysis in the DB
    end
    
    methods
        
        function Xobj=Analysis(varargin)
            %ANALYSIS This class defines collects some information about the
            %current analysis. The object is then added to the OpenCossan object
            %
            % See also: https://cossan.co.uk/wiki/index.php/@Analysis
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
            
            % Paramters for the Analysis object
            %% Process inputs
            OpenCossan.validateCossanInputs(varargin{:});
            
            % Get Analysis from OpenCossan
            if isa(OpenCossan.getAnalysis,'Analysis')
                Xobj=OpenCossan.getAnalysis;
            end
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sprojectname'} %  DONE
                        Xobj.SprojectName = varargin{k+1};
                    case {'sanalysisname'} % Done
                        Xobj.SanalysisName = varargin{k+1};
                    case {'sdescription'} % Done
                        Xobj.Sdescription = varargin{k+1};
                    case {'xtimer'} % Done
                        Xobj.Xtimer = varargin{k+1};
                    case {'nseed'}
                        Xobj.Nseed = varargin{k+1};
                    case {'srandomnumberalgorithm'}
                        Xobj.SrandomNumberAlgorithm = varargin{k+1};
                    case {'sworkingpath','smainpath'}
                     assert(isdir(varargin{k+1}), ...
                            'openCOSSAN:OpenCossan','please provide a valid directory name for the workingpath')
                        Xobj.SworkingPath = varargin{k+1};    
                    otherwise
                        error('openCOSSAN:Analysis',...
                            'The property name %s is not valid',varargin{k})
                end
            end
            

            
            %% Set the RandomNumberGenerator
            if isempty(Xobj.Nseed)
                Xobj.XrandomStream = RandStream(Xobj.SrandomNumberAlgorithm,'Seed','shuffle');
            else
                Xobj.XrandomStream = RandStream(Xobj.SrandomNumberAlgorithm,'Seed',Xobj.Nseed);
            end
            RandStream.setGlobalStream(Xobj.XrandomStream);
            
            %% Initialize embedded objects
            if isempty(Xobj.Xtimer)
                % Set global variable OPENCOSSAN.Xtimer
                Xobj.Xtimer = Timer;
                Xobj.Xtimer.starttime('Sdescription','Timer initialized by Analysis');
            end
            
            if isempty(Xobj.SworkingPath)
                Xobj.SworkingPath=userpath;
            end
            
            assert(~isempty(Xobj.SworkingPath),'openCOSSAN:Analysis',...
                'Please define the working path or be sure that ther Matlab userpath is not empty!\n The userpath can be reset using the command userpath(''reset'')')
            
            
            %% Current working directory
            if isunix
                if strcmp(Xobj.SworkingPath(end),':')
                    Xobj.SworkingPath=Xobj.SworkingPath(1:end-1);
                end
            elseif ispc
                if strcmp(Xobj.SworkingPath(end),';')
                    Xobj.SworkingPath=Xobj.SworkingPath(1:end-1);
                end
            end
            
            if ~strcmp(Xobj.SworkingPath(end),filesep)
                Xobj.SworkingPath=[Xobj.SworkingPath filesep];
            end
            
            %OpenCossan.setAnalysis(Xobj)
            
        end %Analysis
        
    end % Methods
        
end
    
