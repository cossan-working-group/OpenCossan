function XsimOut = apply(Xobj,Xtarget)
%APPLY method.
% This method uses ImportanceSampling simulation to evaluate the object
% Xtarget.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/apply@Simulations
%
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

% Check inputs and Initialize variables
[Xobj, Xinput]=checkInputs(Xobj,Xtarget);
SexitFlag=[];            % Exit flag

if Xobj.Lcomputedesignpoint
    Xobj=Xobj.computeProposalDistribution(Xtarget);
end

%% IS simulation
while isempty(SexitFlag)
    
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    OpenCossan.setLaptime('description',[' Batch #' num2str(Xobj.ibatch)]);
    
    % Number of samples current batch
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nsimxbatch==0
        Ns=Xobj.Nlastbatch;
    else
        Ns=Xobj.Nsimxbatch;
    end
    
    % update counter for Nsamples
    Xobj.isamples = Xobj.isamples + Ns;
    
    % Generate samples
    Xs = Xobj.sample('Nsamples',Ns,'Xinput',Xinput);
    
    Xinput=set(Xinput,'Xsamples',Xs);
    
    OpenCossan.cossanDisp(['Importance Sampling simulation Batch ' num2str(Xobj.ibatch) ...
        ' ( ' num2str(Ns) ' samples)' ],4)
    
    % Evaluate Xtarget
    Xout= apply(Xtarget,Xinput);
    
    %% Export the weights
    Xout=Xout.addVariable('Cnames',{Xobj.SweightsName},'Mvalues',Xs.Vweights);
    
    %% Export results
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=Xout;  %#ok<AGROW>
    else
        Xobj.exportResults('Xsimulationoutput',Xout);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=Xout;
    end
    
    % check termination criteria
    SexitFlag=checkTermination(Xobj,XsimOut);
end

% Add termination criteria to the FailureProbability
XsimOut(end).SexitFlag=SexitFlag;
XsimOut(end).SbatchFolder=[OpenCossan.getCossanWorkingPath filesep Xobj.SbatchFolder];

%%  Set random number generator to state prior to running simulation
if exist('XRandomNumberGenerator','var'),
    Simulations.restoreRandomNumberGenerator(XRandomNumberGenerator)
end

OpenCossan.setLaptime('description','End apply@ImportanceSampling');
% Restore Global Random Stream
restoreRandomStream(Xobj);
