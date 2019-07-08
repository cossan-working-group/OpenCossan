function [Xcutset,varargout] = findIntersection(Xsys,varargin)
%DPINTERSECTION
%   This function identify the intersection between linearized limit state
%   functions,
%   Original code developed by HJP. Integrated in COSSAN by EP
%
%
% Input arguments:
%   - Ccutset:  Cell array that define the cut-sets. Each number define the
%   basic event of the cut-set defined in the FaultTree.
%   - Vbeta:      Vector of the reliability indexes of the basic event. The
%                 length of the vector Vbeta must be equal to the length of
%                 Vcutset
%   - Malpha:     array of importat direction of the basic events.
%
%  Ouput arguments
%  - Xcutset:      array of CutSet object
%  - varargout{1}: Matrices that contains the coordinates of the
%                  intersection points
%  - varargout{2}: Vector contains the numbers of iterations required



%% Initialize variables
% Retrieve important direction (Malpha) and the design point (MdesignPoint)
% from the SystemReliability object

Ntolerance=1e-2;   % Default values for the tolerance in the identification of the DesignPoint
Nmaxiterations=10; % Number of maximum iteration allowed

Ndimension=Xsys.Xmodel.Xinput.Ninputs;  % Number of input variables
Ncomponents=length(Xsys.XdesignPoints); % Number of base components

if ~isempty(Xsys.XdesignPoints)
    Malpha=zeros(Ndimension,Ncomponents);
    MdesignPoint=zeros(Ndimension,Ncomponents);
    VbetaMembers=zeros(Ndimension,1);
    % populate Malpha and MdesignPoint
    for idp=1:length(Xsys.XdesignPoints)
        Malpha(:,idp)=Xsys.XdesignPoints{idp}.VDirectionDesignPointStdNormal;
        VbetaMembers(idp)=Xsys.XdesignPoints{idp}.ReliabilityIndex;
        MdesignPoint(:,idp)=Xsys.XdesignPoints{idp}.VDesignPointStdNormal;
    end
else
    Malpha=[];
    MdesignPoint=[];
    VbetaMembers=[];
end

% Minimal cut-sets
if ~isempty(Xsys.XFaultTree)
    if isempty(Xsys.XFaultTree.CminimalCutSets);
        Xsys.XFaultTree=Xsys.XFaultTree.findMinimalCutSets;
    end
    CmcsNames = Xsys.XFaultTree.CminimalCutSets;
    for ics=1:length(CmcsNames)
        for n=1:length(CmcsNames{ics})
            Cmcs{ics}(n)=find(strcmp(CmcsNames{ics}{n},Xsys.Cnames)); %#ok<AGROW>
        end
    end
    
else
    Cmcs=[];
end


for k=1:2:length(varargin)
    switch lower(varargin{k})
        case ('ccutset')
            % User defined cut-set
            Cmcs=varargin{k+1};
        case ('malpha')
            Malpha=varargin{k+1};
        case ('vbeta')
            VbetaMembers=varargin{k+1};
        case 'nmaxiterations'
            Nmaxiterations=varargin{k+1};
        case 'tolerance'
            Ntolerance=varargin{k+1};
        otherwise
            error('openCOSSAN:reliability:SystemReliabiliy:findIntersection',...
                [varargin{k} ' is not a valid FieldName'])
    end
end

Viterations=zeros(length(Cmcs),1);
MintersectionPoint=zeros(Ndimension,length(Cmcs));
%% Loop over the minumal cut-sets
for imcs=1:length(Cmcs)
    
    % Identify the reliability index and the direction of each performance
    % function of the minimal cut set
    
    nlim=length(Cmcs{imcs});  % Number of limit state functions in the cutset
    Malpha_lin=Malpha; % Columns -> Limit state function; % Row: variables
    Vdp_old=MdesignPoint(:,1)';
    Vbeta_lin=VbetaMembers;
    
    %% Loop for the dp identification
    for iter=1:Nmaxiterations
        
        [Xcutset(imcs) Vdp_new] = findLinearIntersection(Xsys, ...
            'Ccutset',Cmcs(imcs),'Vbeta',Vbeta_lin,'Malpha',Malpha_lin');  %#ok<AGROW>
        
        if all(abs((Vdp_new'-Vdp_old'))<Ntolerance)
            MintersectionPoint(:,imcs)=Vdp_new;
            break
        end
        
        Vdp_old=Vdp_new;
        
        for n=1:nlim
            componentIndex=Cmcs{imcs}(n); % index of the component
            
            %% Linearize the limit state function
            
            % Create a dummy ProbabilisticModel
            XpmDummy=ProbabilisticModel('Xmodel',Xsys.Xmodel,...
                'XperformanceFunction',Xsys.XperformanceFunctions(componentIndex));
            
            % Compute the gradient around the design point
            [Xgradient Xout0]=Sensitivity.gradientFiniteDifferences( ...
                'Xtarget',XpmDummy,'referencepoint',Vdp_old);
            
            % Retrive the values of the performance function
            g0=Xout0.getValues('Sname',XpmDummy.XperformanceFunction.Soutputname);
            
            % Inportant direction
            Malpha_lin(:,componentIndex) = -Xgradient.Valpha;
            Vproj=(Vdp_old*Xgradient.Valpha)*Xgradient.Valpha;
            Vproj2=g0/norm(Xgradient.Vgradient) *Xgradient.Valpha;
            
            Vbeta_lin(componentIndex)=norm(Vproj - Vproj2);
        end
        
        % Store the number of iteration in the counters
        Viterations(imcs)=iter;
        
    end
end

varargout{1}=MintersectionPoint;
varargout{2}=Viterations;

