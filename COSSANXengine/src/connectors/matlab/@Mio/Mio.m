classdef Mio
    % Matlab Input/Output interface
    % See also: https://cossan.co.uk/wiki/index.php/@Mio
    %
    % Author: Edoardo Patelli, Matteo Broggi, Marco De Angelis
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
    
    %% Properties of the object
    properties % Public access
        Sdescription                    % Description of the Matlab I/O
        Spath           = ''            % Default Full path
        Sfile           = ''            % matlab script (.m extension can be added or omitted, it will be stripped away by the constructor method)
        Lfunction       = false         % Define if the matlab script is a function
        Liostructure    = true          % Input and Output arguments passed as a structure
        Liomatrix       = false         % Input and Output arguments passed as a single matrix
        Sadditionalpath     		    % Folder that contains additional files required for compiling Mio
        Coutputnames                    % Names of the generated outputs
        Cinputnames                     % Names of the required inputs
        Lkeepsimfiles = false
        Sscript                         % field that  contains the script
        % to be executed (i.e. there is no file to be executed but this script)
        SwrapperName    ='mio_wrapper'  % Name of the compiled MIO
    end
    
    
    properties (SetAccess=private,Hidden=true )% Define private propeties
        Lcompiled  = false              % compiled status
        FunctionHandle                  % function handle for external file
    end
    
    properties (SetAccess=protected)    % Define protected propeties
    end
    
    %% Methods of the class
    methods
        
        display(Xobj)      % Shows the summary of the Xobj
        
        [XSimOut, Poutput] = deterministicAnalysis(Xmio,Xinput) % Evaluates the target function/script using the nominal values
        
        [XSimOut,Pout] = run(Xobj,varargin)   % Evaluates the target function/script
        
        [XSimOut,Pout] = runJob(Xobj,varargin) %Evaluates the target function using the JobManager
        
        [Xobj]      = compile(Xobj,varargin)    %This method allows compiling the m-function within the Mio
        
        %% Constructor
        function Xobj   = Mio(varargin)
            %% Mio  Matlab Input/Output mapper
            %
            %   Mio defines an object type, which can be used to map an
            %   input to the corresponding output, using a Matlab
            %   function defined in an m-file
            %
            % See also: https://cossan.co.uk/wiki/index.php/@Mio
            % 
            % Author: Edoardo Patelli and Matteo Broggi
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
                % Construct an empty object used by the subclasses
                % Please DO NOT REMOVE this
                return
            end
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set parameters defined by the user
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription = varargin{k+1};
                    case 'swrappername'
                        Xobj.SwrapperName = varargin{k+1};
                    case 'spath'
                        Xobj.Spath = varargin{k+1};
                    case 'sfile'
                        Xobj.Sfile = varargin{k+1};
                    case 'lfunction'
                        Xobj.Lfunction = varargin{k+1};
                    case 'liostructure'
                        Xobj.Liostructure = varargin{k+1};
                        Xobj.Liomatrix= ~varargin{k+1};
                    case 'liomatrix'
                        Xobj.Liomatrix = varargin{k+1};
                        Xobj.Liostructure= ~varargin{k+1};
                    case 'sadditionalpath'
                        Xobj.Sadditionalpath = varargin{k+1};
                    case 'soutputname'
                        Xobj.Coutputnames = varargin(k+1);
                    case 'coutputnames'
                        Xobj.Coutputnames = varargin{k+1};
                    case 'cinputnames'
                        Xobj.Cinputnames = varargin{k+1};
                    case 'lkeepsimfiles'
                        Xobj.Lkeepsimfiles = varargin{k+1};
                    case 'sscript'
                        Xobj.Sscript = varargin{k+1};
                    case {'afunction' 'afunctionhandle'}
                        Xobj.FunctionHandle = varargin{k+1};
                    otherwise
                        error('openCOSSAN:connectors:Mio',...
                              'The Field name (%s) is not allowed',varargin{k});
                end
            end
            
            %% Check inputs
            Xobj=validateConstructor(Xobj);
            
        end     %of constructor
        
        
    end    %of methods
    
    %% Private methods
    methods (Access = private)
        Poutput = checkPinput(Xobj,Pinput)    %this method checks the correctness of the objects given to the method run of Mio
        XsimOut = createSimulationData(Xobj,Poutput)    %this method checks the correctness of the matrix/structure output from Mio and create a simulationData
        [PoutputALL, Vresults] = retrieveResults(Xobj,Vresults,Vstart,Vend,PoutputALL,Xjob)   %method to retrieve results after evaluation of Mio
    end     %of private methods
    
    methods (Access = protected)
        Xobj=validateConstructor(Xobj);  % Validate the constructor
        Pout=runScript(Xobj,Pinput);     % evaluate a Matlab script.
        Pout=runFunction(Xobj,Pinput);   % evaluate a Matlab function.
        [XSimOut,Pout] = runJobMatlab(Xobj,varargin)
        [XSimOut,Pout] = runJobCompiled(Xobj,varargin)
    end
    
    
end     %of class definition
