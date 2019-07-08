function [Xpf,varargout] = computeFailureProbability(Xobj,Xtarget)
%COMPUTEFAILUREPROBABILITY method. This method compute the FailureProbability associate to a
% ProbabilisticModel/SystemReliability/MetaModel by means of a Monte Carlo
% simulation object. It returns a FailureProbability object.
%
% See also:
% https://cossan.co.uk/wiki/index.php/computeFailureProbability@Simulation
%
% Author: Edoardo Patelli
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

%% Check inputs and Initialize variables
[Xobj, Xinput]=checkInputs(Xobj,Xtarget);
SexitFlag=[]; % Exit Flag


%% Start simulation
while isempty(SexitFlag)

    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    OpenCossan.setLaptime('Sdescription',[' Batch #' num2str(Xobj.ibatch)]);
   
        
     %Adjust number of samples to be generated for current batch
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nsimxbatch==0
        Ns=Xobj.Nlastbatch;
    else
        Ns=Xobj.Nsimxbatch;
    end
    
    OpenCossan.cossanDisp(['Sobol Sampling simulation Batch ' num2str(Xobj.ibatch) ...
            ' ( ' num2str(Ns) ' samples)' ],4)
    
    Xs = Xobj.sample('Nsamples',Ns,'Xinput',Xinput);
    
    % update status of the HaltonSampling object
    Xobj.Nskip=Xobj.Nskip+Xobj.Nleap*Ns;
        
    Xinput=set(Xinput,'Xsamples',Xs);
    
    % update counter for Nsamples
    Xobj.isamples = Xobj.isamples + Ns;
    
    %% evaluate performance function  
    XsimOut = apply(Xtarget,Xinput);  
    
    %% Compute Pf 
    if Xobj.ibatch==1
        % Initialize FailureProbability object
        Xpf=FailureProbability('CXmembers',{Xtarget XsimOut}, ...
            'Smethod','SobolSampling');
    else
        Xpf=Xpf.addBatch('XsimulationOutput',XsimOut);
    end

    %% Export results
    if Xobj.Lintermediateresults
        exportResults(Xobj,'XsimulationOutput',XsimOut);
    end
    
    % check termination criteria
    SexitFlag=checkTermination(Xobj,Xpf);
end

% Add termination criteria to the FailureProbability
Xpf.SexitFlag=SexitFlag;

if ~isdeployed
    % add entries in simulation and analysis database at the end of the
    % computation when not deployed. The deployed version does this with
    % the finalize command
    XdbDriver = OpenCossan.getDatabaseDriver;
    if ~isempty(XdbDriver)
        XdbDriver.insertRecord('StableType','Result',...
            'Nid',getNextPrimaryID(OpenCossan.getDatabaseDriver,'Result'),...
            'CcossanObjects',{Xpf},...
            'CcossanObjectsNames',{'Xpf'});
    end
end

XsimOut(end).SexitFlag=SexitFlag;
XsimOut(end).SbatchFolder=[OpenCossan.getCossanWorkingPath filesep Xobj.SbatchFolder];

%% Export the last SimulationData object if required
varargout{1}=XsimOut;
OpenCossan.setLaptime('Sdescription','End pf@SobolSampling');

% Restore Global Random Stream
restoreRandomStream(Xobj);
