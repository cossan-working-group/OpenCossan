classdef MatlabWorker < opencossan.workers.Worker
    % Matlab Input/Output interface
    % See also: Worker, Evaluator, Connector
    %
    % Author: Edoardo Patelli, Matteo Broggi, Marco De Angelis
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2020 COSSAN WORKING GROUP

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
    
    %% Properties of the object
    properties % Public access
        FullFileName(1,:) char            % Default Full path of the matlab file
        Format(1,1) string  = 'table'     % Define interface to the matlab file
        IsFunction(1,1) logical           % Define if the matlab script is a function
        AdditionalPath(1,1)     		  % Folder that contains additional files required for compiling MatlabWorker
        Script(1,:) char                  % field that  contains the script
    end
    
    properties (SetAccess=private,Hidden=true)% Define private propeties
        IsCompiled logical = false          % compiled status
        FunctionHandle                      % function handle for external file
    end
    
    properties  (Constant,Hidden)
        % Available format
        FormatTypes= ["table","structure","matrix","vectors"];
    end
    %% Methods of the class
    methods
        
        [XSimOut, Poutput] = deterministicAnalysis(Xmio,Xinput) % Evaluates the target function/script using the nominal values
        
        [XSimOut,Pout] = run(Xobj,varargin)   % Evaluates the target function/script
        
        [XSimOut,Pout] = runJob(Xobj,varargin) %Evaluates the target function using the JobManager
        
        [Xobj]      = compile(Xobj,varargin)    %This method allows compiling the m-function within the MatlabWorker
        
        tableOutput = evaluate(thisObject,tableInput)
        %% Constructor
        function obj   = MatlabWorker(varargin)
            %% MatlabWorker  Matlab Input/Output mapper
            %
            %   MatlabWorker defines an object type, which can be used to map an
            %   input to the corresponding output, using a Matlab
            %   function defined in an m-file
            %
            % See also: Worker,
           
            
            %% Process inputs
            if nargin == 0
                superArg={};
            else
                
                % Define optional arguments with default values
                OptionalsArguments={"FullFileName", [];...
                                    "Format","table";...
                                    "IsFunction",false;...
                                    "AdditionalPath","";...
                                    "Script",[];...
                                    "FunctionHandle",[]};

                % Parse the optional values
                 [optionalArg, superArg] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    [OptionalsArguments{:,1}],{OptionalsArguments{:,2}}, varargin{:});
            end
            
            % Now we define all the inputs not filtered out by the parsers
            obj@opencossan.workers.Worker(superArg{:});
            
            if nargin>0
            
                obj.FullFileName = optionalArg.fullfilename;
                obj.Format = optionalArg.format;
                obj.IsFunction = optionalArg.isfunction;    
                obj.AdditionalPath = optionalArg.additionalpath;  
                obj.Script = optionalArg.script; 
                obj.FunctionHandle = optionalArg.functionhandle; 
                % Check the object
                obj = obj.validateConstructor;
            end
  
        end     %of constructor
        
        PinputMio=prepareInput(Xobj,varargin); % Prepare the input file for the execution of MatlabWorker Object
        
    end    %of methods
    
    %% Private methods
    methods (Access = private)
        Poutput = checkPinput(Xobj,Pinput)    %this method checks the correctness of the objects given to the method run of MatlabWorker
        XsimOut = createSimulationData(Xobj,Poutput)    %this method checks the correctness of the matrix/structure output from MatlabWorker and create a simulationData
        [PoutputALL, Vresults] = retrieveResults(Xobj,Vresults,Vstart,Vend,PoutputALL,Xjob)   %method to retrieve results after evaluation of MatlabWorker
    end     %of private methods
    
    methods (Access = protected)
        Xobj=validateConstructor(Xobj);  % Validate the constructor
        Pout=runScript(Xobj,Pinput);     % evaluate a Matlab script.
        Pout=runFunction(Xobj,Pinput);   % evaluate a Matlab function.
        [XSimOut,Pout] = runJobMatlab(Xobj,varargin)
        [XSimOut,Pout] = runJobCompiled(Xobj,varargin)
    end
    
    
end     %of class definition
