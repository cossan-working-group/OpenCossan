function [Xobj, Xinput]=checkInputs(Xobj,Xtarget)
%CHECKINPUTS This is a private function of the Simulation class. 
%
% See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@Simulations
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

% Retrieve information of the caller
ST = dbstack(1);

% set the analyis ID
OpenCossan.setAnalysisID;
% set the Analysis name if not already set
if ~isdeployed && isempty(OpenCossan.getAnalysisName)
    OpenCossan.setAnalysisName(class(Xobj));
end

ScallerDescription=['Start Simulation: ' ST(1).name '@' class(Xobj) ' ' Xobj.Sdescription];

% Initialize Timer
Xobj.initialLaptime = OpenCossan.setLaptime('Sdescription',ScallerDescription);
% insert entry in Analysis DB
if ~isempty(OpenCossan.getDatabaseDriver)
    insertRecord(OpenCossan.getDatabaseDriver,'StableType','Analysis',...
        'Nid',OpenCossan.getAnalysisID);
end

%% Process inputs
switch class(Xtarget)
    case {'Model'}
        assert(~strcmp(ST(1).name,'computeFailureProbability'),...
            'openCOSSAN:Simulations:checkInputs:ModelNotAllowed',...
            'Model object can not be used to estimate the failure probability. A probabilistic model is required')
        Xinput  = Xtarget.Xinput;
    case {'ResponseSurface','NeuralNetwork','PolyharmonicSplines','PolynomialChaos','KrigingModel'}
        % MetaModel
        if isempty(Xtarget.XFullmodel)
            Xinput=Xtarget.XcalibrationInput;
        else
            Xinput  = Xtarget.XFullmodel.Xinput;
        end
    case {'ProbabilisticModel'}
        switch class(Xtarget.Xmodel)
            case {'Model'}
                Xinput  = Xtarget.Xmodel.Xinput;
            otherwise
                % assuming that a metamodel is replacing the
                % full model
                CsuperClass=superclasses(Xtarget.Xmodel);
                if ismember('MetaModel', CsuperClass)
                    if isempty(Xtarget.Xmodel.XFullmodel)
                        Xinput=Xtarget.Xmodel.XcalibrationInput;
                    else
                        Xinput  = Xtarget.Xmodel.XFullmodel.Xinput;
                    end
                else
                    error('openCOSSAN:Simulations:checkInputs',...
                        ['Input parameter of class ' class(Xtarget) ' not allowed'])
                end
        end
        
    case {'SystemReliability'}
        Xinput  = Xtarget.Xmodel.Xinput;
    otherwise
        error('openCOSSAN:Simulations:checkInputs',...
            ['Input parameter of class ' class(Xtarget) ' not allowed'])
end

%% Initialize variables
if isempty(Xobj.SbatchFolder)
    Xobj.SbatchFolder=datestr(now,30);
end

Xobj.isamples = 0; % Number of samples processed
Xobj.ibatch = 0;   % Number of batches processed

%% Set random stream
if ~isempty(Xobj.XrandomStream)
    RandStream.setGlobalStream(Xobj.XrandomStream);
end
