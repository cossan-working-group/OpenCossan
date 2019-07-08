classdef Nastsem < Sfem
    % NASTSEM class definition
    %
    % $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
    
    properties % Public access
        Nsimulations=10;              % No of Simulations
        Ndofs                         % no of dofs
        Vfixednodes;                  % Nodes where the SE's are connected to residual structure
    end
    
    methods % Methods inheritated from the superclass
        display(Xobj);
        %constructor
        function Xobj= Nastsem(varargin)
            %NASTSEM This method construct the object Nastsem
            %
            % See also http://cossan.cfd.liv.ac.uk/wiki/index.php/@Nastsem
            %
            % $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
            
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
                    case {'smethod'}
                        Xobj.Smethod=varargin{k+1};
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
                    case {'nsimulations'}
                        Xobj.Nsimulations=varargin{k+1};
                    case {'nseed'}
                        Xobj.Nseed=varargin{k+1};
                    case {'norder'}
                        Xobj.Norder=varargin{k+1};
                    case {'nmode'}
                        Xobj.Nmode=varargin{k+1};
                    case {'ndofs'}
                        Xobj.Ndofs=varargin{k+1};
                    case {'vfixednodes'}
                        Xobj.Vfixednodes=varargin{k+1};
                    case {'ninputapproximationorder'}
                        Xobj.NinputApproximationOrder=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Nastsem', ...
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
            global OPENCOSSAN
            OpenCossan.cossanDisp('[Nastsem] Preparation of the input files started',1);
            startTime = OPENCOSSAN.Xtimer.currentTime;
            % Generate the DMAP code
            generateDMAPforNastsem(Xobj);
            % Prepare the Residual File
            prepareResidualFile(Xobj);
            % prepare the Superelement files
            prepareSEfiles(Xobj);
            % assemble all files together
            assembleMainInputFile(Xobj);
            stopTime          = OPENCOSSAN.Xtimer.currentTime;
            Xobj.Ccputimes{2} = stopTime - startTime;
            OpenCossan.cossanDisp(['[Nastsem] Preparation of the input files completed in ' num2str(Xobj.Ccputimes{2}) ' sec'],1);
            OpenCossan.cossanDisp(' ',1);
            startTime = OPENCOSSAN.Xtimer.currentTime;
            % Run NASTRAN
            runNASTRAN(Xobj);
            % Stop the time
            stopTime = OPENCOSSAN.Xtimer.currentTime;
            Xobj.Ccputimes{3} = stopTime - startTime;
            OpenCossan.cossanDisp(['[Nastsem.runNASTRAN] Execution of the maininput.dat file completed in ' num2str(Xobj.Ccputimes{3}) ' sec'],1);
            OpenCossan.cossanDisp(' ',1);
            % Estimate the Response Statistics
            Xoutput_SFEM = postprocess(Xobj);
            % reset working path
            OpenCossan.setWorkingPath(SoriginalWorkingPath)
        end % constructor
    end % methods
end
