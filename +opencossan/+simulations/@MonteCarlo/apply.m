function XsimOut = apply(Xobj,Xtarget)
%APPLY method. This method applies MonteCarlo object to the object
%passed as argument. 
% It perform Monte Carlo simulation 
%
% See also: http://cossan.co.uk/wiki/index.php/Apply@Simulations
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

import opencossan.OpenCossan

% Check inputs and initialize variables
[Xobj, Xinput]=checkInputs(Xobj,Xtarget);
SexitFlag=[]; % Exit flag

assert(isa(Xinput,'opencossan.common.inputs.Input'),'openCOSSAN:MonteCarlo:apply:InputObjectNotPresent',...
        'Input object is required to perform a MonteCarlo analysis!')

%% Start MC simulation
while isempty(SexitFlag)
    % Update the current batch counter
    Xobj.ibatch = Xobj.ibatch + 1;

    % Lap time for each batch
    OpenCossan.getTimer().lap('description',[' Batch #' num2str(Xobj.ibatch)]);
  
    % Number of samples current batch    
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nsimxbatch==0
        Ns=Xobj.Nlastbatch;
    else
        Ns=Xobj.Nsimxbatch;
    end
    
    % update counter for Nsamples
    Xobj.isamples = Xobj.isamples + Ns;
    
    OpenCossan.cossanDisp(['Monte Carlo Sampling simulation Batch ' num2str(Xobj.ibatch) ...
            ' ( ' num2str(Ns) ' samples)' ],4)
        
    % Generate samples
    Xs = Xobj.sample('Nsamples',Ns,'Xinput',Xinput);
            
    Xinput=set(Xinput,'Xsamples',Xs);
    
    
    %% evaluate performance function
    Xout= apply(Xtarget,Xinput);
                
    %% Export results
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=Xout;  %#ok<AGROW>
    else
        Xobj.exportResults('XsimulationOutput',Xout);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=Xout; 
    end
    
    % check termination criteria
    SexitFlag=checkTermination(Xobj,XsimOut);
end

% Add termination criteria to the FailureProbability
XsimOut(end).SexitFlag=SexitFlag;
XsimOut(end).SbatchFolder=[OpenCossan.getWorkingPath filesep Xobj.SbatchFolder];
OpenCossan.getTimer().lap('description','End apply@MonteCarlo');

%% Restore Random Stream
restoreRandomStream(Xobj);


