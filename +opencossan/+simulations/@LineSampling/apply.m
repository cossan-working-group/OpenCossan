function XsimOut = apply(Xobj,Xtarget)
%APPLY method. This method applies LineSampling simulation to the object
%passed as the argument
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

import opencossan.simulations.LineSamplingOutput

OpenCossan.cossanDisp('LineSampling: Check inputs',3)

%% Check inputs
[Xobj, Xinput]=checkInputs(Xobj,Xtarget);

%%  Initialize variables
SexitFlag=[];       % status of the simulation

OpenCossan.cossanDisp('LineSampling: Start analysis',3)

switch class(Xtarget)
    case 'ProbabilisticModel'
        SperformanceFunctionName=Xtarget.XperformanceFunction.Soutputname;
    otherwise
        SperformanceFunctionName=Xtarget.Coutputnames{1};
end

%% Start simulation
while isempty(SexitFlag)
    
    % Update the current batch counter
    Xobj.ibatch = Xobj.ibatch + 1;
    
    % Lap time for each batch
    OpenCossan.setLaptime('description',[' Batch #' num2str(Xobj.ibatch)]);
    
    % Compute the number of lines for each batch
    if Xobj.ibatch==Xobj.Nbatches || Xobj.Nlinexbatch==0
        Nlines=Xobj.Nlinelastbatch;
    else
        Nlines=Xobj.Nlinexbatch;
    end
    
    %% Gererate samples
    Xs=Xobj.sample('Nlines',Nlines,'Xinput',Xinput);
    
    %% evaluate performance function
    Xout= apply(Xtarget,Xs);
    
    Xobj.isamples = Xobj.isamples+Nlines*length(Xobj.Vset);
    
    %% Construct LineSamplingOutput
    %assuming constant # of samples per line
    
    Vdistance=sqrt(sum(Xs.MsamplesStandardNormalSpace.*Xs.MsamplesStandardNormalSpace,2));
    VdistancePlane=transpose(repmat(Xobj.Vset,1,Nlines));
    
    XlsOut = LineSamplingOutput('SperformanceFunctionName',SperformanceFunctionName,...
        'VnumPointLine',length(Xobj.Vset)*ones(Nlines,1),'VdirectionSNS',Xobj.Valpha, ...
        'Vdistance',Vdistance,'VdistanceOrthogonalPlane',VdistancePlane,...
        'XsimulationData',Xout,'Xinput',Xinput);
    
    OpenCossan.setLaptime('description',['Export Batch #' num2str(Xobj.ibatch) ' results']);
    
    %% Export results
    if ~Xobj.Lintermediateresults
        XsimOut(Xobj.ibatch)=XlsOut;  %#ok<AGROW>
    else
        Xobj.exportResults('XlineSamplingOutput',XlsOut);
        % Keep in memory only the SimulationData of the last batch
        XsimOut=XlsOut;
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

OpenCossan.setLaptime('description','End apply@LineSampling');

% Restore Global Random Stream
restoreRandomStream(Xobj);
end
