classdef Perturbation < Sfem
    % PERTURBATION class definition
    %
    % $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
    
    
    methods % Methods inheritated from the superclass
        display(Xobj);
        %constructor
        function Xobj = Perturbation(varargin)
            % PERTURBATION Constructor for the Perturbation object
            %
            % See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@Perturbation
            %
            % $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
            %
            % validate Input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'xmodel'}
                        Xobj.Xmodel=varargin{k+1};
                    case {'cxmodel'}
                        Xobj.Xmodel=varargin{k+1}{1};
                    case {'sanalysis'}
                        Xobj.Sanalysis=varargin{k+1};
                    case {'cstepdefinition'}
                        Xobj.CstepDefinition=varargin{k+1};
                    case {'simplementation'}
                        Xobj.Simplementation=varargin{k+1};
                    case {'cyoungsmodulusrvs'}
                        Xobj.CyoungsModulusRVs=varargin{k+1};
                    case {'cdensityrvs'}
                        Xobj.CdensityRVs=varargin{k+1};
                    case {'cthicknessrvs'}
                        Xobj.CthicknessRVs=varargin{k+1};
                    case {'ccrosssectionrvs'}
                        Xobj.CcrossSectionRVs=varargin{k+1};
                    case {'cforcervs'}
                        Xobj.CforceRVs=varargin{k+1};
                    case {'lcleanfiles'}
                        Xobj.Lcleanfiles=varargin{k+1};
                    case {'lfesolverexecuted'}
                        Xobj.Lfesolverexecuted=varargin{k+1};
                    case {'ltransfercompleted'}
                        Xobj.Ltransfercompleted=varargin{k+1};
                    case {'lstoreinput'}
                        Xobj.Lstoreinput=varargin{k+1};
                    case {'mconstraineddofs'}
                        Xobj.MconstrainedDOFs=varargin{k+1};
                    case {'norder'}
                        Xobj.Norder=varargin{k+1};
                    case {'ninputapproximationorder'}
                        Xobj.NinputApproximationOrder=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Perturbation', ...
                            'Field name %s not allowed',varargin{k});
                end
            end
            % Check input
            Xobj=checkInput(Xobj);
        end
        
        function Xoutput_SFEM=performAnalysis(Xobj)
            %execute everything in a subfolder please!!!
            mkdir(fullfile(OpenCossan.getCossanWorkingPath,'SfemExecution'));
            SoriginalWorkingPath = OpenCossan.getCossanWorkingPath;
            OpenCossan.setWorkingPath(fullfile(SoriginalWorkingPath,'SfemExecution'));
            % Prepare Input Files
            if strcmpi(Xobj.Simplementation,'Regular')...
                    && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
                    && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype(1:5),'nastr')
                Xobj=prepareInputFilesNASTRANRegular(Xobj);
            elseif strcmpi(Xobj.Simplementation,'Componentwise')...
                    && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
                    && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype(1:5),'nastr')
                Xobj=prepareInputFilesNASTRANComponentwise(Xobj);
            elseif strcmpi(Xobj.Simplementation,'Regular')...
                    && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
                    && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype,'ansys')
                Xobj=prepareInputFilesANSYS(Xobj);
            elseif strcmpi(Xobj.Simplementation,'Regular')...
                    && Xobj.Ltransfercompleted == false && Xobj.Lfesolverexecuted == false...
                    && strcmpi(Xobj.Xmodel.Xevaluator.CXsolvers{1}.Stype,'abaqus')
                Xobj=prepareInputFilesABAQUS(Xobj);               
            end
            % run the FE solver (first check if the FE analysis is already done)
            if Xobj.Lfesolverexecuted == false && Xobj.Ltransfercompleted == false
                % Check if a Grid is defined
                XsfemGrid = Xobj.Xmodel.Xevaluator.getJobManager(...
                    'SsolverName',Xobj.Xmodel.Xevaluator.CSnames{1});
                if isempty(XsfemGrid)
                    Xobj = runFESolverSequential(Xobj);
                else
                    Xobj = runFESolverParallel(Xobj);
                end
            end
            % Transfer System Quantities to MATLAB
            if Xobj.Ltransfercompleted == false
                Xobj = transferSystemQuantities(Xobj);
            else
                if exist('SFEM.mat','file') ~= 2
                    error('COSSAN:Perturbation',...
                        'Please make sure that the SFEM.mat exists');
                end
                load SFEM
            end
            % Calculate K_i, M_i, f_i, etc.
            Xobj = calculateDerivatives(Xobj);
            % Estimate the Response Statistics
            Xoutput_SFEM = postprocess(Xobj);
            % reset working path
            OpenCossan.setWorkingPath(SoriginalWorkingPath)
        end % constructor
    end % methods
end
