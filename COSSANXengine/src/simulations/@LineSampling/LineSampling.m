classdef LineSampling < Simulations
    % LineSampling class
    %   This class allows to perform simulation adopting the Line Sampling
    %   strategy. Please refer to the Theory Manual and Reference Manual
    %   for more information about the Line Sampling.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@LineSampling
    %
    % Author: Edoardo Patelli and Marco de Angelis
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
    
    %% Properties
    properties
        Valpha          % Important Direction (pointing to the failure area)
        CalphaNames     % Names of the corresponding directions (i.e. RandomVariable)
    end
       
    properties (Dependent = true, SetAccess = protected)
        Nlinexbatch        % number of lines per batch
        Nlinelastbatch     % number of lines in the last batch
    end
    
    properties
        Nlines                      % Termination criteria for the maximum number of lines
        Vset=1:6                    % Evaluation points along the line
        Ncfine=1000                 % Number of iterpolation points of the values along each line
    end
    
    methods
        %% Methods inheritated from the superclass
        display(Xobj)    % show object details
        
        XsimOut=apply(Xobj,Xtarget)      % Performe Monte Carlo Simulation
        
        [Xpf,XsimData]=computeFailureProbability(Xobj,Xtarget)   % Esitmate FailureProbability
        
        Xsamples = sample(Xobj,varargin) % Generate samples using IS method
        
        
        %% constructor
        function Xobj= LineSampling(varargin)
            %LINESAMPLING This is the constructor of the LineSampling
            %object.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@LineSampling
            %
            % Author: Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            %% Validate input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'cov'}
                        Xobj.CoV=varargin{k+1};
                    case {'timeout'}
                        Xobj.timeout=varargin{k+1};
                    case {'nsamples'}
                        NsamplesUD=varargin{k+1};
                    case {'nlines'}
                        NlinesUD=varargin{k+1};
                    case {'conflevel'}
                        Xobj.confLevel=varargin{k+1};
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                    case {'nbatches'}
                        Xobj.Nbatches=varargin{k+1};
                    case {'lintermediateresults'}
                        Xobj.Lintermediateresults=varargin{k+1};
                    case {'xgradient','xlocalsensitivitymeasures'}
                        Xgradient=varargin{k+1};
                    case {'cxgradient','cxlocalsensitivitymeasures'}
                        Xgradient=varargin{k+1}{1};
                    case {'valpha','vimportancedirection'}
                        Xobj.Valpha=varargin{k+1};
                        Xobj.Valpha=Xobj.Valpha(:)/norm(Xobj.Valpha);
                    case {'cimportancedirectionnames'}
                        Xobj.CalphaNames=varargin{k+1}{1};
                    case {'vset'}
                        Xobj.Vset=varargin{k+1};
                    case {'ncfine'}
                        Xobj.Ncfine=varargin{k+1};
                    case {'nseedrandomnumbergenerator'}
                        Nseed       = varargin{k+1};
                        Xobj.XrandomStream = ...
                            RandStream('mt19937ar','Seed',Nseed);
                    case {'xrandomnumbergenerator'}
                        assert(isa(varargin{k+1},'RandStream'),...
                            'openCOSSAN:LineSampling:wrongRandStream',...
                            'A RandStream object is required after argument %s\nProvided object of class %s', varargin{k},class(varargin{k+1}))
                        Xobj.XrandomStream  = varargin{k+1};                        
                    otherwise
                        error('openCOSSAN:LineSampling:wrongArgument',...
                             'Field name %s not allowed!',varargin{k});
                end
            end % end process inputs
            
            %% Check Important Direction
            if exist('Xgradient','var')
                assert(isa(Xgradient,'Gradient') | isa(Xgradient,'LocalSensitivityMeasures'), ...
                    'openCOSSAN:LineSampling',...
                    'Object of class %s is not valid to define the important direction', ...
                    class(Xgradient))
                
                % Keep only the Gradient/SensitivityMeasures that refers to the
                % performance function
                
                assert(length(Xgradient)==1,'openCOSSAN:LineSampling',...
                    ['Please provide a %s ' ...
                    'of the PerformanceFunction only! \nLength of the provided object: %i'], ...
                    class(Xgradient),length(Xgradient))
                
                if isempty(Xobj.Valpha)
                    % It is necessary to go in the opposite direction 
                    % of the Gradient or the SensitivityMeasure
                    Xobj.Valpha=-Xgradient.Valpha;
                    Xobj.CalphaNames=Xgradient.Cnames;
                end
                
            end
            
            % Adapt Nlines and Nsamples
            if exist('NlinesUD','var')
                if exist('NsamplesUD','var')
                    if NlinesUD*length(Xobj.Vset)~=NsamplesUD
                        Xobj.Nsamples=NlinesUD*length(Xobj.Vset);
                        warning('openCOSSAN:simulations:LineSampling',...
                            ['Nsamples reset to ' num2str(Xobj.Nsamples)])
                    else
                        Xobj.Nsamples=NsamplesUD;
                    end
                    Xobj.Nlines=NlinesUD;
                else
                    Xobj.Nsamples=NlinesUD*length(Xobj.Vset);
                    Xobj.Nlines=NlinesUD;
                end
            else
                if exist('NsamplesUD','var')
                    Xobj.Nlines=floor(NsamplesUD/length(Xobj.Vset));
                    if NsamplesUD~=Xobj.Nlines*length(Xobj.Vset)
                        warning('openCOSSAN:simulations:LineSampling',...
                            ['Nsamples reset to ' num2str(Xobj.Nlines*length(Xobj.Vset))])
                    end
                end
                Xobj.Nsamples=Xobj.Nlines*length(Xobj.Vset);
                
            end
            
            if Xobj.Nbatches>Xobj.Nlines
                error('openCOSSAN:simulations:LineSampling',...
                    ['The number of batches (' num2str(Xobj.Nbatches) ...
                    ') can not be greater than the number of Lines (' ...
                    num2str(Xobj.Nlines) ')' ]);
            end
            
            %%
            
        end % end constructor
        
        
        function Nlinexbatch = get.Nlinexbatch(Xobj)
            Nlinexbatch = floor(Xobj.Nlines/Xobj.Nbatches);
        end % Modulus get method
        
        function Nlinelastbatch = get.Nlinelastbatch(Xobj)
            Nlinelastbatch =  Xobj.Nlinexbatch+rem(Xobj.Nlines,Xobj.Nbatches);
        end % Modulus get method
        
        
    end % methods
    
end

