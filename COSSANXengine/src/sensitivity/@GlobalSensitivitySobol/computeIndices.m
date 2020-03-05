function varargout=computeIndices(Xobj,varargin)
%COMPUTEINDICES This method does the Local Sensitivity analysis, and
%computes the local sensitivity indices
%
% $Copyright~1993-2019,~COSSAN~Working~Group,~UK$
% $Author: Edoardo-Patelli and Ganesh Ala$

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
%% Check inputs
OpenCossan.validateCossanInputs(varargin{:})

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'xtarget','xmodel'}
            Xobj=Xobj.addModel(varargin{k+1}(1));
        case {'cxtarget','cxmodel'}
            Xobj=Xobj.addModel(varargin{k+1}{1});
        otherwise
            error('OpenCossan:GlobalSensitivitySobol:computeIndices',...
                'The PropertyName %s is not allowed',varargin{k});
    end
end
%% Set the analysis name when not deployed
if ~isdeployed
    OpenCossan.setAnalysisName(class(Xobj));
end
%% Set the analysis ID
OpenCossan.setAnalysisID;
% Insert entry in Analysis Database
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',OpenCossan.getAnalysisID);
end
%%

%% Get Local Indices
Ninput=length(Xobj.Cinputnames);
Noutput=length(Xobj.Coutputnames);
Nsamples=Xobj.Xsimulator.Nsamples;
OpenCossan.cossanDisp(['Total number of model evaluations ' num2str(Nsamples*(Ninput+2))],2)
%% Estimate sensitivity indices
% Generate samples
OpenCossan.cossanDisp(['Generating samples from the ' class(Xobj.Xsimulator) ],4)
% Create two sample objects each with half of the sample size
OpenCossan.cossanDisp('Creating Samples object',4)

% The two input sample matrices are: with dimension(N,k) each
XA=Xobj.Xsimulator.sample('Xinput',Xobj.Xinput);
XB=Xobj.Xsimulator.sample('Xinput',Xobj.Xinput);

% Evaluate the model
OpenCossan.cossanDisp('Evaluating the model ' ,4)
% Computing y_{A} = f(A), where A is an (N,k) matrix
ibatch=1;
XoutA=Xobj.Xtarget.apply(XA); % y_A=f(A)
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',XoutA,'Nbatchnumber',ibatch)
end

% Computing y_{B} = f(B), where A is an (N,k) matrix
ibatch = ibatch+1;
XoutB=Xobj.Xtarget.apply(XB); % y_B=f(B)
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',XoutB,'Nbatchnumber',ibatch)
end

% Expectation values of the output variables
OpenCossan.cossanDisp('Extract quantity of interest from SimulationData ' ,4)
% Check if the model contains Dataseries
Vindex=ismember(XoutA.CnamesDataseries,Xobj.Coutputnames);
if sum(Vindex)>0
    warning('It is not possible to compute the Sensitivity Analysis with respect a variable that is a DataSeries')
    fprintf('****** Removing vairables %s from the requested outputs ******\n',Xobj.Coutputnames{Vindex})
    Xobj.Coutputnames=Xobj.Coutputnames(~Vindex);
    Noutput=length(Xobj.Coutputnames);
end

% Omit/Extract the output vector of the two outputs y_{A} and y_{B}
MoutA=XoutA.getValues('Cnames',Xobj.Coutputnames);
MoutB=XoutB.getValues('Cnames',Xobj.Coutputnames);
% % Normalise the output vector of the model
% MoutA=(MoutA-mean(MoutA));
% MoutB=(MoutB-mean(MoutB));


%% Preallocate memory for the computation of Indices
Dz=zeros(Ninput,Noutput);
Dy=zeros(Ninput,Noutput);
Dybs=zeros(Ninput,Xobj.Nbootstrap,Noutput);
Dzbs=zeros(Ninput,Xobj.Nbootstrap,Noutput);
MfirstOrder=zeros(Ninput,Noutput);
Mtotal=zeros(Ninput,Noutput);
MfirstOrderCoV=zeros(Ninput,Noutput);
MtotalCoV=zeros(Ninput,Noutput);
MfirstOrderCI=zeros(2,Ninput,Noutput);
MtotalCI=zeros(2,Ninput,Noutput);

%% Extract the matrices of samples
MA=XA.MsamplesHyperCube;
MB=XB.MsamplesHyperCube;

switch lower(Xobj.Smethod)
    case{'saltelli2008','sobol1993'}
        Xout = useSaltelli2008();
    case{'saltelli2010'}
        Xout=useSaltelli2010();
    case{'jansen1999'}
        Xout=useJansen1999();
    otherwise
        error('OpenCossan:GlobalSensitivitySobol:computeIndices',...
            'The property name %s is not allowed. Please choose an appropriate analysis method',Xobj.Smethod)
end


for n=1:Noutput
    %MfirstOrder=MfirstOrder(n);
    %Mtotal=Mtotal(n);
    
    if Xobj.Nbootstrap>0
        % include bootstraping
        
        varargout{1}(n)=SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ...
            'Soutputname',  Xobj.Coutputnames{n},'Xevaluatedobject',Xobj.Xtarget, ...
            'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
            'VtotalIndices',Mtotal(:,n)','VsobolFirstOrder',MfirstOrder(:,n)', ...
            'VtotalIndicesCoV',MtotalCoV(:,n),'VsobolFirstOrderCoV',MfirstOrderCoV(:,n), ...
            'MsobolfirstorderCI',MfirstOrderCI(:,:,n),'MtotalIndicesCI',MtotalCI(:,:,n), ...
            'Sestimationmethod',Xobj.Smethod);
    else
        varargout{1}(n)=SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ...
            'Soutputname',  Xobj.Coutputnames{n},'Xevaluatedobject',Xobj.Xtarget, ...
            'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
            'VtotalIndices',Mtotal(:,n)','VsobolFirstOrder',MfirstOrder(:,n)', ...
            'Sestimationmethod',Xobj.Smethod);
    end
end

if nargout>1
    % Return all the simulated data
    varargout{2}=Xout;
end

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end
    
    
    
end


    function Xout=useSaltelli2008()
        % computeSobolIndices using Saltelli2008 method
        %
        % $Copyright~1993-2019,~COSSAN~Working~Group,~UK$
        % $Author: Edoardo-Patelli$
        
        
        Xout = XoutB.merge(XoutA);
        
        %% Define a function handle to estimate the paraemeters
        % This function handle is also used by the bootstraping method to estimate
        % the variance of the estimators, in Sobol.1993
        Vf02=(sum([MoutA;MoutB],1)/(2*Nsamples)).^2; % fo² from Saltelli 2008
        
        hcomputeindices=@(MxA,MxB)sum(MxA.*MxB)/(size(MxA,1))-Vf02;
        % Computing Total variance of the outputs from the above method, also
        % described in Saltelli 2008 adapted from Sobol.1993
        
        
        % Compute total variance of the output
        % Use either
        % VD=sum([MoutA;MoutB].^2,1)/(2*Nsamples) - Vf02;
        % or, the method from pre-allocated function handles
        
        % Compute the normalizing variance of y (ednominator formula 4.21, 4.23)
        VD=hcomputeindices([MoutA;MoutB],[MoutA;MoutB]);
        for irv=1:Ninput
            OpenCossan.cossanDisp(['[Status] Compute Sensitivity indices ' num2str(irv) ' of ' num2str(Ninput)],2)
            % Saltelli's 2008 method describes that matrix C_i is created
            % with all elements from B except the ith elements taken from A
            Vpos=strcmp(XA.Cvariables,Xobj.Cinputnames{irv});
            % Allocate Matric C, with all elements taken from B
            MC=MB;
            % Compute C_i by swapping ith column with ith column of A
            MC(:,Vpos)=MA(:,Vpos); % Create matrix C_i
            % Construct sample object
            XC=Samples('Xinput',Xobj.Xinput,'MsamplesHyperCube',MC);
            
            % Evaluate the model with y_C_i=f(C_i)
            ibatch=ibatch+1;
            XoutC=Xobj.Xtarget.apply(XC); %y_C_i=F(C_i)
            
            if ~isempty(OpenCossan.getDatabaseDriver)
                insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                    'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
                    'XsimulationData',XoutC,'Nbatchnumber',ibatch);
            end
            
            Xout = Xout.merge(XoutC);
            
            % Extract the output vector of the model
            MoutC=XoutC.getValues('Cnames',Xobj.Coutputnames);
            
            % Estimate V(E(Y|X_i))
            Dy(irv,:)=hcomputeindices(MoutA,MoutC);
            % or use use the following method, which are identical but without function handles
            % Dy(irv,:)=sum(MoutA.*MoutC)/Nsamples- Vf02; %
            
            % Estimate V(E(Y|X~i))
            Dz(irv,:)=hcomputeindices(MoutB,MoutC);
            % or use use the following method, which are identical but without function handles
            % Dz(irv,:)=sum(MoutB.*MoutC)/Nsamples- Vf02; %
            
            if Xobj.Nbootstrap>0
                statoptions = statset(@bootstrp);
                statoptions.UseParallel = 1;
                [MfirstOrderCI(:,irv,:), Dybs(irv,:,:)] =bootci(Xobj.Nbootstrap,{hcomputeindices,MoutA,MoutC},'type','per','Options',statoptions);
                [MtotalCI(:,irv,:), Dzbs(irv,:,:)]=bootci(Xobj.Nbootstrap,{hcomputeindices,MoutB,MoutC},'type','per','Options',statoptions);
            end
        end
        
        %% Compute bounds
        if Xobj.Nbootstrap>0
            VDbs=bootstrp(Xobj.Nbootstrap,hcomputeindices,[MoutA;MoutB],[MoutA;MoutB]);
        end
        
        for n=1:Noutput
            % Compute First order Sobol Indices
            MfirstOrder(:,n)=Dy(:,n)/(VD(n));
            % Compute the Total Sensitivity indices
            Mtotal(:,n)=1-(Dz(:,n)/(VD(n)));
            
            if Xobj.Nbootstrap>0
                MfirstOrderCoV(:,n)=std(squeeze(Dybs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(MfirstOrder(:,n)');
                MtotalCoV(:,n)=std(1-squeeze(Dzbs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(Mtotal(:,n)');

                MfirstOrderCI(:,:,n) = MfirstOrderCI(:,:,n)/VD(n);
                MtotalCI(:,:,n) = 1-MtotalCI(:,:,n)/VD(n);
            end
        end
    end


    function Xout=useSaltelli2010()
        % computeSobolIndices using Saltelli2010 method
        %
        % $Copyright~1993-2019,~COSSAN~Working~Group,~UK$
        % $Author: Edoardo-Patelli$
        
        
        Xout = XoutB.merge(XoutA);
        
        %% Define a function handle to estimate the paraemeters
        % This function handle is also used by the bootstraping method to estimate
        % the variacne of the estimators, in Sobol.1993
        Vf02=(sum([MoutA;MoutB],1)/(2*Nsamples)).^2; % fo² from Saltelli 2008
        VD=sum([MoutA;MoutB].*[MoutA;MoutB])/(size([MoutA;MoutB],1))-Vf02;
        
        % anonymous functions used for bootstrap C.I. of the indeces
        hvariance=@(MxA,MxB)sum(MxA.*MxB)/(size(MxA,1))-Vf02;
        hindices_first=@(MxA,MxB,MxC)sum(MxB.*(MxC -MxA)/Nsamples);
        hindices_total=@(MxA,MxC)sum((MxA - MxC).^2)/(2*Nsamples);
        
        
        for irv=1:Ninput
            % Saltelli's 2010 method describes that matrix C_i is created
            % with all the elements in A but with ith column taken from B
            Vpos=strcmp(XA.Cvariables,Xobj.Cinputnames{irv});
            % Allocate Matric C, with all elements taken from A
            MC=MA;
            % Swap the ith column of C with ith column of A to form C_i
            MC(:,Vpos)=MB(:,Vpos);
            % Construct a samples object
            XC=Samples('Xinput',Xobj.Xinput,'MsamplesHyperCube',MC);
            % Evaluate the model
            ibatch = ibatch+1;
            XoutC=Xobj.Xtarget.apply(XC); % y_C_i=f(C_i)
            
            if ~isempty(OpenCossan.getDatabaseDriver)
                insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                    'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
                    'XsimulationData',XoutC,'Nbatchnumber',ibatch)
            end
            
            Xout = Xout.merge(XoutC);
            % Extract the output vectors
            MoutC=XoutC.getValues('Cnames',Xobj.Coutputnames);
            
            % Estimate V(E(Y|X_i))
            Dy(irv,:)=hindices_first(MoutA,MoutB,MoutC);
            % Estimate V(E(Y|X~i))
            Dz(irv,:)=hindices_total(MoutA,MoutC);
            
            if Xobj.Nbootstrap>0
                statoptions = statset(@bootstrp);
                statoptions.UseParallel = 1;
                [MfirstOrderCI(:,irv,:), Dybs(irv,:,:)] = bootci(Xobj.Nbootstrap,{hindices_first,MoutA,MoutB,MoutC},'type','per','Options',statoptions);
                [MtotalCI(:,irv,:), Dzbs(irv,:,:)] = bootci(Xobj.Nbootstrap,{hindices_total,MoutA,MoutC},'type','per','Options',statoptions);
            end
        end
        
        %% Compute bounds
        if Xobj.Nbootstrap>0
            VDbs=bootstrp(Xobj.Nbootstrap,hvariance,[MoutA;MoutB],[MoutA;MoutB]);
        end
        
        for n=1:Noutput
            % Compute First order Sobol Indices
            MfirstOrder(:,n)=Dy(:,n)/(VD(n));
            % Compute the Total Sensitivity indices
            Mtotal(:,n)= Dz(:,n)/(VD(n));
            
            if Xobj.Nbootstrap>0
                MfirstOrderCoV(:,n)=std(squeeze(Dybs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(MfirstOrder(:,n)');
                MtotalCoV(:,n)=std(1-squeeze(Dzbs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(Mtotal(:,n)');

                MfirstOrderCI(:,:,n) = MfirstOrderCI(:,:,n)/VD(n);
                MtotalCI(:,:,n) = MtotalCI(:,:,n)/VD(n);
            end
        end
    end


    function Xout=useJansen1999()
        % computeSobolIndices using Jansen1999 method
        %
        % $Copyright~1993-2019,~COSSAN~Working~Group,~UK$
        % $Author: Edoardo-Patelli$
        
        Xout = XoutB.merge(XoutA);
        %% Define a function handle to estimate the parameters
        
        % This function handle is also used by the bootstraping method to estimate
        % the variacne of the estimators, in Sobol.1993
        Vf02=(sum([MoutA;MoutB],1)/(2*Nsamples)).^2;
        VD=sum([MoutA;MoutB].*[MoutA;MoutB])/(size([MoutA;MoutB],1))-Vf02; % Variance of the output. A and B are used to be more precise (double no. of samples)
        
        % anonymous functions used for bootstrap C.I. of the indeces
        hvariance=@(MxA,MxB)sum(MxA.*MxB)/(size(MxA,1))-Vf02;
        hindices_first=@(MxB,MxC) VD - sum((MxB - MxC).^2)/(2*Nsamples);
        hindices_total=@(MxA,MxC)sum((MxA - MxC).^2)/(2*Nsamples);
        % Computing Total variance of the outputs from the above method, also
        % described in Saltelli 2008 adapted from Sobol.1993
        
        %% Extract the matrices of samples
        MA=XA.MsamplesHyperCube;
        MB=XB.MsamplesHyperCube;
        
        % The case computes the First and total indices inaccordance to the
        % Jansen 1999 paper
        for irv=1:Ninput
            % Jansen 1999 method describes that matrix C_i is created
            % with all the elements in A but with ith column taken from B
            Vpos=strcmp(XA.Cvariables,Xobj.Cinputnames{irv});
            % Allocate Matric C, with all elements taken from A
            MC=MA;
            % Swap the ith column of C with ith column of A to form C_i
            MC(:,Vpos)=MB(:,Vpos);
            % Construct a samples object
            XC=Samples('Xinput',Xobj.Xinput,'MsamplesHyperCube',MC);
            % Evaluate the model
            ibatch = ibatch+1;
            XoutC=Xobj.Xtarget.apply(XC); % y_C_i=f(C_i)
            
            if ~isempty(OpenCossan.getDatabaseDriver)
                insertRecord(OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                    'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Simulation'),...
                    'XsimulationData',XoutC,'Nbatchnumber',ibatch)
            end
            
            Xout = Xout.merge(XoutC);
            % Extract the output vectors
            MoutC=XoutC.getValues('Cnames',Xobj.Coutputnames);
            
            % Estimate V(E(Y|X_i))
            Dy(irv,:)=hindices_first(MoutB,MoutC);
            % Estimate E_x~i(V_x_i(Y|X~i))
            Dz(irv,:)=hindices_total(MoutA,MoutC);
            
            if Xobj.Nbootstrap>0
                statoptions = statset(@bootstrp);
                statoptions.UseParallel = 1;
                [MfirstOrderCI(:,irv,:), Dybs(irv,:,:)]=bootci(Xobj.Nbootstrap,{hindices_first,MoutB,MoutC},'type','per','Options',statoptions);
                [MtotalCI(:,irv,:), Dzbs(irv,:,:)]=bootci(Xobj.Nbootstrap,{hindices_total,MoutA,MoutC},'type','per','Options',statoptions);
            end
        end
        
        %% Compute bounds
        if Xobj.Nbootstrap>0
            VDbs=bootstrp(Xobj.Nbootstrap,hvariance,[MoutA;MoutB],[MoutA;MoutB]);
        end
        
        for n=1:Noutput
            % Compute First order Sobol Indices
            MfirstOrder(:,n)=Dy(:,n)/(VD(n));
            % Compute the Total Sensitivity indices
            Mtotal(:,n)=(Dz(:,n)/(VD(n)));
            
            if Xobj.Nbootstrap>0
                MfirstOrderCoV(:,n)=std(squeeze(Dybs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(MfirstOrder(:,n)');
                MtotalCoV(:,n)=std(1-squeeze(Dzbs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(Mtotal(:,n)');

                MfirstOrderCI(:,:,n) = MfirstOrderCI(:,:,n)/VD(n);
                MtotalCI(:,:,n) = MtotalCI(:,:,n)/VD(n);
            end
        end
        
    end

end