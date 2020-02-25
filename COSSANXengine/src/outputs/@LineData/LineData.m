classdef LineData
    % LINEDATA class
    %   This class collects outputs and data resulting from the LineSampling
    %   or the AdaptiveLineSampling simulation.
    %
    % See also: https://cossan.co.uk/wiki/index.php/@LineData
    %
    % Author:~Marco~de~Angelis
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
        Sdescription             % object description (user provided)
        SperformanceFunctionName % name of the output of the PerformanceFunction
        SmainPath                % path where all results are stored
        
        LdeleteResults           %
        LdeleteSimulationFolders %
        
        Xals                     % Adaptive Line Sampling object
    end
    
    properties (SetAccess = protected)
        VimportantDirectionPHY   % important direction coordinates in Physiacal Space
        VimportantDirectionSNS   % important direction coordinates in Standard Normal Space
        
        Llite = false            % lite version of the object where most of data results are not saved in matrix arrays
        
        Nevaluations             % number of function's evaluations
        
        NdirectionalUpdates      % number of directional updates
        Nlines                   % number of lines spcified by the user
        NprocessedLines          % total number of processed lines
        NcrossingLines           % number of lines that cross the state boundary
        Nbatches                 % number of bathces user provided
        
        
        MlimitStateCoordsSNS     %
        MlimitStateCoordsPHY     %
        
        MimportantDirectionSNS   %
        MimportantDirectionPHY
        MhyperplaneCoords        %
        MconstellationPoints     %
        
        Tline                    % structure with information for each line
        
        
        reliabilityIndex         % norm of the most probable point on the state boundary
        
        VNlineEvaluations        % number of evaluations on single lines
        
        VdistanceLimitState      %
        VnormStatePoints         %
    end
    
    properties (SetAccess = private, Hidden = true)
        Xinput                   % Input object
    end
    
    properties (Dependent = true, SetAccess = protected)
        Nvars                    % number of (random) variables or dimension
        Tdata                    % structure with info about all lines
    end
    
    
    methods
        
        
        Xobj=display(Xobj)
        
        varargout=plotLines(Xobj,varargin)
        varargout=plotLimitState(Xobj,varargin)
        varargout=plotDirectionCoordinates(Xobj,varargin)
        
        
        function Xobj=LineData(varargin)
            %LINEDATA
            % This object stores the results of the simulation performed by
            % AdaptiveLineSampling or LineSampling
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/@LineData
            %
            % Author:~Marco~de~Angelis
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            
            OpenCossan.validateCossanInputs(varargin{:});
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription = varargin{k+1};
                    case {'sperformancefunctionname'}
                        Xobj.SperformanceFunctionName = varargin{k+1};
                    case {'xals','xls','xlinesampling'}
                        Xobj.Xals = varargin{k+1};
                    case 'xinput'
                        Xobj.Xinput = varargin{k+1};
                    case 'ldeleteresults'
                        Xobj.LdeleteResults = varargin{k+1};
                    otherwise
                        error('OpenCossan:wrongInput',...
                            'PropertyName %s not allowed', varargin{k})
                end
            end
            
            %% assign the working path
            Xobj.SmainPath=OpenCossan.getCossanWorkingPath;
            %% Validate Constructor
            % check if main path where results are stored exists
            assert(~isempty(Xobj.SmainPath),...
                'openCOSSAN:LineData',...
                'The main path with the simulations results has not been passed to the object')
            
            [status,~]=system(['mkdir ',Xobj.SmainPath]);
            if status == 0
                error('openCOSSAN:LineData',...
                    'The main path with the simulations results does not exist');
                % TODO: delete created directory
            end
            
            % check if Xinput is an Input object
            assert(isa(Xobj.Xinput,'Input'),...
                'openCOSSAN:LineData',...
                'The variable Xinput is supposed to be an Input object')
            
            %% Construct the object
            
            % extract all important directions (Standard Normal Space)
            fid = fopen(fullfile(Xobj.SmainPath,'mimportantdirections.txt'), 'r');
            if fid<0
                error('openCOSSAN:LineData',...
                    'The file containing the important directions does not exist')
            else
                Mid = fscanf(fid, '%e', [Xobj.Nvars inf]);
                fclose(fid);
                Mid=transpose(Mid);
            end
            
            % extract coordinates of limit state points
            fid = fopen(fullfile(Xobj.SmainPath,'mlimitstatecoords.txt'), 'r');
            if fid<0
                error('OpenCOSSAN:LineData',...
                    'The matrix containing values of the performance function does not exist')
            else
                MlspSNS = fscanf(fid, '%e', [Xobj.Nvars inf]);
                fclose(fid);
                MlspSNS=transpose(MlspSNS);
            end
            Vpos=find(isnan(MlspSNS(:,1)));
            Xobj.NcrossingLines=length(Vpos);
            
            
            % extract line results
            fid = fopen(fullfile(Xobj.SmainPath,'mlineresults.txt'), 'r');
            if fid<0
                error('OpenCOSSAN:LineData',...
                    'The matrix containing results from the ALS algorithm does not exist')
            else
                Mre = fscanf(fid, '%e', [7 inf]);
                fclose(fid);
                Mre=transpose(Mre);
            end
            Xobj.reliabilityIndex=Mre(end,4);
            Xobj.NdirectionalUpdates=sum(Mre(:,5));
            Xobj.NprocessedLines=size(Mre,1);
            Xobj.Nbatches=Mre(end,7);
            
            % extract line-points distances from the hyperplane
            fid = fopen(fullfile(Xobj.SmainPath,'mlinedistances.txt'), 'r');
            if fid<0
                error('OpenCOSSAN:LineData',...
                    'The matrix containing hyperplane distances does not exist')
            else
                Md = fscanf(fid, '%e', [Xobj.Xals.NmaxPoints inf]);
                fclose(fid);
                Md=transpose(Md);
            end
            
            
            % Store results in matrix arrays
            
            
            fid = fopen(fullfile(Xobj.SmainPath,'mhyperplanecoords.txt'), 'r');
            if fid<0
                error('OpenCOSSAN:LineData',...
                    'The matrix containing coordinates of hyperplane points does not exist')
            else
                Mhp = fscanf(fid, '%e', [Xobj.Nvars inf]);
                fclose(fid);
                Mhp=transpose(Mhp);
            end
            
            
%                 fid = fopen(fullfile(Xobj.SmainPath,'mconstellationpoints.txt'), 'r');
%                 if fid<0
%                     error('OpenCOSSAN:LineData',...
%                         'The matrix containing coordinates of the constellation points does not exist')
%                 else
%                     Mcn = fscanf(fid, '%e', [Xobj.Nvars inf]);
%                     fclose(fid);
%                     Mcn=transpose(Mcn);
%                 end
%                 Xobj.MconstellationPoints=Mcn;
            
            
            
            
            % extract performance function values
            fid = fopen(fullfile(Xobj.SmainPath,'mperformancevalues.txt'), 'r');
            if fid<0
                error('OpenCOSSAN:LineData',...
                    'The matrix containing values of the performance function does not exist')
            else
                Mg = fscanf(fid, '%e', [Xobj.Xals.NmaxPoints inf]);
                fclose(fid);
                Mg=transpose(Mg);
            end
            Xobj.NprocessedLines=size(Mg,1);
            
            Xobj.Nevaluations=sum(~isnan(Mg(:)));
            VNlineEval=zeros(1,size(Mg,1));
            VnormSP = zeros(1,size(Mg,1));
            VnormLastPoint= zeros(1,size(Mg,1));
            Cline=cell(2,size(Mg,1));
            MdirectionsPHY=zeros(size(Mg,1),Xobj.Nvars);
            MlspPHY=zeros(size(Mg,1),Xobj.Nvars);
            for n=1:size(Mg,1)                                              % begin loop over lines
                VLkeep=~isnan(Mg(n,:));
                % number of evaluations per line
                VNlineEval(1,n)=sum(VLkeep);
                % norm of state points
                VnormSP(1,n)=sqrt(sum(MlspSNS(n,:).^2));
                index=~isnan(Md(n,:));
                VnormPoints=sqrt(sum((repmat(Mhp(n,:)',1,VNlineEval(n))+...
                    Mid(n,:)'*Md(n,index)).^2,1));
                VnormLastPoint(1,n)=VnormPoints(end);
                Tl=struct('lineIndex',Mre(n,2),'Vg',Mg(n,VLkeep),'Vdistances',Md(n,VLkeep),...
                    'distanceLimitState',Mre(n,3),'stateFlag',Mre(n,5),...
                    'LdirectionalUpdate',Mre(n,5),'ibatch',Mre(n,7));
                Cline{1,n}=Tl;
                Cline{2,n}=['line_',num2str(n-1)];
                % important directions in Physical Space
                VpoleStarCoordinatesSNS=Mid(n,:);
                VpoleStarCoordinatesPHY=Xobj.Xinput.map2physical(VpoleStarCoordinatesSNS(:)');
                VmedianState=Xobj.Xinput.map2physical(zeros(1,Xobj.Nvars));
                VdirectionPHY=VpoleStarCoordinatesPHY-VmedianState;
                MdirectionsPHY(n,:)=VdirectionPHY(:)'/norm(VdirectionPHY);
                % limit state points in Physical Space
                MlspPHY(n,:)=Xobj.Xinput.map2physical(MlspSNS(n,:));
            end                                                             % end loop over lines
            Xobj.VNlineEvaluations=VNlineEval;
            Xobj.VnormStatePoints=VnormSP;
            Xobj.Tline=cell2struct(Cline(1,:),Cline(2,:),2);
            Xobj.VimportantDirectionPHY=MdirectionsPHY(end,:);
            Xobj.VimportantDirectionSNS=Mid(end,:);
            
            
            MreNo0=Mre;
            if Mre(1,1)==0
                MreNo0(1,:)=[];
            end
            Xobj.Nlines=size(MreNo0,1);
            
            
            
            if ~Xobj.Llite
                Xobj.MimportantDirectionSNS=Mid;
                Xobj.MimportantDirectionPHY=MdirectionsPHY;
                
                Xobj.MlimitStateCoordsSNS=MlspSNS;
                Xobj.MlimitStateCoordsPHY=MlspPHY;
                
                Xobj.MhyperplaneCoords=Mhp;
            end
            
            
            
            if Xobj.LdeleteResults
                status=rmdir(Xobj.SmainPath,'s');
                assert(status==1,...
                    'openCOSSAN:LineData',...
                    'Directory containing all results could not be deleted')
            end
        end % of constructor
        
        
        % dependent property
        function Nvars=get.Nvars(Xobj)
            Nvars=length(Xobj.Xinput.CnamesRandomVariable);
        end
        
        % dependent property
        function Tdata=get.Tdata(Xobj)
            CTlines=struct2cell(Xobj.Tline);
            Tdata=[CTlines{:}];
        end
        
    end % Methods
end

