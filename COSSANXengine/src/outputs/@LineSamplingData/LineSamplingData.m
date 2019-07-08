classdef LineSamplingData<SimulationData
    % LINESAMPLINGDATA class
    %   This class collect outputs and data resulting from the LineSampling
    %   or the AdvancedLineSampling simulation.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@LineSamplingData
    %
    % Author: Marco de Angelis
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
    
    
    properties (SetAccess = protected)
        Nvars                    % number of variables or dimension
        NprocessedLines          % total number of processed lines
        NeffectiveLines          % number of lines effectively used for computing conditional probabilities
        NcrossingLines           % number of lines that cross the state boundary
        NdirectionUpdates        % number of direction updates
        SperformanceFunctionName % name of the output of the PerformanceFunction
        Tlines=struct            % strcture containing Line Sampling Data
        Tdata=struct             % strcture containing data for all the line processed
        MrandReferencePoints     % coordinates of reference points
        VimportantDirection      % final important direction
        VupdatedDirection        % current important direction   
        VinitialDirection        % initial important direction   
        reliabilityIndex         % norm of the most probable point on the state boundary
        CMstatePoints={};        % storing cell for boundary state points in physical space
        Xinput                   % Input object
        pfInterval               % probability of failure based on the available points, assuming unclassified points both as fail and safe points
        covpfInterval            % coefficient of variation of estimator of pfhat
        Xpf                      % Failure Probability Object
        Xsimulator               % Simulator used to compute the probability (AdvancedLineSampling, LineSampling)
    end
    
    properties (Dependent = true, SetAccess = protected)
        MlimitStatePointsStandard% matrix of limit state points in SNS
        MlimitStatePointsPhysical% matrix of limit state points in physical space
        MsamplePoints            % all the sample points
        VnumPointLine            % # of points on each line
        VdistancePlane           % all distances from the orthogonal hyper-plane
        VdistanceOrigin          % all distances from the origin in SNS
        Npoints                  % total # of points
        Nbatches                 % # of batches
        Nlines                   % number of lines as specified by the user
    end
    
    methods
        
        function Xobj=LineSamplingData(varargin)
            %LINESAMPLINGDATA
            % This object stores the results of the simulation performed by
            % AdvancedLineSampling or LineSampling
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@LineSamplingData
            %
            % Author: Marco de Angelis
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            
            OpenCossan.validateCossanInputs(varargin{:});
            % Initialize variables
            Sname=[];
            Vindex=[];
            ibatch=0;
            iLine=[];
            Xinp=[];
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sperformancefunctionname'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Sname = varargin{k+1};
                    case {'vlinehyperplanepoint','vstartpoint'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VlineHyperPlanePoint = varargin{k+1};
                    case {'vlinedistances'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VlineDistances = varargin{k+1};
                    case {'xsimulationdata'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        XsimOut=varargin{k+1};
                    case 'xinput'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Xinp=varargin{k+1};
                    case {'vstatepoint'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VstatePoint=varargin{k+1};
                    case {'valpha','vimportantdirection'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Valpha=varargin{k+1};
                        Valpha=Valpha(:)/norm(Valpha);
                    case {'vdirectionphysical','vdirectionphysicalspace'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Vdirection=varargin{k+1};
                    case 'vpointphysical'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VpointPhy=varargin{k+1};
                    case 'vinitialdirection'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VinitialDir=varargin{k+1};
                    case 'xgradient'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Xgradient=varargin{k+1};
                    case {'distancelimitstate'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        distanceLimitState=varargin{k+1};
                    case {'reliabilityindex'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        rIndex=varargin{k+1};
                    case {'iline','linenumber'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        iLine=varargin{k+1};
                    case {'lupdatedirection'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        LupdateDirection=varargin{k+1};
                    case {'stateflag'}
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        stateFlag=varargin{k+1};
                    case 'lineindex'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        lineIndex=varargin{k+1};
                    case 'mrandreferencepoints'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        MrefSNS=varargin{k+1};
                    case 'vperformancevalues'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VperformanceValues=varargin{k+1};
                    case 'xsimulator'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Xsimulatore=varargin{k+1};
                    case 'ibatch'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                        ibatch=varargin{k+1};
                    otherwise
                        error('openCOSSAN:LineSamplingOutput',...
                            'PropertyName %s not allowed', varargin{k})
                end
            end % for k
            
            varargin(Vindex)=[];
            % Call constructor superclass
            Xobj=Xobj@SimulationData(varargin{:});
            
            Xobj.SperformanceFunctionName=Sname;
            
            Xobj.Xinput=Xinp;
            
            if ~exist('XsimOut','var')
                % create an empty structure
                Xobj.Tvalues=struct;
            else
                Xobj.Tvalues=XsimOut.Tvalues;
            end
            
            if exist('VinitialDir','var')
                Xobj.VinitialDirection=VinitialDir;
            end
            
            
            if exist('Xsimulatore','var')
               Xobj.Xsimulator=Xsimulatore;
            end
            
            % Define important direction from the Physical space
            if exist('Vdirection','var') % given a direction
                refPointPhysical=Xobj.Xinput.getMoments'+Vdirection;
                refPointSns=Xobj.Xinput.map2stdnorm(refPointPhysical);
                Valpha=refPointSns(:)/norm(refPointSns);
            elseif exist('VpointPhy','var') % given a point
                refPointPhysical=VpointPhy(:);
                refPointSns=Xobj.Xinput.map2stdnorm(refPointPhysical);
                Valpha=refPointSns/norm(refPointSns);
            end

            %% Create Object
            
            Tline=struct;
            
            if isa(Xobj.Xsimulator,'AdvancedLineSampling')
                Tline.VreferencePoint=[];
            end
            
            if exist('VperformanceValues','var')
                Tline.VperformanceValues=VperformanceValues;
            else
                Tline.VperformanceValues=[];
            end
            
            if exist('Valpha','var')
                Xobj.Nvars=length(Valpha);
                Xobj.VimportantDirection=Valpha;
                Tline.Valpha=Valpha;
            elseif exist('Xgradient','var')
                Valpha=-Xgradient.Valpha;
                Xobj.VimportantDirection=Valpha;
                Tline.Valpha=Valpha;
            else
                Tline.Valpha=[];
%                 error('openCOSSAN:LineSamplingData',...
%                     'The important direction is a mandatory argument');
            end
            
            
            if exist('XsimOut','var')
                Tline.XSimulationData=XsimOut;
            else
                Tline.XSimulationData=[];
            end
            
            
            if exist('rIndex','var')
                Xobj.reliabilityIndex=rIndex;
            else
                Xobj.reliabilityIndex=[];
            end
            
            
            if exist('VlineDistances','var')
                Tline.VlineDistances=VlineDistances;
                Tline.NlinePoints = length(VlineDistances);
            else
                Tline.VlineDistances=[];
                Tline.NlinePoints=[];
            end
            
            
            if exist('VlineHyperPlanePoint','var')
                Tline.VlineHyperPlanePoint=VlineHyperPlanePoint;
                assert(length(VlineHyperPlanePoint)==Xobj.Nvars,...
                    'openCOSSAN:LineSamplingData',...
                    'Number of components in <<%s>> is %i while it should be %i!',...
                    'VlineHyperPlanePoint',length(VlineHyperPlanePoint),Xobj.Nvars);
            else
                Tline.VlineHyperPlanePoint=[];
            end
            
            
            if exist('VstatePoint','var')
                if isempty(Xobj.CMstatePoints)
                    Xobj.CMstatePoints{1}=transpose(Xinp.map2physical(VstatePoint(:)'));
                else
                    Xobj.CMstatePoints{end+1}=transpose(Xinp.map2physical(VstatePoint(:)'));
                end
                Tline.CVstatePoints{1}=VstatePoint;
                Tline.CVstatePointsPhysical{1}=transpose(Xinp.map2physical(VstatePoint(:)'));
                Tline.normStatePoint=norm(VstatePoint);
                Tline.distanceLimitState=distanceLimitState;
                Tline.directionCosine=VstatePoint(:)'*Valpha(:)/norm(VstatePoint);
            else
                Tline.CVstatePoints=cell(1);
                Tline.CVstatePointsPhysical{1}=[];
                Tline.normStatePoint=[];
                Tline.distanceLimitState=[];
                Tline.directionCosine=[];
            end
            
            
            
            if isa(Xobj.Xsimulator,'AdvancedLineSampling')
                if exist('LupdateDirection','var')
                    Tline.LupdateDirection=LupdateDirection;
                    assert(isa(LupdateDirection,'logical'),...
                        'openCOSSAN:LineSamplingData',...
                        'The variable <<%s>> must be logical',...
                        'LupdateDirection');
                else
                    Tline.LupdateDirection=[];
                end
            end
            
            if exist('stateFlag','var')
                Tline.stateFlag=stateFlag;
            else
                Tline.stateFlag=[];
            end
            
            if exist('lineIndex','var')
                Tline.lineIndex=lineIndex;
            else
                Tline.lineIndex=[];
            end
            
            if exist('MrefSNS','var')
                Xobj.MrandReferencePoints=MrefSNS;
                assert(size(Xobj.MrandReferencePoints,1)==Xobj.Nvars,...
                    'openCOSSAN:LineSamplingData',...
                    'The property <<%s>> must have the number of columns equal to the number of Lines',...
                    'MrandReferencePoints')
            else
                Xobj.MrandReferencePoints=[];
            end
            
            if isa(Xobj.Xsimulator,'AdvancedLineSampling')
                Tline.Nreprocessed=0;
            end
            
            % This property is used by ALS for remapping. "lineRank" ranks
            % the lines accordingly to how the information on the line
            % are used to compute the partial probabilities (PP). If the
            % rank is "lineRank=0" means the line has not provided any
            % info, if "lineRank=1" the line identified a PP but using
            % others' lines information (i.e. by interpolation).  While if
            % "lineRank=2" the line identified a PP by means of a full analysis.
            if isa(Xobj.Xsimulator,'AdvancedLineSampling')
                Tline.lineRank=[];
            end
            
            Tline.ibatch=ibatch;
            
            Xobj.Tlines=struct(strcat('Line_',num2str(iLine)),Tline);
            
            CTlines=struct2cell(Xobj.Tlines);
            Xobj.Tdata=[CTlines{:}];
            
            
        end % end constructor
        
        % Dependent property
        function MlimitStatePointsPhysical=get.MlimitStatePointsPhysical(Xobj)
            MlimitStatePointsPhysical=cell2mat(Xobj.CMstatePoints);            
        end
        
        % Dependent property
        function MlimitStatePointsStandard=get.MlimitStatePointsStandard(Xobj)
            MlimitStatePointsStandard=Xobj.Xinput.map2stdnorm(cell2mat(Xobj.CMstatePoints));
        end
        
        % Dependent property
        function MsamplePoints=get.MsamplePoints(Xobj)
            CVhyperPlanePoints={Xobj.Tdata.VlineHyperPlanePoint};
            CValpha={Xobj.Tdata.Valpha};
            CVlineDistances={Xobj.Tdata.VlineDistances};
            CNlinePoints={Xobj.Tdata.NlinePoints};
            iStart=1;
            if isempty(horzcat(Xobj.Tdata.NlinePoints))
                MsamplePoints=[];
            else
                for n=1:length(Xobj.Tdata)
                    iEnd=iStart+CNlinePoints{n}-1;
                    MsamplePoints(:,iStart:iEnd)=repmat(CVhyperPlanePoints{n},1,CNlinePoints{n})+...
                        CValpha{n}*CVlineDistances{n};
                    iStart=iEnd+1;
                end
            end
        end
        
        % Dependent property
        function VnumPointLine=get.VnumPointLine(Xobj)
            VnumPointLine=[Xobj.Tdata.NlinePoints];
        end
        
        % Dependent property
        function VdistancePlane=get.VdistancePlane(Xobj)
            VdistancePlane=[Xobj.Tdata.VlineDistances];
        end
        
        % Dependent property
        function VdistanceOrigin=get.VdistanceOrigin(Xobj)
            MallPoints=Xobj.MsamplePoints;
            VdistanceOrigin=sqrt(sum(MallPoints.^2,1));
        end
        
        % Dependent property
        function Npoints=get.Npoints(Xobj)
            Npoints=size(Xobj.MsamplePoints,2);
        end
        
        % Dependent property
        function Nbatches=get.Nbatches(Xobj)
            Nbatches=max([Xobj.Tdata.ibatch]);
            if Nbatches==0
                Nbatches=1;
            end
        end
        
        
        % Dependent property
        function Nlines=get.Nlines(Xobj)
            Nlines=sum(horzcat(Xobj.Tdata.lineIndex)~=0);
            if isempty(Nlines)
                Nlines=0;
            end
        end
        
        
        % Dependent property
        function reliabilityIndex=get.reliabilityIndex(Xobj)
            reliabilityIndex=min([Xobj.Tdata.normStatePoint]);     
        end
        
        % Dependent property
        function VupdatedDirection=get.VupdatedDirection(Xobj)
                [~,posID]=min([Xobj.Tdata.normStatePoint]);
                CViD=[Xobj.Tdata.CVstatePoints];
                VupdatedDirection=CViD{posID};
                VupdatedDirection=VupdatedDirection/norm(VupdatedDirection);
                VupdatedDirection=VupdatedDirection(:);
        end
        
        function save(Xobj,varargin)
            % Calling superclass method
            save@SimulationData(Xobj,varargin{:})
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Check Inputs
            for k=1:2:nargin-1
                switch lower(varargin{k})
                    case {'sfilename'}
                        %check input
                        SfileName = varargin{k+1};
                        
                end
            end
            LineSamplingReserved_SperformanceFunctionName=Xobj.SperformanceFunctionName; %#ok<NASGU>
            LineSamplingReserved_VnumPointLine=Xobj.VnumPointLine; %#ok<NASGU>
            LineSamplingReserved_Vdistance=Xobj.VdistanceOrigin; %#ok<NASGU>
            LineSamplingReserved_VdistancePlane=Xobj.VdistancePlane; %#ok<NASGU>
            save(SfileName,'LineSamplingReserved_SperformanceFunctionName', ...
                'LineSamplingReserved_VnumPointLine', ...
                'LineSamplingReserved_VdistancePlane', ...
                'LineSamplingReserved_Vdistance','-append')
        end
        
        Xobj = merge(Xobj,Xobj2)
        Xobj = add(Xobj,varargin)
        Xobj = update(Xobj,variable)
        Xobj = addStatePoints(Xobj,Cpoints,varargin)
        varargout=plotLines(Xobj,varargin)
        varargout=plotResults(Xobj,varargin)
        [orogin,distance,cosine]=Map2ReducedSpace(Xobj,varargin)
        Xobj = getFailureProbability(Xobj,varargin)
        Xobj = addInputObject(Xobj,Xinput)
        Xobj = addFailureProbabilityObject(Xobj,Xpf)
        varargout=plotLimitState(Xobj,varargin)
        
        
        
    end % Methods
    
    
    
    methods  (Static)
        function XLineSamplingData=load(varargin)
            % Calling superclass method
            Xout=load@SimulationData(varargin{:});
            
            % Check Inputs
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sfilename'}
                        check input
                        SfileName = varargin{k+1};
                end
            end
            
            load(SfileName,'LineSamplingReserved_*');
            
            if isempty(LineSamplingReserved_VnumPointLine)
                XLineSamplingData=LineSamplingData('XsimulationData',Xout, ...
                    'SperformanceFunctionName',LineSamplingReserved_SperformanceFunctionName);
            else
                XLineSamplingData=LineSamplingData('XsimulationData',Xout, ...
                    'VnumPointLine',LineSamplingReserved_VnumPointLine, ...
                    'Vdistanceorthogonalplane',LineSamplingReserved_VdistancePlane, ...
                    'Vdistance',LineSamplingReserved_Vdistance, ...
                    'SperformanceFunctionName',LineSamplingReserved_SperformanceFunctionName);
            end
        end % load
    end % static methods
    
end

