classdef LineSamplingOutput < opencossan.common.outputs.SimulationData
    %LINESAMPLINGOUTPUT class containing speific outputs of the
    %LineSampling simulation method
    %
    % See also: https://cossan.co.uk/wiki/index.php/@LineSamplingOutput
    %
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
    
    properties (SetAccess = public)
        SmainPath                % Path with analysis results
        SfolderName              % Name of the folder containing results
    end
    
    properties (SetAccess = protected)
        Nlines                   % Number of Lines as specified by the user
        NprocessedLines          % Number of processed lines (either =Nlines or =Nlines+1)
        Nvars                    % Number of state variables
        NdirectionalUpdates
        NlinesInFailureDomain
        NlinesInSurvivalDomain
        SperformanceFunctionName % name of the output of the PerformanceFunction
        VdistancePlane           % Evaluation point along the line (distance from the hyper-plane orthogonal to the important direction)
        VdistanceOrigin          % distance of line points from the origin in SNS (norm in SNS)
        VlimitStateDistances     % distance to the limit state (from hyperplane) for each line
        VnumPointLine            % # of points on each line
        VinitialDirectionSNS     % important direction coordinates at the start of analysis in the Standarad Space
        VlastDirectionSNS        % important direction coordinates at the end of analysis in the Standarad Space
        initialMostProbPointNorm % norm of the initial most probable point on the state boundary
        lastMostProbPointNorm    % norm of the final most probable point on the state boundary
        Tline                    % structure with information for each line
        Xinput                   % input object to map points to physical space
        Lals=false               % condition for adaptive Line Sampling
        LdeleteResults=false          % 
    end
    
    properties (Dependent = true, SetAccess = protected)
        Npoints                  % Total number of points
        Nevaluations             % Number of evaluations   
        MlimitStateCoordsSNS     % 
        MlimitStateCoordsPHY     % 
        MimportantDirectionSNS   % 
        MimportantDirectionPHY   % 
        MhyperplaneCoordsSNS     % 
        MhyperplaneCoordsPHY     % 
        MconstellationPointsSNS  % 
        MconstellationPointsPHY  % 
        VinitialDirectionPHY     % important direction coordinates at the start of analysis in the Physical Space
        VlastDirectionPHY        % important direction coordinates at the end of analysis in the Physical Space
        mostProbablePointNorm    % norm of the most probable point found
        failureProbabilityEstimate % estimation of the failure probability using LineSampling
    end
    
    methods
        
        function Xobj=LineSamplingOutput(varargin)
            %LINESAMPLINGOUTPUT
            % This object stores the results of the simulation performed by
            % LineSampling
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@LineSamplingOutput
            %
            % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            % Author: Marco de Angelis and Edoardo Patelli

            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            % Initialize variables
            Vindex=[];
            Carginputs={};
            if nargin==0
                
            end

            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sperformancefunctionname'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Sname = varargin{k+1};    
                    case {'ldeleteresults'}
                        Ldel = varargin{k+1}; 
                    case {'vnumpointline'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        % the field SoutputName is always a column vector
                        if isrow(varargin{k+1})
                            Vpoints = varargin{k+1}';
                        else
                            Vpoints = varargin{k+1};
                        end
                    case {'vnorm','vdistance','vdistanceorigin'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VpointNorm = varargin{k+1}; 
                        if ~isrow(VpointNorm)
                            VpointNorm=VpointNorm'; 
                        end
                    case {'vdistanceorthogonalplane'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VdistanceOrthPlane = varargin{k+1};
                        if ~isrow(VdistanceOrthPlane)
                            VdistanceOrthPlane=VdistanceOrthPlane';
                        end
                    case 'smainpath'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        StempPath = varargin{k+1};
                    case {'initialmostprobablepointnorm'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        initialMostProbablePointNorm=varargin{k+1};
                    case {'lastmostprobablepointnorm'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        lastMostProbablePointNorm=varargin{k+1};
                    case {'vinitialdirectionsns','vdirectionsns'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VinitialDirectSNS=varargin{k+1};
                    case {'vlastdirectionsns'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VlastDirectSNS=varargin{k+1};
                    case 'vlinenumber'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VlineNumber=varargin{k+1};
                    case 'vlineindex'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VlineIndex=varargin{k+1};
                    case 'vdirectionnumber'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VdirectionNumber=varargin{k+1};
                    case 'vlimitstatedistance'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VdistanceLimitState=varargin{k+1};
                    case 'vlimitstatenorm'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        VlimitStateNorm=varargin{k+1};
                    case 'lupdate'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Lupdate=varargin{k+1};
                    case 'xinput'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        Xinp=varargin{k+1};
                    case 'sdescription'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                    case 'sexitflag'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                    case 'sbatchfolder'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                    case 'table'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>
                    case 'mvalues'
                        Vindex=[Vindex k k+1]; %#ok<AGROW>    
                    case {'xsimulationdata'}
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        XsimOut=varargin{k+1};
                        CpropertiesSuperClass={'Sdescription','SexitFlag','SbatchFolder','TableValues'};
                        CnamePropertiesSuperClass={'Sdescription','SexitFlag','SbatchFolder','Table'};
                        
                        CdependentProperties={'Cnames','CnamesDataseries','Nsamples','NmissingData','Ldataseries'};
                        h=1;
                        for n=1:length(CpropertiesSuperClass)
                            if isempty(XsimOut.(CpropertiesSuperClass{n})) || any(strcmpi(CpropertiesSuperClass{n},CdependentProperties))
                            else
                                Carginputs{h}=CnamePropertiesSuperClass{n}; %#ok<AGROW>
                                Carginputs{h+1}=XsimOut.(CpropertiesSuperClass{n}); %#ok<AGROW>
                                h=h+2;
                            end
                        end
                    case 'ladaptivelinesampling'
%                         Vindex=[Vindex k k+1]; %#ok<AGROW>
                        LadaptiveLineSampling=varargin{k+1};
                    otherwise
                        error('openCOSSAN:LineSamplingOutput',...
                            'PropertyName %s not allowed', varargin{k})
                end
            end % for k
            
%             varargin(Vindex)=[];
            %% Preprocessing
            % Split user arguments
%             CpropertiesSuperClass=properties(XsimOut);
            
%             CspecialProperties={'Cnames','CnamesDataseries','Nsamples','LisDataseries'};
%             h=1;
%             for n=1:length(CpropertiesSuperClass)
%                 if isempty(XsimOut.(CpropertiesSuperClass{n})) || ...
%                         any(strcmpi(CpropertiesSuperClass{n},CspecialProperties))
%                 else
%                     Carginputs{h}=CpropertiesSuperClass{n}; %#ok<AGROW>
%                     Carginputs{h+1}=XsimOut.(CpropertiesSuperClass{n}); %#ok<AGROW>
%                     h=h+2;
%                 end
%             end
%             
%             % Call constructor superclass
%             Xobj=Xobj@common.outputs.SimulationData(Carginputs{:});
%             OpenCossan.validateCossanInputs(varargin{:});
            %% Merge information from superclass
%             CpropertiesSuperClass=properties(XsimOut);

                CarginputsAdd=varargin(Vindex);
                Carginputs=[Carginputs, CarginputsAdd];

            
            % Call constructor superclass
            Xobj=Xobj@opencossan.common.outputs.SimulationData(Carginputs{:});
            %% Validate Object
            if exist ('LdeleteResults','var')
                Xobj.LdeleteResults=Ldel;
            end
            if exist('LadaptiveLineSampling','var')
                Xobj.Lals=LadaptiveLineSampling;
                Xobj.SmainPath=StempPath;
            end
            if Xobj.Lals
                % check if main path of results exists
                assert(~isempty(Xobj.SmainPath),...
                    'openCOSSAN:LineData',...
                    'The main path with the simulation results has not been passed to the object')
                
                [status,~]=system(['mkdir ',Xobj.SmainPath]);
                if status == 0
                    error('openCOSSAN:LineData',...
                        'The main path with the simulation cannot be created');
                    % TODO: delete created directory
                end
            end
            
            Xobj.VnumPointLine=Vpoints;
            Ntotalpoints=Xobj.Npoints;
            if exist('VdistanceOrthPlane','var')
                Xobj.VdistancePlane=VdistanceOrthPlane;
                     assert(length(Xobj.VdistancePlane)==Ntotalpoints,...
                'openCOSSAN:LineSamplingOutput',...
                'Number of points in VdistanceOrthogonalPlane is %i and it should be %i!',...
                length(Xobj.VdistancePlane),Ntotalpoints);
            end
            
            if exist('VpointNorm','var')
                Xobj.VdistanceOrigin=VpointNorm;
                 assert(length(Xobj.VdistanceOrigin)==Ntotalpoints,...
                'openCOSSAN:LineSamplingOutput',...
                'Number of points in VdistanceOrigin is %i and it should be %i!',...
                length(Xobj.VdistanceOrigin),Ntotalpoints);
            end
            
            Xobj.Nlines=length(Xobj.VnumPointLine);
            if exist('VdistanceLimitState','var')
                Xobj.VlimitStateDistances=VdistanceLimitState;
                assert(length(Xobj.VlimitStateDistances)==Xobj.Nlines,...
                'openCOSSAN:LineSamplingOutput',...
                'Number of points in VlimitStateDistances, %i, should be equal to the nummber of lines, %i',...
                length(Xobj.VlimitStateDistances),Xobj.Nlines);
            end
%             % Merge XsimOut with the current object
%             if exist('XsimOut','var')
%                 Xobj=Xobj.merge(XsimOut);
%             end
            %% Construct the object 
            Xobj.SperformanceFunctionName=Sname;
            
            Xobj.VinitialDirectionSNS=VinitialDirectSNS;
            Xobj.Nvars=length(VinitialDirectSNS);
            
            Xobj.Xinput=Xinp;
            
            if Xobj.Lals
                Xobj.SmainPath=StempPath;
                
                Xobj.initialMostProbPointNorm=initialMostProbablePointNorm;
                Xobj.lastMostProbPointNorm=lastMostProbablePointNorm;
                
                Xobj.VlastDirectionSNS=VlastDirectSNS;
            end
            %% Construct the object
            if Xobj.Lals
                Xobj.NprocessedLines=VlineNumber(end);
            else
                Xobj.NprocessedLines=Xobj.Nlines;
            end
            
            % Retrieve performance function values
            SperformFunctName=Xobj.SperformanceFunctionName;
            Vg=Xobj.getValues('Sname',SperformFunctName);
            
            if Xobj.Lals
                iend=0;
                for iLine=1:Xobj.NprocessedLines
                    istart=iend+1;
                    numPointLine=Xobj.VnumPointLine(iLine);
                    iend=numPointLine+istart-1;
                    
                    VnLine=Xobj.VdistanceOrigin(istart:iend);
                    VdLine=Xobj.VdistancePlane(istart:iend);
                    VgLine=Vg(istart:iend);
                    
                    if VlineIndex(iLine)==0
                        Xobj.Tline(iLine).description='Line #0 (through the origin of SNS)';
                    else
                        Xobj.Tline(iLine).description=['Line #',num2str(VlineNumber(iLine))];
                    end
                    Xobj.Tline(iLine).lineNumber=VlineNumber(iLine);
                    Xobj.Tline(iLine).lineIndex=VlineIndex(iLine);
                    Xobj.Tline(iLine).numPointLine=numPointLine;
                    
                    Xobj.Tline(iLine).VdistancesOrthPlane=VdLine;
                    Xobj.Tline(iLine).VlinePointsNorm=VnLine;
                    Xobj.Tline(iLine).VperformanceValues=VgLine;
                    
                    Xobj.Tline(iLine).distanceLimitState=VdistanceLimitState(iLine);
                    Xobj.Tline(iLine).limitStateNorm=VlimitStateNorm(iLine);
                    Xobj.Tline(iLine).directionNumber=VdirectionNumber(iLine);
                    Xobj.Tline(iLine).Lupdate=Lupdate(iLine);
                end
                Xobj.NdirectionalUpdates=VdirectionNumber(end);
            end
            %% Clear directory from results
            if Xobj.LdeleteResults
                status=rmdir(Xobj.SmainPath,'s');
                assert(status==1,...
                    'openCOSSAN:LineData',...
                    'Directory containing all results could not be deleted')
            end
        end % end constructor
        
        % Dependent properties
        function Npoints = get.Npoints(Xobj)
            Npoints =sum(Xobj.VnumPointLine); % this shall coincide with the total number of samples
        end
        
        function Nevaluations = get.Nevaluations(Xobj)
            Nevaluations =length(Xobj.getValues('Sname',Xobj.SperformanceFunctionVariable)); % this shall coincide with the total number of samples
        end
        
        
        function NlinesInFailureDomain = get.NlinesInFailureDomain(Xobj)
            NlinesInFailureDomain=sum(double(Xobj.VlimitStateDistances==Inf));
        end
        
        function NlinesInSurvivalDomain = get.NlinesInSurvivalDomain(Xobj)
            NlinesInSurvivalDomain=sum(double(Xobj.VlimitStateDistances==-Inf));
        end
        
        function mostProbablePointNorm = get.mostProbablePointNorm(Xobj)
            if Xobj.Lals
                mostProbablePointNorm=Xobj.lastMostProbPointNorm;
            else
                mostProbablePointNorm=min(sqrt(sum(Xobj.MlimitStateCoordsSNS.^2,1)));
            end
        end
        
        function failureProbabilityEstimate = get.failureProbabilityEstimate(Xobj)
            failureProbabilityEstimate=mean(normcdf(-Xobj.VlimitStateDistances));
        end
        
        function VinitialDirectionPHY=get.VinitialDirectionPHY(Xobj)
            VpoleStarCoordinatesSNS=Xobj.VinitialDirectionSNS;
            VpoleStarCoordinatesPHY=Xobj.Xinput.map2physical(VpoleStarCoordinatesSNS(:)');
            VmedianState=Xobj.Xinput.map2physical(zeros(1,Xobj.Nvars));
            VinitialDirectionPHY=VpoleStarCoordinatesPHY-VmedianState;
        end
        
        function VlastDirectionPHY=get.VlastDirectionPHY(Xobj)
            VpoleStarCoordinatesSNS=Xobj.VlastDirectionSNS;
            VpoleStarCoordinatesPHY=Xobj.Xinput.map2physical(VpoleStarCoordinatesSNS(:)');
            VmedianState=Xobj.Xinput.map2physical(zeros(1,Xobj.Nvars));
            VlastDirectionPHY=VpoleStarCoordinatesPHY-VmedianState;
        end
        
        function MlimitStateCoordsSNS=get.MlimitStateCoordsSNS(Xobj)
            if Xobj.Lals
                % extract coordinates of limit state points
                fid = fopen([Xobj.SmainPath,filesep,'MlimitStateCoords.txt'], 'r');
                if fid<0
                    error('OpenCOSSAN:LineData',...
                        'Unable to find the file with results')
                else
                    MlspSNS = fscanf(fid, '%e', [Xobj.Nvars inf]);
                    fclose(fid);
                    MlimitStateCoordsSNS=transpose(MlspSNS);
                end
            else
                % extract random variable names
                Cnames=Xobj.Xinput.RandomVariableNames; % to check with multiple random variable sets
                % extract evaluation points
                CMxLines=cell(1,Xobj.NprocessedLines);
                CMsLines=cell(1,Xobj.NprocessedLines);
                % matrix with evaluation points
                MX=transpose(Xobj.getValues('CSnames',Cnames));
                Valpha=Xobj.VinitialDirectionSNS;
                MlspSNS=zeros(length(Valpha),Xobj.NprocessedLines);
                istart=1;
                for iLine=1:Xobj.NprocessedLines
                    iend=istart+Xobj.VnumPointLine(iLine)-1;
                    Mx=MX(:,istart:iend);
                    Ms=Xobj.Xinput.map2stdnorm(Mx);
                    CMxLines{iLine}=Mx;
                    CMsLines{iLine}=Ms;
                    % calculate coordinates of limit state point
                    c=Xobj.VdistancePlane(istart);
                    d=Xobj.VlimitStateDistances(iLine);
                    MlspSNS(:,iLine)=Ms(:,1)+(d-c)*Valpha;
                    istart=iend+1;
                end
                MlimitStateCoordsSNS=MlspSNS;
            end
        end
        
        function MlimitStateCoordsPHY=get.MlimitStateCoordsPHY(Xobj)
%             MlspPHY=zeros(Xobj.NprocessedLines,Xobj.Nvars);
%             for n=1:Xobj.NprocessedLines
%                 MlspPHY(n,:)=Xobj.Xinput.map2physical(Xobj.MlimitStateCoordsSNS(n,:));
                MlspPHY=Xobj.Xinput.map2physical(Xobj.MlimitStateCoordsSNS);
                MlimitStateCoordsPHY=MlspPHY;
%             end
        end
        
        function MimportantDirectionSNS=get.MimportantDirectionSNS(Xobj)
            if Xobj.Lals
                % extract all important directions (Standard Normal Space)
                fid = fopen(fullfile(Xobj.SmainPath,'MimportantDirections.txt'), 'r');
                if fid<0
                    error('openCOSSAN:LineData',...
                        'Unable to find the file with results')
                else
                    Mid = fscanf(fid, '%e', [Xobj.Nvars inf]);
                    fclose(fid);
                    MimportantDirectionSNS=transpose(Mid);
                end
            else
%                 MimportantDirectionSNS=[];
                VinitialDirectSNS=Xobj.VinitialDirectionSNS(:)';
                MimportantDirectionSNS=repmat(VinitialDirectSNS,Xobj.NprocessedLines,1);
            end
        end
        
        function MimportantDirectionPHY=get.MimportantDirectionPHY(Xobj)
            if Xobj.Lals
            MimportantDirectionPHY=zeros(Xobj.NprocessedLines,Xobj.Nvars);
            for n=1:Xobj.NprocessedLines
                % important directions in Physical Space
                VpoleStarCoordinatesSNS=Xobj.MimportantDirectionSNS(n,:);
                VpoleStarCoordinatesPHY=Xobj.Xinput.map2physical(VpoleStarCoordinatesSNS(:)');
                VmedianState=Xobj.Xinput.map2physical(zeros(1,Xobj.Nvars));
                VdirectionPHY=VpoleStarCoordinatesPHY-VmedianState;
                MimportantDirectionPHY(n,:)=VdirectionPHY(:)'/norm(VdirectionPHY);
            end
            else
                VinitialDirectPHY=Xobj.VinitialDirectionPHY;
                MimportantDirectionPHY=repmat(VinitialDirectPHY,Xobj.NprocessedLines,1);
            end
        end
        
        function MhyperplaneCoordsSNS=get.MhyperplaneCoordsSNS(Xobj)
            if Xobj.Lals
                % extract coordinates of limit state points
                fid = fopen(fullfile(Xobj.SmainPath,'MhyperplaneCoords.txt'), 'r');
                if fid<0
                    error('OpenCOSSAN:LineData',...
                        'Unable to find the file with results')
                else
                    MhpSNS = fscanf(fid, '%e', [Xobj.Nvars inf]);
                    fclose(fid);
                    MhyperplaneCoordsSNS=transpose(MhpSNS);
                end
            else
                MhyperplaneCoordsSNS=[];
            end
        end
        
        function MhyperplaneCoordsPHY=get.MhyperplaneCoordsPHY(Xobj)
            if Xobj.Lals
                MhpPHY=zeros(Xobj.NprocessedLines,Xobj.Nvars);
                for n=1:Xobj.NprocessedLines
                    MhpPHY(n,:)=Xobj.Xinput.map2physical(Xobj.MhyperplaneCoordsSNS(n,:));
                    MhyperplaneCoordsPHY=transpose(MhpPHY);
                end
            else
                MhyperplaneCoordsPHY=[];
            end
        end
        
        function MconstellationPointsSNS=get.MconstellationPointsSNS(Xobj)
            if Xobj.Lals
                % extract coordinates of limit state points
                fid = fopen(fullfile(Xobj.SmainPath,'MconstellationPoints.txt'), 'r');
                if fid<0
                    error('OpenCOSSAN:LineData',...
                        'Unable to find the file with results')
                else
                    McpSNS = fscanf(fid, '%e', [Xobj.Nvars inf]);
                    fclose(fid);
                    MconstellationPointsSNS=transpose(McpSNS);
                end
            else
                MconstellationPointsSNS=[];
            end
        end
        
        function MconstellationPointsPHY=get.MconstellationPointsPHY(Xobj)
            if Xobj.Lals
                McpPHY=zeros(Xobj.Nlines,Xobj.Nvars);
                for n=1:Xobj.Nlines
                    McpPHY(n,:)=Xobj.Xinput.map2physical(Xobj.MconstellationPointsSNS(n,:));
                    MconstellationPointsPHY=McpPHY;
                end
            else
                MconstellationPointsPHY=[];
            end
        end
        
        function save(Xobj,varargin)
            % Calling superclass method
            save@opencossan.common.outputs.SimulationData(Xobj,varargin{:})
            
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
        varargout=plotLines(Xobj,varargin)
        varargout=plotLimitState(Xobj,varargin)
        
    end % Methods
    
    methods  (Static)
        function XLineSamplingOutput=load(varargin)
            % Calling superclass method
            Xout=load@SimulationData(varargin{:});
            
            %% Check Inputs
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sfilename'}
                        %check input
                        SfileName = varargin{k+1};
                end
            end
            
            load(SfileName,'LineSamplingReserved_*');
            
            if isempty(LineSamplingReserved_VnumPointLine)
                XLineSamplingOutput=LineSamplingOutput('XsimulationData',Xout, ...
                    'SperformanceFunctionName',LineSamplingReserved_SperformanceFunctionName);
            else
                XLineSamplingOutput=LineSamplingOutput('XsimulationData',Xout, ...
                    'VnumPointLine',LineSamplingReserved_VnumPointLine, ...
                    'Vdistanceorthogonalplane',LineSamplingReserved_VdistancePlane, ...
                    'Vdistance',LineSamplingReserved_Vdistance, ...
                    'SperformanceFunctionName',LineSamplingReserved_SperformanceFunctionName);
            end
            
        end
    end
    
end

