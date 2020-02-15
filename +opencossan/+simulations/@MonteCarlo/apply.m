function simData = apply(obj, model)
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

import opencossan.*
import opencossan.reliability.*

simData = opencossan.common.outputs.SimulationData();

batch = 0;
while true
     batch = batch + 1;
     
    opencossan.OpenCossan.cossanDisp(...
        sprintf("Monte Carlo simulation batch #%i (%i samples)", batch, obj.Nsimxbatch), 4);
    
    samples = obj.sample('Nsamples',obj.Nsimxbatch,'Xinput',model.Input);
    
    simDataBatch = apply(model,samples);
    simDataBatch.Samples.Batch = repmat(batch, obj.Nsimxbatch, 1);
    
    simData = simData + simDataBatch;
    
    % check termination
    [exit, flag] = obj.checkTermination(simData);
    
    if exit
        simData.ExitFlag = flag;
        break;
    end
end

%% Restore Random Stream
restoreRandomStream(obj);


