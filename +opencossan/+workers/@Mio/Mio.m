classdef Mio < opencossan.workers.Worker
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
        FullFileName(1,:) char            % Default Full path of the matlab file
        Format(1,1) string  = 'table'       % Define interface to the matlab file       
        IsFunction(1,1) logical  = false    % Define if the matlab script is a function
        AdditionalPath(1,1)     		    % Folder that contains additional files required for compiling Mio
        Script(1,:) char                  % field that  contains the script
    end
    
    properties (SetAccess=private,Hidden=true)% Define private propeties
        IsCompiled logical = false          % compiled status
        FunctionHandle                      % function handle for external file
    end
       
    properties  (Constant,Hidden)
        % Available format 
        FormatTypes={'table','structure','matrix','vectors'};
    end
    %% Methods of the class
    methods
                
        [XSimOut, Poutput] = deterministicAnalysis(Xmio,Xinput) % Evaluates the target function/script using the nominal values
        
        [XSimOut,Pout] = run(Xobj,varargin)   % Evaluates the target function/script
        
        [XSimOut,Pout] = runJob(Xobj,varargin) %Evaluates the target function using the JobManager
        
        [Xobj]      = compile(Xobj,varargin)    %This method allows compiling the m-function within the Mio
        
        tableOutput = evaluate(thisObject,tableInput)
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
            % COSSAN WORKING GROUP
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
            
            %% Process inputs
            if nargin == 0
                return % Create empty object
            else
                % Process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.workers.Mio';
                
                % Use default values
                p.addParameter('Description',Xobj.Description);
                p.addParameter('FullFileName',Xobj.FullFileName);
                p.addParameter('Format',Xobj.Format);
                p.addParameter('IsFunction',Xobj.IsFunction);
                p.addParameter('AdditionalPath',Xobj.AdditionalPath);
                p.addParameter('Script',Xobj.Script);
                % From the superclass
                p.addParameter('OutputNames',Xobj.OutputNames);
                p.addParameter('InputNames',Xobj.InputNames);
                p.addParameter('IsKeepSimulationFiles',Xobj.IsKeepSimulationFiles);
                p.addParameter('FunctionHandle',Xobj.FunctionHandle);
                                              
                p.parse(varargin{:});
                
                % Assign input to objects properties
                Xobj.Description = p.Results.Description;
                Xobj.FullFileName = p.Results.FullFileName;
                Xobj.Format = p.Results.Format;
                Xobj.OutputNames = p.Results.OutputNames;
                Xobj.InputNames = p.Results.InputNames;
                Xobj.Script = p.Results.Script;  
                Xobj.IsFunction = p.Results.IsFunction;
                Xobj.AdditionalPath = p.Results.AdditionalPath;
                Xobj.IsKeepSimulationFiles = p.Results.IsKeepSimulationFiles; 
                Xobj.FunctionHandle = p.Results.FunctionHandle;  
                
                Xobj = Xobj.validateConstructor;
            end
        end     %of constructor
        
        PinputMio=prepareInput(Xobj,varargin); % Prepare the input file for the execution of Mio Object
        
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
