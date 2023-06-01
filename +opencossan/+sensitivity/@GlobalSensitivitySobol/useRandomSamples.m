function varargout=useRandomSamples(Xobj,varargin)
% computeRandomSobolIndices is a function that computes the Sobol Indices 
% of a given model using random methods 
% computes the local sensitivity indices
%
% $Copyright~1993-2017,~COSSAN~Working~Group,~UK$
% $Author: Edoardo-Patelli$

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
%  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/

%% Check inputs
opencossan.OpenCossan.validateCossanInputs(varargin{:});

%% Process inputs
for k=1:2:length(varargin) 
    switch lower(varargin)
        case {'xtarget','xmodel'} 
            Xobj=Xobj.addModel(varargin{k+1}(1));
        case {'cxtarget','cxmodel'}
            Xobj=Xobj.addModel(varargin{k+1}{1});
        case {'smethod'}
            Xobj.Smethod=varargin{k+1};
        case {'xsimulationdata'}
            Xobj.XsimulationData=varargin{k+1};
        otherwise
            error('openCOSSAN:GlobalSensitivitySobol:computeIndices',... 
                'The PropertyName %s is not allowed',varargin{k});
    end 
end
%% Get Local Indices
Ninput=length(Xobj.Cinputnames);
Noutput=length(Xobj.Coutputnames);
Nsamples=Xobj.Xsimulator.Nsamples;
opencossan.OpenCossan.cossanDisp(['Total number of model evaluations ' num2str(Nsamples*(Ninput+2))],2)
%% Estimate sensitivity indices
% Generate samples
opencossan.OpenCossan.cossanDisp(['Generating samples from the ' class(Xobj.Xsimulator) ],4)
% Create two sample objects each with half of the sample size 
opencossan.OpenCossan.cossanDisp('Creating Samples object',4)

% The two input sample matrices are: with dimension(N,k) each
XA=Xobj.Xsimulator.sample('Xinput',Xobj.Xinput);
XB=Xobj.Xsimulator.sample('Xinput',Xobj.Xinput);

% Evaluate the model 
opencossan.OpenCossan.cossanDisp('Evaluating the model ' ,4)
% Computing y_{A} = f(A), where A is an (N,k) matrix
ibatch=1;
XoutA=Xobj.Xtarget.apply(XA); % y_A=f(A)
if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
    insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',XoutA,'Nbatchnumber',ibatch)
end

% Computing y_{B} = f(B), where A is an (N,k) matrix
ibatch = ibatch+1;
XoutB=Xobj.Xtarget.apply(XB); % y_B=f(B)
if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
    insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
        'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
        'XsimulationData',XoutB,'Nbatchnumber',ibatch)
end

% Expectation values of the output variables
opencossan.OpenCossan.cossanDisp('Extract quantity of interest from SimulationData ' ,4)
% Check if the model contains Dataseries
Vindex=strcmp(XoutA.CnamesDataseries,Xobj.Coutputnames);
if sum(Vindex)>0
    warning('It is not possible to compute the Sensitivity Analysis with respect a variable that is a DataSeries')
    fprintf('****** Removing vairables %s from the requested outputs ******\n',Xobj.Coutputnames{Vindex})
    Xobj.Coutputnames=Xobj.Coutputnames(~Vindex);
    Noutput=length(Xobj.Coutputnames);
end

% Omit/Extract the output vector of the two outputs y_{A} and y_{B}
MoutA=XoutA.getValues('Cnames',Xobj.Coutputnames);
MoutB=XoutB.getValues('Cnames',Xobj.Coutputnames);
% Normalise the output vector of the model 
MoutA=(MoutA-mean(MoutA)); 
MoutB=(MoutB-mean(MoutB)); 

%% Define a function handle to estimate the paraemeters
% This function handle is also used by the bootstraping method to estimate
% the variacne of the estimators, in Sobol.1993
Vf02=(sum([MoutA;MoutB],1)/(2*Nsamples)).^2; % fo² from Saltelli 2008
Vf21=Vf02;
MoutA=MoutA-Vf02; 
MoutB=MoutB-Vf02; 
Vf02=(sum([MoutA;MoutB],1)/(2*Nsamples)).^2; % fo² from Saltelli 2008
hcomputeindices=@(MxA,MxB)sum(MxA.*MxB)/(size(MxA,1))-Vf02;
% Computing Total variance of the outputs from the above method, also
% described in Saltelli 2008 adapted from Sobol.1993

% include bootstraping 
if Xobj.Nbootstrap>0
   VDbs=bootstrp(Xobj.Nbootstrap,hcomputeindices,[MoutA;MoutB],[MoutA;MoutB]);
end

%% Preallocate memory for the computation of Indices
Dz=zeros(Ninput,Noutput);
Dy=zeros(Ninput,Noutput);
Dybs=zeros(Ninput,Xobj.Nbootstrap,Noutput);
Dzbs=zeros(Ninput,Xobj.Nbootstrap,Noutput);

%% Extract the matrices of samples
MA=XA.MsamplesHyperCube;
MB=XB.MsamplesHyperCube;

switch lower(Xobj.Smethod)
    case{'saltelli2008','sobol1993'}
        % Compute total variance of the output
        % Use either 
        % VD=sum([MoutA;MoutB].^2,1)/(2*Nsamples) - Vf02;
        % or, the method from pre-allocated function handles
        VD=hcomputeindices([MoutA;MoutB],[MoutA;MoutB]);
        for irv=1:Ninput
            opencossan.OpenCossan.cossanDisp(['[Status] Compute Sensitivity indices ' num2str(irv) ' of ' num2str(Ninput)],2)
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
            
            if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
                insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                    'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
                    'XsimulationData',XoutC,'Nbatchnumber',ibatch);
            end
            
            % Extract the output vector of the model
            MoutC=XoutC.getValues('Cnames',Xobj.Coutputnames);
            % Normalise the output 
            MoutC=(MoutC-mean(MoutC));
            MoutC=MoutC-Vf21; 
            
            % Estimate V(E(Y|X_i))
            Dy(irv,:)=hcomputeindices(MoutA,MoutC);
            % or use use the following method, which are identical but without function handles  
            % Dy(irv,:)=sum(MoutA.*MoutC)/Nsamples- Vf02; %
            
            % Estimate V(E(Y|X~i))
            Dz(irv,:)=hcomputeindices(MoutB,MoutC);
            % or use use the following method, which are identical but without function handles  
            % Dz(irv,:)=sum(MoutB.*MoutC)/Nsamples- Vf02; %
            
            if Xobj.Nbootstrap>0
                Dybs(irv,:,:)=bootstrp(Xobj.Nbootstrap,hcomputeindices,MoutA,MoutC);
                Dzbs(irv,:,:)=bootstrp(Xobj.Nbootstrap,hcomputeindices,MoutB,MoutC);
            end
        end
        
        for n=1:Noutput
            % Compute First order Sobol indices
            MfirstOrder=Dy(:,n)/VD(n);
            
            % Compute Total Sensitivity indices
            Mtotal=1-Dz(:,n)/VD(n);
        end
        
    case {'saltelli2010'}
        % The case computes the First and total indices inaccordance to the
        % Saltelli's 2010 paper 'Variance based sensitivity analysis of
        % model output. Design and estimator for the total sensitivity
        % index' 
        
        % Estimate the variance and mean of the sample
        Ey=(mean(MoutA)+mean(MoutB))/2;
        za=MoutA-Ey;
        zb=MoutB-Ey; 
        VD=(za'*za+zb'*zb)/((2*Nsamples)-1);
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
            
            if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
                insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                    'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
                    'XsimulationData',XoutC,'Nbatchnumber',ibatch)
            end
            
            % Extract the output vectors
            MoutC=XoutC.getValues('Cnames',Xobj.Coutputnames);
            % Normalise the output vectors
            MoutC=(MoutC-mean(MoutC)); 
            MoutC=MoutC-Vf21;
            % Estimate V(E(Y|X_i))
            Dy(irv,:)=MoutB'*(MoutC-MoutA);
            % Estimate V(E(Y|X~i))
            Dz(irv,:)=MoutA'*(MoutC-MoutB);
            
            if Xobj.Nbootstrap>0
                Dybs(irv,:,:)=bootstrp(Xobj.Nbootstrap,hcomputeindices,MoutA,MoutC);
                Dzbs(irv,:,:)=bootstrp(Xobj.Nbootstrap,hcomputeindices,MoutB,MoutC);
            end
        end
      for n=1:Noutput
          % Compute First order Sobol Indices
          MfirstOrder=Dy(:,n)/(Nsamples*VD(n));
          % Compute the Total Sensitivity indices
          Mtotal=1-(Dz(:,n)/(Nsamples*VD(n)));
      end
    case {'jansen1999'}
        % The case computes the First and total indices inaccordance to the
        % Jansen 1999 paper
        
        % Estimate the variance and mean of the sample
        Ey=(mean(MoutA)+mean(MoutB))/2;
        za=MoutA-Ey;
        zb=MoutB-Ey; 
        VD=(za'*za+zb'*zb)/((2*Nsamples)-1);
        for irv=1:Ninput
            % Jansen 1999 method describes that matrix C_i is created
            % with all the elements in A but with ith column taken from B
            Vpos=strcmp(XA.Cvariables,Xobj.Cinputnames{irv});
            % Allocate Matric C, with all elements taken from A
            MC=MA;
            % Swap the ith column of C with ith column of A to form C_i 
            MC(:,Vpos)=MB(:,Vpos);
            % Construct a samples object
            XC=opencossan.common.Samples('Xinput',Xobj.Xinput,'MsamplesHyperCube',MC);
            % Evaluate the model
            ibatch = ibatch+1;
            XoutC=Xobj.Xtarget.apply(XC); % y_C_i=f(C_i)
            
            if ~isempty(opencossan.OpenCossan.getDatabaseDriver)
                insertRecord(opencossan.OpenCossan.getDatabaseDriver,'StableType','Simulation', ...
                    'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Simulation'),...
                    'XsimulationData',XoutC,'Nbatchnumber',ibatch)
            end
            
            % Extract the output vectors
            MoutC=XoutC.getValues('Cnames',Xobj.Coutputnames);
            % Normalise the output vectors
            MoutC=(MoutC-mean(MoutC)); 
            MoutC=MoutC-Vf21;
            % Estimate V(E(Y|X_i))
            Dy(irv,:)=VD-(sum((MoutB-MoutC).^2)*(1/(2*Nsamples)));
            % Estimate E_x~i(V_x_i(Y|X~i))
            Dz(irv,:)=(sum((MoutA-MoutC).^2))*(1/(2*Nsamples));
            
            if Xobj.Nbootstrap>0
                Dybs(irv,:,:)=bootstrp(Xobj.Nbootstrap,hcomputeindices,MoutA,MoutC);
                Dzbs(irv,:,:)=bootstrp(Xobj.Nbootstrap,hcomputeindices,MoutB,MoutC);
            end
        end
      for n=1:Noutput
          % Compute First order Sobol Indices
          MfirstOrder=Dy(:,n)/(VD(n));
          % Compute the Total Sensitivity indices
          Mtotal=(Dz(:,n)/(VD(n)));
      end 
    otherwise 
        error('openCOSSAN:GlobalSensitivitySobol:computeIndices',...
            'The property name %s is not allowed. Please choose an appropriate analysis method',Xobj.Smethod)
end


for n=1:Noutput
    %MfirstOrder=MfirstOrder(n);
    %Mtotal=Mtotal(n);

    if Xobj.Nbootstrap>0
        VfirstOrderCoV=std(squeeze(Dybs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(MfirstOrder');
        VtotalCoV=std(1-squeeze(Dzbs(:,:,n))'./repmat(VDbs(:,n),1,Ninput))./abs(Mtotal');
        
        varargout{1}(n)=opencossan.sensitivity.SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ...
            'Soutputname',  Xobj.Coutputnames{n},'Xevaluatedobject',Xobj.Xtarget, ...
            'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
            'VtotalIndices',Mtotal','VsobolFirstOrder',MfirstOrder', ...
            'VtotalIndicesCoV',VtotalCoV,'VsobolFirstOrderCoV',VfirstOrderCoV, ...
            'Sestimationmethod',Xobj.Smethod); 
    else
        varargout{1}(n)=opencossan.sensitivity.SensitivityMeasures('Cinputnames',Xobj.Cinputnames, ...
           'Soutputname',  Xobj.Coutputnames{n},'Xevaluatedobject',Xobj.Xtarget, ...
           'Sevaluatedobjectname',Xobj.Sevaluatedobjectname, ...
           'VtotalIndices',Mtotal','VsobolFirstOrder',MfirstOrder', ...
           'Sestimationmethod',Xobj.Smethod); 
    end
end

if nargout>1
    % Merge all 3 Simulation data and export the results
    varargout{2}=XoutC.merge(XoutB.merge(XoutA)); 
end

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = opencossan.OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(opencossan.OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',varargout(1),...
            'CcossanObjectsNames',{'Xgradient'});
    end

end   



end

