classdef Extrema
    %EXTREMA   This object contains the solution of an Interval Analysis.
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Extrema
    %
    % $Author:~Marco~de~Angelis$
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    %
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
    %% Properties of the object
    properties (Access=public)
        Sdescription                     % Description of the object
        Sexitflag                        % exit flag of optimization algorithm
        SresultsPath                     % path where results are stored
        
        totalTime                        % time required to solve problem
        
        CdesignVariableNames             % names of the Design Variables
        
        CVargOptima                      % values of the argument optima
        
        CXsimOutOptima                   % two simulation output objects containing results from last two simulations
        CXresultsExtremeCase             % output object containing results from ExtremeCase analysis
        CXresults                        % results from the global search
        
        XanalysisObject                  % object used to perform the analysis
        
        Nevaluations                     % number of model evaluations 
        Niterations                      % number of iteration/generation
        
        CXoptima                         % cell of objects for the minimum and maximum
        
        XsimulationData                  % object with the simulation data
        
        Coptima                          % minimum and maximum of the objective function
        CcovOptima                       % estimator covariance for the optima
    end
    
    properties (Access=protected)
    end
    
    properties (Dependent=true)
%        NcandidateSolutions           % Number of candidate solutions
%        CconstraintsNames             % Names of the constraints
%        CobjectiveFunctionNames       % Names of the objectiveFunctions
    end
    
    %% Methods of the class
    methods
        display(Xobj)  % shows the summary of the Optimum object
        
%         varargout=plotCandidateSolutions(Xobj,varargin) % Plot the evolution of the objective and design variables
        
%         varargout=plotParallelCoordinates(Xobj,varargin) % Plot the final solution in normalised parallel coordinates
        
%         varargout=plotPolygonCoordinates(Xobj,varargin) % Plot the final solution in polygon coordinates
        
        function Xobj  = Extrema(varargin)
            %% Constructor
            
            %% Validate input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            
            %%  Set values passed by the user
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case 'totaltime'
                        Xobj.totalTime=varargin{k+1};
                    case 'sexitflag'
                        Xobj.Sexitflag=varargin{k+1};
                    case 'sresultspath'
                        Xobj.SresultsPath=varargin{k+1};
                    case 'cdesignvariablenames'
                        Xobj.CdesignVariableNames=varargin{k+1};
                    case 'cvargoptima'
                        Xobj.CVargOptima=varargin{k+1};
                    case 'coptima'
                        Xobj.Coptima=varargin{k+1};
                    case 'ccovoptima'
                        Xobj.CcovOptima=varargin{k+1};
                    case 'cxoptima'
                        Xobj.CXoptima=varargin{k+1};
                    case 'cxsimoutoptima'
                        Xobj.CXsimOutOptima=varargin{k+1};
                    case 'cxresultsextremecase'
                        Xobj.CXresultsExtremeCase=varargin{k+1};
                    case 'cxresults'
                        Xobj.CXresults=varargin{k+1};
                    case 'xanalysisobject'
                        Xobj.XanalysisObject=varargin{k+1};
                    case {'nmodelevaluations','nevaluations'}
                        Xobj.Nevaluations=varargin{k+1};
                    case 'niterations'
                        Xobj.Niterations=varargin{k+1};
                    case 'xsimdata'
                        Xobj.XsimulationData=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Extrema:Extrema', ...
                            ['The PropertyName ' varargin{k} ' is not valid']);
                end
            end
            
            if isempty(Xobj.SresultsPath) && ~isempty(Xobj.XanalysisObject)
                Xobj.SresultsPath=Xobj.XanalysisObject.StempPath;
            end
            
             % if the directory containing results DOES NOT exist return an
             % warning
            [~,mess]=mkdir(Xobj.SresultsPath);
            if strcmpi(mess,'Directory already exists.')
                % ok the directory already existed
            else
                warning('openCOSSAN:Extrema',...
                    'The directory where the optimization results are stored does not exist!')
            end
            
            lists=dir(Xobj.SresultsPath);
            assert(~isempty(lists),...
                'openCOSSAN:Extrema',...
                'There are no results saved in the directory %s!',Xobj.SresultsPath)
            
            % TODO: add one more check to target the specific name of the file.
            
            
        end     %of constructor
        
    end     %of methods
    
    
    
end     %of classdef
