function XsimOut = apply(Xobj,Xtarget)
%APPLY method. This method applies LatinHypercubeSampling simulation to the
%object passed as the argument
%
% See also: https://cossan.co.uk/wiki/index.php/apply@Simulations
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


%% Check inputs
[Xobj, Xinput]=checkInputs(Xobj,Xtarget);

%%  Initialize variables
Xobj.isamples = 0;
Xobj.ibatch = 0;
SexitFlag=[];

if ~isa(Xinput,'opencossan.common.inputs.Input')
    error('openCOSSAN:LatinHypercubeSampling:apply',...
        'an Input object is required to perform a LatinHypercubeSampling analysis!!!!')
end

%% LatinHypercubeSamplingC simulation
while isempty(SexitFlag)
    
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
     opencossan.OpenCossan.getTimer().lap('description',[' Batch #' num2str(Xobj.ibatch)]);
    
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
    
    opencossan.OpenCossan.cossanDisp(['Latin Hypercube Sampling simulation Batch ' num2str(Xobj.ibatch) ...
            ' ( ' num2str(Ns) ' samples)' ],4)
    
    %% evaluate performance function
    Xout= apply(Xtarget,Xinput);
        
    %% Export results
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=Xout;  %#ok<AGROW>
    else
        exportResults(Xobj,'Xsimulationoutput',Xout);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=Xout; 
    end
        
    % check termination criteria
    SexitFlag=checkTermination(Xobj,XsimOut);
end

% Add termination criteria to the FailureProbability
XsimOut(end).SexitFlag=SexitFlag;
XsimOut(end).SbatchFolder=[opencossan.OpenCossan.getWorkingPath filesep Xobj.SbatchFolder];

%%  Set random number generator to state prior to running simulation
if exist('XRandomNumberGenerator','var')
     Simulations.restoreRandomNumberGenerator(XRandomNumberGenerator)
end

opencossan.OpenCossan.getTimer().lap('Description','End apply@LatinHypercubeSampling');
% Restore Global Random Stream
restoreRandomStream(Xobj);
