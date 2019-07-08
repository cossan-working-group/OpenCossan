classdef Evaluator
    %EVALUATOR  Constructor function for class EVALUATOR
    % The evaluator is the object that controls the execution of the analysis. It
    % communicates with the JobManager to distribute the jobs on the grid. 
    %
    % See also: https://cossan.co.uk/wiki/index.php/@Evaluator
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
        Sdescription            % Description of the object
        XjobInterface           % JobManagerInterface
        CXsolvers               % Cell array of solvers
        CSnames                 % Names of the evaluators
        CSqueues                % Names of queues for solvers
        CShostnames             % Names of hostnames where evaluate solvers
        CSparallelEnvironments  % Name of the parallel environment of each solver
        Vslots                  % Number of slots used in each job
        VLcompiled              % Number of slots used in each job
        Vconcurrent             % Number of concurrent execution of each solver
        LremoteInjectExtract = false %TODO: make it true
        LverticalSplit = false  % if true split the analysis in vertical components (see wiki for more details)
        Sduration = ''          % max job duration (for jobManager ) 
    end
    
    properties (Dependent=true)
        Coutputnames  % Output variables defined in the Evaluator
        Cinputnames   % Input variables required by the Evaluator
    end
    
    methods
        function Xev=Evaluator(varargin)
            % EVALUATOR This constructor defines an Evaluator that is collection
            % of Connectors.
            %
            % Please see the reference manual for the complete documentation
            %
            % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo Patelli
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            if nargin==0
                % Crate empty object
                return
            end
            
            %% Process input argments
            for k=1:2:length(varargin)
                
                switch lower(varargin{k})
                    case 'xsolutionsequence'
                        assert(isa(varargin{k+1},'SolutionSequence'), ...
                            'openCOSSAN:Evaluator', ...
                            'The object of class %s is not valid after the PropertyName %s', ...
                            class(varargin{k+1}),varargin{k})
                        
                        Xev.CXsolvers{end+1}=varargin{k+1};
                    case 'xmio'
                        assert(isa(varargin{k+1},'Mio'), ...
                            'openCOSSAN:Evaluator', ...
                            'The object of class %s is not valid after the PropertyName %s', ...
                            class(varargin{k+1}),varargin{k})
                        Xev.CXsolvers{end+1}=varargin{k+1};
                        
                    case 'xconnector'
                        assert(isa(varargin{k+1},'Connector'), ...
                            'openCOSSAN:Evaluator', ...
                            'The object of class %s is not valid after the PropertyName %s', ...
                            class(varargin{k+1}),varargin{k})
                        Xev.CXsolvers{end+1}=varargin{k+1};
                        
                    case 'xjobmanagerinterface'
                        assert(isa(varargin{k+1},'JobManagerInterface'), ...
                            'openCOSSAN:Evaluator', ...
                            'The object of class %s is not valid after the PropertyName %s', ...
                            class(varargin{k+1}),varargin{k})
                        Xev.XjobInterface=varargin{k+1};
                    case 'cxjobmanagerinterface'
                        assert(isa(varargin{k+1}{1},'JobManagerInterface'), ...
                            'openCOSSAN:Evaluator', ...
                            'The object of class %s is not valid after the PropertyName %s', ...
                            class(varargin{k+1}{1}),varargin{k})
                        Xev.XjobInterface=varargin{k+1}{1};
                    case {'sdescription'}
                        Xev.Sdescription=varargin{k+1};
                    case {'lremoteinjectextract'}
                        Xev.LremoteInjectExtract=varargin{k+1};
                    case {'cshostnames'}
                        Xev.CShostnames=varargin{k+1};
                    case {'csparallelenvironments','cspe'}
                        Xev.CSparallelEnvironments=varargin{k+1};
                    case {'csqueues'}
                        Xev.CSqueues=varargin{k+1};
                    case {'sduration'}
                        Xev.Sduration=varargin{k+1};    
                    case {'csnames','csmembers'}
                        Xev.CSnames=varargin{k+1};
                    case {'vconcurrent','nconcurrent'}
                        Xev.Vconcurrent=varargin{k+1};
                    case {'vslots','nslots'}
                        Xev.Vslots=varargin{k+1};
                    case 'cxmembers'
                        % The object are retrieved from the cell array
                        for iobj=1:length(varargin{k+1})
                            switch  class(varargin{k+1}{iobj})
                                case {'Connector', 'Mio','SolutionSequence'}
                                    Xev.CXsolvers{end+1}=varargin{k+1}{iobj};
                                case 'JobManagerInterface'
                                    Xev.XjobInterface=varargin{k+1}{iobj};
                                otherwise
                                    error('openCOSSAN:Evaluator',...
                                        ['The object of class ' ...
                                        class(varargin{k+1}{iobj}) ' not allowed']);
                            end
                        end
                    case 'ccxmembers'
                        % The object are retrieved from the cell array
                        for iobj=1:length(varargin{k+1})
                            switch  class(varargin{k+1}{iobj}{1})
                                case {'Connector', 'Mio','SolutionSequence'}
                                    Xev.CXsolvers{end+1}=varargin{k+1}{iobj}{1};
                                case 'JobManagerInterface'
                                    Xev.XjobInterface=varargin{k+1}{iobj}{1};
                                otherwise
                                    error('openCOSSAN:Evaluator',...
                                        ['The object of class ' ...
                                        class(varargin{k+1}{iobj}{1}) ' not allowed']);
                            end
                        end
                    case 'lverticalsplit'
                        Xev.LverticalSplit=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Evaluator',...
                             'PropertyName %s is not  a valid PropertyName',varargin{k});
                end
            end
            
            % Validate objects
            if ~isempty(Xev.CSnames)
                assert(length(Xev.CSnames)==length(Xev.CXsolvers),...
                    'openCOSSAN:Evaluator',...
                    ['Length of CSnames (' num2str(length(Xev.CSnames)) ...
                    ') must be equal to the length of CXsolvers (' ...
                    num2str(length(Xev.CXsolvers)) ')' ])
            else
                Xev.CSnames=repmat({'N/A'},length(Xev.CXsolvers),1);
            end
            
            if ~isempty(Xev.Vconcurrent)
                assert(length(Xev.Vconcurrent)==length(Xev.CXsolvers),...
                    'openCOSSAN:Evaluator',...
                    ['Length of Vconcurrent (' num2str(length(Xev.Vconcurrent)) ...
                    ') must be equal to the length of CXsolvers (' ...
                    num2str(length(Xev.CXsolvers)) ')' ])
            else
                Xev.Vconcurrent=inf(size(Xev.CXsolvers));
            end
            
            if ~isempty(Xev.CSqueues)
                assert(length(Xev.CSqueues)==length(Xev.CXsolvers),...
                    'openCOSSAN:Evaluator',...
                    ['Length of CSqueues (' num2str(length(Xev.CSqueues)) ...
                    ') must be equal to the length of CXsolvers (' ...
                    num2str(length(Xev.CXsolvers)) ')' ])
            else
                for n=1:length(Xev.CXsolvers)
                    Xev.CSqueues{n}='';
                    Xev.CShostnames{n}='';
                end
            end
            
            if ~isempty(Xev.CShostnames)
                assert(length(Xev.CShostnames)==length(Xev.CXsolvers),...
                    'openCOSSAN:Evaluator',...
                    ['Length of CShostnames (' num2str(length(Xev.CShostnames)) ...
                    ') must be equal to the length of CXsolvers (' ...
                    num2str(length(Xev.CXsolvers)) ')' ])
            else
                for n=1:length(Xev.CXsolvers)
                    Xev.CShostnames{n}='';
                end
            end
            
            if ~isempty(Xev.CSparallelEnvironments)
                assert(length(Xev.CSparallelEnvironments)==length(Xev.CXsolvers),...
                    'openCOSSAN:Evaluator',...
                    ['Length of CSparallelEnvironments (' num2str(length(Xev.CSparallelEnvironments)) ...
                    ') must be equal to the length of CXsolvers (' ...
                    num2str(length(Xev.CXsolvers)) ')' ])
            else
                for n=1:length(Xev.CXsolvers)
                    Xev.CSparallelEnvironments{n}='';
                end
            end
            
            if ~isempty(Xev.Vslots)
                assert(length(Xev.Vslots)==length(Xev.CXsolvers),...
                    'openCOSSAN:Evaluator',...
                    ['Length of Vslots (' num2str(length(Xev.Vslots)) ...
                    ') must be equal to the length of CXsolvers (' ...
                    num2str(length(Xev.CXsolvers)) ')' ])
            else
                Xev.Vslots=ones(size(Xev.CXsolvers));
            end
            
            % Check for unique SwrapperName in the Mio
            for n=1:length(Xev.CXsolvers)
                if isa(Xev.CXsolvers{n},'Mio')
                    Ncount=1;
                    for i=1:n-1
                        if isa(Xev.CXsolvers{i},'Mio')
                            if(strcmp(Xev.CXsolvers{i}.SwrapperName,Xev.CXsolvers{n}.SwrapperName))
                                Ncount = Ncount+1;
                                if Ncount==2
                                    Xev.CXsolvers{n}.SwrapperName = [Xev.CXsolvers{n}.SwrapperName num2str(Ncount)];
                                elseif Ncount<=10
                                    Xev.CXsolvers{n}.SwrapperName = [Xev.CXsolvers{n}.SwrapperName(1:end-1) num2str(Ncount)];
                                else
                                    Xev.CXsolvers{n}.SwrapperName = [Xev.CXsolvers{n}.SwrapperName(1:end-2) num2str(Ncount)];
                                end
                            end
                        end
                    end
                end
            end
            
            
            
            %% Check for duplicated Outputs
            if ~isempty(Xev.Coutputnames)
                Couts=unique(Xev.Coutputnames);
                assert(length(Couts)==length(Xev.Coutputnames),...
                    'openCOSSAN:Evaluator',...
                    strcat('Duplicated outputs present in the Evaluator \n',sprintf('%s ',Xev.Coutputnames{:})))
            end
            
            
        end %end constructor
        
        Xout=apply(Xobj,Pinput) % Run the analysis
        
        Xout=display(Xobj) % Show details of the evaluator
        
        Xout=deterministicAnalysis(Xobj,Xinput) % Perform the deterministic analysis
        
        function Coutputnames=get.Coutputnames(Xobj)
            % Extract output names from the target object
            if isempty(Xobj.CXsolvers)
                Coutputnames={};
            else
                Coutputnames={};
                for n=1:length(Xobj.CXsolvers)
                    if isrow(Xobj.CXsolvers{n}.Coutputnames)
                        Caddoutput=Xobj.CXsolvers{n}.Coutputnames;
                    else
                        Caddoutput=transpose(Xobj.CXsolvers{n}.Coutputnames);
                    end
                    Coutputnames=[Coutputnames Caddoutput]; %#ok<AGROW>
                end
            end
        end
        
        function Cinputnames=get.Cinputnames(Xobj)
            % Extract output names from the target object
            if isempty(Xobj.CXsolvers)
                Cinputnames={};
            else
                Cinputnames=Xobj.CXsolvers{1}.Cinputnames;
                CoutEvaluator={};
                for n=2:length(Xobj.CXsolvers)
                    CaddInputs=Xobj.CXsolvers{n}.Cinputnames; % tmp variable
                    % Remove already present inputs
                    Vindex=false(length(CaddInputs),1);
                    for j=1:length(CaddInputs)
                        Vindex(j)=any(strcmp(Cinputnames,CaddInputs(j)));
                    end
                    CaddInputs(Vindex)=[];
                    
                    if isrow(Xobj.CXsolvers{n-1}.Coutputnames)
                        Caddoutput=Xobj.CXsolvers{n-1}.Coutputnames;
                    else
                        Caddoutput=transpose(Xobj.CXsolvers{n-1}.Coutputnames);
                    end
                    CoutEvaluator=[CoutEvaluator Caddoutput];  %#ok<AGROW>
                    
                    for j=1:length(CoutEvaluator)
                        % Remove Evaluator inputs provided by the previous Evaluator
                        CaddInputs(strcmp(CoutEvaluator(j),CaddInputs))=[];
                    end
                    Cinputnames=[Cinputnames CaddInputs]; %#ok<AGROW>
                end
            end
        end
        
        Xjm=getJobManager(Xobj,varargin)
        
    end
    
    methods (Access=protected)
        Xout=executeWorkers(Xobj,Tinput);
    end
    
    methods (Static)
        % Static methods that allows to add to the input structure output
        % of available in SimulationData.
        % If the simulationData and Tinput structure contains the same
        % variables the variable provided by the structure are exported in
        % the output.
        
        Toutput=addField2Structure(Xsolver,XsimData,Tinput)
    end
    
end
