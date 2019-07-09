function varargout=lineSearch(Xobj,varargin)

import opencossan.common.Samples

%% Global variables
global iUpdates

if isempty(iUpdates)
    iUpdates=0;
end

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin)
    switch (lower(varargin{k}))
        case 'xtarget'
            Xtarget = varargin{k+1};
        case 'reliabilityindex'
            reliabilityIndex = varargin{k+1}; % note: this variable may be changed by this method 
        case 'vinitialdistance'
            VinitialDistance=varargin{k+1};
        case 'valpha'
            Valpha = varargin{k+1}; % note: this variable may be changed by this method 
        case 'vhyperplanepoint'
            VlineHyperPlanePoint = varargin{k+1};
        case {'mlinepoints'}
            % coordinates of points on line
            MlinePoints = varargin{k+1};
        case'iline'
            iLine = varargin{k+1};
        case {'salgorithm'}
            Salgorithm = varargin{k+1};
        otherwise
            % error, unknown property specified
            error('OpenCossan:AdaptiveLineSampling:exploitLine:lineSearch',...
                ['Field name (' varargin{k} ') not allowed']);
    end
end

% here we go
[Xobj,Xinput]=checkInputs(Xobj,Xtarget);

% Reset Variables
Xs=[]; % initialise Samples object
XpartialSimOut=[]; % initialise Simulation Data object

% Allocate memory for the distances from the hyperplane (growing vector)
% CVlineDistances=cell(1,Xobj.NmaxPoints);
% assign initial distance
% CVlineDistances{1}=VinitialDistance;

% VlineDistances=cell2mat(CVlineDistances);

n=0;
VlineDistances=zeros(1,Xobj.NmaxPoints);
for n=1:length(VinitialDistance)
    VlineDistances(n)=VinitialDistance(n);
end

% initialise limit state point
VmagicPoint=NaN(1,length(Valpha));

% |1-precisionNumber| is the closest floating-point number to 1
precisionLimit=abs(norminv(2^(-53)));

switch Salgorithm
    case 'NewtonRaphson'
        
        % Initialise state conditions for the loop over the points
        LdirectionalUpdate=false;           % this turns true when the direction is updated
        LprocessingAccomplished=false;      % this turns true when the state boundary is met
        LstateNotFound=false;               % this turns true when anywhere on the given direction the state boundary is not met
        LkeepLooping=true;                  % this turns false when it is no longer needed to loop
        
        
        ValphaNew=Valpha;
        iPoint=n-1;
        while LkeepLooping
            
            iPoint=iPoint+1; % count the number of points
            
            % Check if one of the points is outside the hypercube
            if any(any(MlinePoints>precisionLimit))
                % Take the point along the line to the edge of the hypercube
                for iSamplePoint=1:size(MlinePoints,1)
                    if any(MlinePoints(iSamplePoint,:)>precisionLimit)
                        % Compute the point on the line that meets the edge of the
                        % hypercube
                        [~,b]=max(abs(MlinePoints(iSamplePoint,:)));
                        ratio=(precisionLimit-VlineHyperPlanePoint(b))/Valpha(b);
                        VhypercubeEdgePoint=VlineHyperPlanePoint+ratio*Valpha;
                        MlinePoints(iSamplePoint,:)=VhypercubeEdgePoint';
                        
                    end
                end
            end
            
            % Gererate samples (define starting point of the lines)
            Xsamples=Samples('MsamplesStandardNormalSpace',MlinePoints,'Xinput',Xinput);
            
            % Collect samples
            if ~isempty(Xs)
                Xs=Xs.add('Xsamples',Xsamples);
            else
                Xs=Xsamples;
            end
            
            % Evaluate the model
            OpenCossan.setVerbosityLevel(2);
            XpointSimOut= apply(Xtarget,Xsamples);
            OpenCossan.setVerbosityLevel(3);
            
            % Collect Outputs and merge results
            if ~isempty(XpartialSimOut)
                XpartialSimOut=XpartialSimOut.merge(XpointSimOut);
            else
                XpartialSimOut=XpointSimOut;
            end
            
            % Extract the values of the performance function
            VgLine=XpartialSimOut.getValues('Sname',Xtarget.SperformanceFunctionVariable);
            
            if any(abs(VgLine)<Xobj.acceptableError)
                % point on the limit state: no needs to further proceed
                [~, imin]=min(abs(VgLine));
                currentLineDistance=VlineDistances(imin);
                distanceLimitState=currentLineDistance;
                
                % Store magic point coordinates in a vector array
                VmagicPoint=VlineHyperPlanePoint+distanceLimitState*Valpha;
                
                % check if a new reliability index is found
                if norm(VmagicPoint)+1e-6 < reliabilityIndex
                    reliabilityIndex=norm(VmagicPoint);
                    ValphaNew = VmagicPoint/norm(VmagicPoint);
                    LdirectionalUpdate=true;
                end
                
                 if length(VgLine)==1        
                    stateFlag=0; % State boundary met at first attempt
                    OpenCossan.cossanDisp(strcat('Intersection found at first attempt on Line#: ',...
                        num2str(iLine)),2)
                 else
                     stateFlag=assignStateFlag(Xobj,VlineDistances(1:iPoint),VgLine,iLine,Valpha,VlineHyperPlanePoint);
                end
%                 if length(VgLine)==1
%                     stateFlag=0; % State boundary met at first attempt
%                     OpenCossan.cossanDisp(strcat('Intersection found at first attempt on Line#: ',...
%                         num2str(iLine)),2)
%                 elseif sign(VgLine(1))==1 && sign(distanceLimitState)==1
%                     stateFlag=1; % State boundary met regularly after some iterations
%                 elseif sign(VgLine(1))==1 && sign(distanceLimitState)==-1
%                     stateFlag=1; % State boundary met after some iterations on the direction opposite to Valpha
%                 elseif sign(VgLine(1))==-1 && sign(distanceLimitState)==1
%                     stateFlag=2; % State boundary met regularly after some iterations
%                 elseif sign(VgLine(1))==-1 && sign(distanceLimitState)==-1
%                     stateFlag=2; % State boundary met on the negative half-space on the direction opposite to Valpha
%                 else
%                     % stateFlag=5; % State boundary exists but has a complex topology
%                 end
                
                if stateFlag==2 && iLine==0
                    % An update in direction is needed
                    ValphaNew = VmagicPoint/norm(VmagicPoint);
                    LdirectionalUpdate=true;
                    OpenCossan.cossanDisp('Intersection met the wrong way round! Consider changing sign to the important direction.',2)
                end
                
                LprocessingAccomplished=true; % Point close enough to the limit state function
            end
            
            % Evaluate the increment for the next iteration
            if length(VgLine)==1
                x = Xobj.minStep*sign(VgLine);
                currentLineDistance=VlineDistances(1)+x;
            else
                % Use the slope of the performance function between two
                % points to move in bigger(smaller) steps as per Newton-Raphson
                
                % Pick the last two evaluated points
                VgLastTwo=[VgLine(end-1),VgLine(end)];
                VlineLastTwo=[VlineDistances(iPoint-1),VlineDistances(iPoint)];
                [~,posMinVg]=min(abs(VgLastTwo));
                
                % dx= - f[x] / f'[x]
                x = - VgLastTwo(posMinVg)/...
                    ((VgLine(end)-VgLine(end-1))/(VlineLastTwo(2)-VlineLastTwo(1)));
                
                if isnan(x) && abs(VgLine(end))<=Xobj.acceptableError
                    x=0;
                elseif isnan(x)
                    x = Xobj.minStep*sign(VgLine(end));
                end
                currentLineDistance=VlineLastTwo(posMinVg)+x;
            end
            
            
            %Check if any point goes beyond the hypercube, if so get the line point
            %on the edge of the hypercube, and restart from a middle random value
            if norm((VlineHyperPlanePoint+Valpha*currentLineDistance),Inf)>precisionLimit
                % evaluate point on the edge of the hypercube
                [~,b]=max(abs(VlineHyperPlanePoint+Valpha*currentLineDistance));
                ratio=(precisionLimit-VlineHyperPlanePoint(b))/Valpha(b);
                VhypercubeEdgePoint=VlineHyperPlanePoint+ratio*Valpha;
                
                if sign(currentLineDistance)==1
                    %restart from a random point close to the edge of
                    %the hypercube
                    currentLineDistance=(20+rand)/21*...
                        norm(VhypercubeEdgePoint-VlineHyperPlanePoint);
                else
                    % restart from a random point anywhere in between
                    currentLineDistance=rand*...
                        norm(VhypercubeEdgePoint-VlineHyperPlanePoint);
                end
            end
            
            
            % Check if the intersection has been found
            if abs(sum(sign(VgLine)))<length(VgLine) && ~LprocessingAccomplished
                % Compute the point on the limit state by interpolating among the
                % available points
                VlineDistanceFine=linspace(min(VlineDistances),...
                    max(VlineDistances),Xobj.Ncfine);
                VgFine=interp1(VlineDistances(1:iPoint),VgLine,VlineDistanceFine,'linear');
                
                % get the closest point to the boundary
                [~,posMinVgFine]=min(abs(VgFine));
                distanceLimitState=VlineDistanceFine(posMinVgFine);
                
                
                % Check if the points are close enough to the estimeted
                % point for the limit state function
                if abs(x)<=Xobj.tolerance || length(VgLine)==Xobj.NmaxPoints
                    % store point coordinates in a vector array
                    VmagicPoint=VlineHyperPlanePoint+distanceLimitState*Valpha;
                    
                    % check if a new reliability index is found
                    if norm(VmagicPoint)+1e-6 < reliabilityIndex
                        reliabilityIndex=norm(VmagicPoint);
                        ValphaNew = VmagicPoint/norm(VmagicPoint);
                        LdirectionalUpdate=true;
                    end
                    
                    stateFlag=assignStateFlag(Xobj,VlineDistances(1:iPoint),VgLine,iLine,Valpha,VlineHyperPlanePoint);
%                     % Assign the state flags
%                     if sign(VgFine(1))==1 && sign(distanceLimitState)==1
%                         stateFlag=1; % State boundary met regularly after some iterations
%                     elseif sign(VgFine(1))==1 && sign(distanceLimitState)==-1
%                         stateFlag=1; % State boundary met after some iterations on the direction opposite to Valpha
%                     elseif sign(VgFine(1))==-1 && sign(distanceLimitState)==1
%                         stateFlag=2; % State boundary met regularly after some iterations
%                     elseif sign(VgFine(1))==-1 && sign(distanceLimitState)==-1
%                         stateFlag=2; % State boundary met on the negative half-space on the direction opposite to Valpha
%                         %                     else
%                         %                         stateFlag=5; % State boundary exists but has a complex topology
%                     end
                    
                    if iLine==0 && stateFlag==2 
                        % An update in direction is needed
                        ValphaNew = VmagicPoint/norm(VmagicPoint);
                        LdirectionalUpdate=true;
                        OpenCossan.cossanDisp('Intersection met the wrong way round! Consider changing sign to the important direction.',2)
                    end
                    
                    LprocessingAccomplished=true; % intersection with limit state function discovered
                end
            end
            
            % Check if the maximum number of points has been reached
            if abs(sum(sign(VgLine)))==Xobj.NmaxPoints
                
                if iLine==0
                    OpenCossan.cossanDisp('Intersection not met on the line passing through the origin',2)
                else
                    OpenCossan.cossanDisp(strcat('Intersection not met on Line#: ',...
                        num2str(iLine)),2)
                end
                
                if sign(VgLine(1))==1
                    stateFlag=3; % State boundary not met, the whole line is in the safe domain
                else
                    stateFlag=4; % State boundary not met, the whole line is in the fail domain
                end
                LstateNotFound=true; % state boundary NOT found
                distanceLimitState=0; % line will be discarded in a next stage
                
            elseif length(VgLine)==Xobj.NmaxPoints
                
                if iLine==0
                    OpenCossan.cossanDisp(...
                        sprintf('Intersection on the line passing through the origin found with less accuracy than specified.\n May want to increase the number of evaluation points currently set to %i',...
                        Xobj.NmaxPoints),2)
                else
                    OpenCossan.cossanDisp(...
                        sprintf('The intersection on Line#: %d was found with less accuracy than specified.',...
                        iLine),2)
                end
            end
            
            % Evaluate points coordinates
            MlinePoints=transpose(VlineHyperPlanePoint+Valpha*currentLineDistance);
            
            % Condition for getting out of the loop
            if LprocessingAccomplished
                LkeepLooping=false;
            elseif LstateNotFound
                LkeepLooping=false;
            else
                % Store current distance
                %                 ClineDistances{iPoint+1}=currentLineDistance;
                %                 VlineDistances=cell2mat(ClineDistances);
%                 CVlineDistances{iPoint+1}=currentLineDistance;
                VlineDistances(iPoint+1)=currentLineDistance;
            end
            
%             VlineDistances=cell2mat(CVlineDistances);
            
        end %loop over points of the line
        
        
        % Update reliability index and important direction
        if LdirectionalUpdate
            if iUpdates > Xobj.NmaxDirectionalUpdates || Xobj.NmaxDirectionalUpdates==0
                LdirectionalUpdate=false;
            else
                iUpdates=iUpdates+1;
            end
        end
        
    case 'splineFitting'
        % here a set of fixed points on the line is needed to proceed
    otherwise
        
end


varargout={stateFlag,reliabilityIndex,distanceLimitState,VgLine,...
    VlineDistances(1:iPoint),Valpha,ValphaNew,VmagicPoint,LdirectionalUpdate,XpartialSimOut,Xs};


return