classdef AdaptiveLineSampling < opencossan.simulations.Simulations
    % ADAPTIVELINESAMPLING class
    %   This class allows to perform simulation with the Advanced Line
    %   Sampling method.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@AdaptiveLineSampling
    %
    % Author: Marco de Angelis and Edoardo Patelli
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
    
    %% Properties
    properties (SetAccess = public)
        StempPath                   % temporary path where results are stored
        SfolderName                 % name of the folder containing results
        VdirectionSNS               % Important Direction in SNS (provided by user)
        VdirectionPHY               % Important Direction in PHY (provided by user)
        VpointCoordPHY              % Coordinates of a point in PHYsical Space that will determine the important direction (user provided)
        VimportantTails             % Tails of the distributions that point towards failure
    end
    
    properties (SetAccess = public, Transient = true)
%         MstatePointsPHY                % matrix of limit state points (provided by user to initialise the i.direction)
%         MfailurePointsPHY              % matrix of failure points (provided by user to initialise the i.direction)
    end
    
    properties (SetAccess = protected)
        NmaxDirectionalUpdates=Inf  % maximum number of directional updates (to donot update direction set this property =0)
        Vclock                      % time of the analysis
    end
    
    properties (SetAccess = private)
        Nlines=10                   % Number of lines (nominal value = 10)
        Ncfine=1000                 % Number of iterpolation points of the values along each line
        acceptableError=1e-08        % Acceptable error on the value of the performance function
        tolerance=1e-4              % Tolerance on the Newton's iteration steps
        NmaxPoints=10               % Max number of points adopted to identify the limit state function on each line
    end
    
    properties (SetAccess = private, Hidden = true)
        minStep=1                   % minimum step adopted to move along the line
        maxStep=3                   % maximum step adopted to move along the line
        reliabilityIndex            % norm of the most probable point on the state boundary
    end
    
    properties (Dependent = true, SetAccess = protected)
        Nlinexbatch                 % number of lines per batch
        Nlinelastbatch              % number of lines in the last batch
        Nvars                       % number of variables
        CalphaNames                 % names of the corresponding directions (i.e. RandomVariable)
    end
    
    methods
        %% Methods inheritated from the superclass
        XsimOut=apply(Xobj,Xtarget)                             % Performe Monte Carlo Simulation
        
        [Xpf,XsimOut]=computeFailureProbability(Xobj,Xtarget)   % Esitmate FailureProbability
        
        Xsamples = sample(Xobj,varargin)                        % Generate samples using IS method
        
        %% Constructor
        function Xobj= AdaptiveLineSampling(varargin)
            % ADAPTIVELINESAMPLING This is the constructor of the
            % AdvancedLineSampling object.
            %
            % See also: https://cossan.co.uk/wiki/index.php/@AdaptiveLineSampling
            %
            % Author: Marco de Angelis and Edoardo Patelli
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
            
            %% Validate input arguments
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sbatchfolder'}
                        Xobj.SbatchFolder=varargin{k+1};
                    case 'stemppath'
                        Xobj.StemPath=varargin{k+1};
                    case {'cov'}    % from superclass
                        Xobj.CoV=varargin{k+1};
                    case {'timeout'}    % from superclass
                        Xobj.timeout=varargin{k+1};
                    case {'conflevel'}  % from superclass
                        Xobj.confLevel=varargin{k+1};
                    case 'acceptableerror'
                        Xobj.acceptableError=varargin{k+1};
                    case 'tolerance'
                        Xobj.tolerance=varargin{k+1};
                    case {'nsamples'}
                        Xobj.Nsamples=varargin{k+1};
                    case {'nlines'}
                        Xobj.Nlines=varargin{k+1};
                    case 'nmaxpoints'
                        Xobj.NmaxPoints=varargin{k+1};
                    case 'ncfine'
                        Xobj.Ncfine=varargin{k+1};
                    case {'nbatches'}
                        Xobj.Nbatches=varargin{k+1};
                    case 'nmaxdirectionalupdates'
                        Xobj.NmaxDirectionalUpdates=varargin{k+1};
                    case {'vdirectionsns','vdirectionstandardspace'}
                        Valpha=varargin{k+1};
                        Xobj.VdirectionSNS=Valpha(:)/norm(Valpha);
                    case {'vpointphysicalspace','vpointphy','vfailurepoint','vlimitstatepoint'}
                        VpntCoordPHY=varargin{k+1};
                        Xobj.VpointCoordPHY=VpntCoordPHY(:)';
                    case {'vdirectionphy','vdirectionphysicalspace','vgradient'}
                        Vdirect=varargin{k+1};
                        Xobj.VdirectionPHY=Vdirect(:);
                    case {'vimportanttails'}
                        VimpTails=varargin{k+1};
                        Xobj.VimportantTails=VimpTails(:)';
%                     case {'vpointphysical','vpointphysicalspace'}
%                           VimportancePoint=varargin{k+1};
% %                           Xobj.Vdirection=VpointPhy(:)/norm(VpointPhy);
%                     case {'mstatepoints','mlimitstatepoints'}
%                         Xobj.MstatePointsPHY=varargin{k+1};
%                     case {'mfailurepoints','mfailpoints'}
%                         Xobj.MfailurePointsPHY=varargin{k+1};
                    case 'xgradient'
                        Xgradient=varargin{k+1};
                        assert(isa(Xgradient,'opencossan.sensitivity.Gradient'),...
                            'openCOSSAN:simulations:AdaptiveLineSampling',...
                            'Invalid Gradient object. Please provide an object of class Gradient')
                        Xobj.VdirectionPHY=-Xgradient.Valpha;
                    case {'xgradientsns','xgradientstandardspace'}
                        XgradientSNS=varargin{k+1};
                        assert(isa(XgradientSNS,'opencossan.sensitivity.Gradient'),...
                            'openCOSSAN:simulations:AdaptiveLineSampling',...
                            'Invalid Gradient object. Please provide an object of class Gradient')
                        Xobj.VdirectionSNS=-XgradientSNS.Valpha;
                    case 'xlocalsensitivitymeasures'
                        XlocalSensMeasures=varargin{k+1};
                        assert(isa(XlocalSensMeasures,'opencossan.sensitivity.LocalSensitivityMeasures'),...
                            'openCOSSAN:simulations:AdaptiveLineSampling',...
                            'Invalid object. Please provide an object of class Local Sensitivity Measures')
                        Xobj.VdirectionSNS=-XlocalSensMeasures.Valpha;
                    otherwise
                        error('openCOSSAN:simulations:AdaptiveLineSampling',...
                            ['Field name (' varargin{k} ') not allowed']);
                end
            end % end process inputs
			
			
            %% check if temporary directory already exists
            if isempty(Xobj.StempPath)
                Xobj.StempPath=fullfile(opencossan.OpenCossan.getWorkingPath,'ALS_results#1');
                Xobj.SfolderName='ALS_results#1';
                [~,mess]=mkdir(Xobj.StempPath);
                
                if strcmpi(mess,'Directory already exists.')
                    % the directory existed
                    inum=0;
                    while strcmpi(mess,'Directory already exists.')
                        inum=1+inum;
                        Xobj.StempPath=fullfile(opencossan.OpenCossan.getWorkingPath,['ALS_results#',num2str(inum)]);
                        [~,mess]=mkdir(Xobj.StempPath);
                    end
                    Xobj.SfolderName=['ALS_results#',num2str(inum)];
                    rmdir(Xobj.StempPath,'s'); % this directory will be later created if the analysis is performed
                else
                    % the directory did not exist
                    rmdir(Xobj.StempPath,'s'); % this directory will be later created if the analysis is performed
                end
            end
            %% Check properties
            
            if Xobj.NmaxDirectionalUpdates<0
                warning('openCOSSAN:simulations:AdaptiveLineSampling',...
                    'The maximum number of updates must be a positive integer: this value will be set to 0')
                Xobj.NmaxDirectionalUpdates=0;
            end
            
            if Xobj.NmaxPoints<=0
                warning('openCOSSAN:simulations:AdaptiveLineSampling',...
                    'The maximum number of points on a line must be a positive integer: this value will be set to 10')
                Xobj.NmaxPoints=10;
            end
            
            if Xobj.Nlines<0
                warning('openCOSSAN:simulations:AdaptiveLineSampling',...
                    'The number of lines must be a positive integer: this value will be set to 10')
                Xobj.Nlines=10;
            end
            
            if Xobj.Nsamples<0
                warning('openCOSSAN:simulations:AdaptiveLineSampling',...
                    'The number of samples must be a positive integer: this value will be set to 50')
                Xobj.Nsamples=50;
            end
            
            if Xobj.Nbatches>Xobj.Nlines % each batch shall contain results from whole lines
                warning('openCOSSAN:simulations:AdaptiveLineSampling',...
                    strcat('The number of batches (', num2str(Xobj.Nbatches), ...
                    ') can not be greater than the number of Lines (', ...
                    num2str(Xobj.Nlines), '): this value will be set to 1'));
                Xobj.Nbatches=1;
            end
            
            if ~isempty(Xobj.VdirectionSNS) || ~isempty(Xobj.VdirectionPHY)% || ~isempty(Xobj.VimportancePoint)
                if ~isempty(Xobj.VpointCoordPHY)
                    warning('openCOSSAN:simulations:AdaptiveLineSampling',...
                        'The direction exists already, additional point coordinates will be dismissed')
                end
            end
            
            if isempty(Xobj.VdirectionSNS) && isempty(Xobj.VdirectionPHY) && isempty(Xobj.VpointCoordPHY) && isempty(Xobj.VimportantTails) 
                warning('openCOSSAN:simulations:AdaptiveLineSampling',...
                        'No direction provided, the important direction will be recomputed')
            end
        end % of constructor
        
        function Nlinexbatch = get.Nlinexbatch(Xobj)
            Nlinexbatch = floor(Xobj.Nlines/Xobj.Nbatches);
        end % Modulus get method
        
        function Nlinelastbatch = get.Nlinelastbatch(Xobj)
            Nlinelastbatch =  Xobj.Nlinexbatch+rem(Xobj.Nlines,Xobj.Nbatches);
        end % Modulus get method
        
        function Nvars = get.Nvars(Xobj)
            Nvars = length(Xobj.VdirectionSNS);
        end
        
    end % of methods
    
    methods (Access = private)
        
        [Xobj,XlineSimOut,reliabilityIndex,Valpha,stateFlag0,NevalPoints, XsamplesInput] = ...
            computeReliabilityIndex(Xobj,Xtarget);
        
        [VhyperPlanePoint,lineIndex,subsequentLineIndex,CindexProcessedLines]=...
            projectPoints(Xobj,varargin);
        
        [Xobj,Tline,XpartialSimOut,Xsamples]=...
            exploitLine(Xobj,Xtarget,varargin)
        
        [pfhat,variancepf]=...
            computeLineProbabilities(Xobj,varargin)
        
        [Xobj,Valpha] = initialiseImportantDirection(Xobj,Xtarget)
        
        varargout = lineSearch(Xobj,varargin)
        
        varargout = assignStateFlag(Xobj,Vd,Vg,iLine,Valpha,Vlhp)
        
    end % of private methods
    
    
    methods(Static)
        varargout=makeString4TextFile(varargin)
    end % of static methods
    
end % end of class definition

