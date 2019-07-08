function TexportedStucture=addField2Structure(Xsolver,XsimData,Tinput)
%ADDFIELD2STRUCTURE Private function of Evaluator that allows to add fields
%to the structure of Inputs. It is useful when an output of the previous
%evaluate Object is required to evaluate the current Object (i.e.
%Mio/Contraint/ObjectiveFunction/Connector etc.).
%
% PLEASE NOTE that If the SimulationData object (XsimData) and teh Tinput
% structure contain the same variables, the variable provided by the
% structure are exported in the output structure. 
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

% Retrieve names of inputs required by the solver
CrequiredVariables=Xsolver.Cinputnames;

if isempty(XsimData)
    TexportedStucture=Tinput;
else
    % Check that the SimulationData and Structure have the same number of
    % samples
    assert(length(Tinput)==XsimData.Nsamples, ...
    'openCOSSAN:Evaluator:addField2Structure:wrongSampleSize', ...
    'Samples in the Simulation data (%i) does not match the samples in the structure (%i)', ...
    XsimData.Nsamples,length(Tinput))
    
    % Extract values form Input structure
    CvaluesFromInput=struct2cell(Tinput);
    
    % Remove unneccessary fields. Keep only the variables required to
    % evaluate the Evaluator
    CinputNames=fieldnames(Tinput);
    Vindinp=ismember(CinputNames,CrequiredVariables);
    CvaluesFromInput(~Vindinp,:)=[];
    
    % Extract values from the SimulationData
    CvaluesFromSimulationData=struct2cell(XsimData.Tvalues);
    
    % Remove unneccessary fields. Keep only the variables required to
    % evaluate the Evaluator.
    % If the same variables are provided by the SimulationData and by the Structure
    % the values stored in the Structure are used
    CnamesSimData=XsimData.Cnames;
    
    VindsimData=ismember(CnamesSimData,CrequiredVariables);
    VnonDuplicateInputs=~ismember(CnamesSimData,CinputNames);
    
    % Keep only values required by the Evaluator and not provided by the
    % structure Tinput.
    VindSimData=VindsimData&VnonDuplicateInputs;
    
    CvaluesFromSimulationData(~VindSimData,:)=[];
          
    % Construct a structure of Input values required by the connector
    TexportedStucture=cell2struct([CvaluesFromInput; CvaluesFromSimulationData],...
        [CinputNames(Vindinp); CnamesSimData(VindSimData)],1);
end



   