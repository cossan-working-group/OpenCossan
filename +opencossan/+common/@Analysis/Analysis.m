classdef (Sealed) Analysis < handle
    %ANALYSIS This class is used to collects information about the
    %current analysis. The object is then added to the OpenCossan object
    %
    % See also: TutorialAnalysis, OPENCOSSAN,TIMER
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    
    properties
        ProjectName(1,1) string                 % Name of the current project
        AnalysisName(1,1) string                % Name of the analysis (for Database and GUI)
        Description(1,1) string                 % Description of the analysis
        WorkingPath char = userpath             % Current working folder
        Timer(1,1) opencossan.common.Timer      % Timer object
        ErrorsStack                             % Store error message from the evaluators
    end
    
    properties (Dependent)
        RandomNumberGeneratorAlgorithm  % Random number generetor Algorithms
        Seed                            % Seed number for the random number generator
        RandomStream                    % Random stream
    end
    
    properties(Hidden=true)
        AnalysisID                      % ID of the current analysis in the DB
    end
    
    methods (Access = ?opencossan.OpenCossan)
        function obj = Analysis(varargin)
            % ANALYSIS This class collects some information about the
            % current analysis. The object is then added to the OpenCossan
            % object.
            % The Analysis object allows to define and set the random number
            % generator, define the working path, initialise the TIMER, set
            % the project and analysis name.
            %
            % SINTAX:
            % Analysis('PropertyName1',PropertyValue1,'PropertyName2',PropertyValue2, ...)
            %
            % INPUT ARGUMENTS:
            % * Description: object description (string)
            % * ProjectName: Project Name (string)
            % * Timer: TIMER object
            % * Seed: seed of the random number generator
            % * RandomNumberAlgorithm: name of the Random Number Algorithm
            % * WorkingPath: Path of the working directory
            %
            % EXAMPLE: Analysis('ProjectName','MyProject','Seed',5164)
            %
            % See also: TutorialAnalysis, OPENCOSSAN,TIMER
            
            % Packages for the Analysis object
            import opencossan.common.Timer
            import opencossan.OpenCossan
            
            %% Process inputs
            if nargin == 0, return, end % Create empty object
            
            % Process inputs via inputParser
            p = inputParser;
            p.FunctionName = 'opencossan.common.Analysis';
            
            % Use default values
            p.addParameter('Description',obj.Description);
            p.addParameter('ProjectName',obj.ProjectName);
            p.addParameter('AnalysisName',obj.AnalysisName);
            p.addParameter('Timer',[]);
            p.addParameter('Seed','');
            p.addParameter('RandomNumberGeneratorAlgorithm','');
            p.addParameter('WorkingPath',userpath);
            p.addParameter('RandomStream','');
            
            % Parse inputs
            p.parse(varargin{:});
            
            %% Set RandonNumberGenerator
            if isempty(p.Results.RandomStream)
                if isempty(p.Results.Seed)
                    seed = 'shuffle';
                else
                    seed = p.Results.Seed;
                end
                if isempty(p.Results.RandomNumberGeneratorAlgorithm)
                    algorithm = 'mt19937ar';
                else
                    algorithm = p.Results.RandomNumberGeneratorAlgorithm;
                end
                
                RandStream.setGlobalStream(RandStream(algorithm,'Seed',seed));
            else
                RandStream.setGlobalStream(p.Results.RandomStream);
            end
            
            % Assign input to objects properties
            obj.Description = p.Results.Description;
            obj.ProjectName = p.Results.ProjectName;
            obj.AnalysisName = p.Results.AnalysisName;
            obj.WorkingPath = p.Results.WorkingPath;
            
            
            %% Initialize embedded objects
            if isempty(p.Results.Timer)
                % Set global variable OPENCOSSAN.Xtimer
                obj.Timer = Timer;
                obj.Timer.start('Description','Timer initialized by Analysis');
            else
                obj.Timer = p.Results.Timer;
            end
            
            assert(~isempty(obj.WorkingPath),...
                'OpenCossan:Analysis:NoUserPath',...
                ['Please define the working path or ',...
                'be sure that ther Matlab userpath is not empty!\n',...
                'The userpath can be reset using the command \n',...
                'userpath(''reset'')'])
                       
        end %Analysis
        
    end % Methods
    
    methods
        
        function stream = get.RandomStream(~)
            stream = RandStream.getGlobalStream();
        end
        
        function Seed = get.Seed(obj)
            Seed = obj.RandomStream.Seed;
        end
        
        function algorithm = get.RandomNumberGeneratorAlgorithm(obj)
            algorithm = obj.RandomStream.Type;
        end
        
        function set.RandomStream(~,stream)
            RandStream.setGlobalStream(stream)
        end
        
        function resetRandomNumberGenerator(obj,seed)
            % RESETRANDOMNUMBERGENERATOR This method of Analysis allows to
            % reset the status of the global random number generator.
            %
            % Resetting a stream should be used primarily for reproducing results.
            %
            % If the value of the seed is provides, it is used to reinitilised the
            % random number generator otherwise the  internal state corresponding to
            % the initialised state of the random number generator is used
            %
            % See also: TutorialAnalysis, OPENCOSSAN, RANDSTREAM
            
            if nargin==1
                reset(obj.RandomStream);
            elseif nargin==2
                reset(obj.RandomStream,seed);
            end
        end
        
    end % Methods
    
end

