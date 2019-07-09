function display(Xobj)
%DISPLAY  Displays the object RBOproblem
%
%
% Author: Edoardo Patelli, Matteo Broggi
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

%% Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' object  -  Description: ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',3);

if isempty(Xobj.Xinput)
    OpenCossan.cossanDisp('* Empty object',1);
    return
end

OpenCossan.cossanDisp( '* ProbabilistiModel to be evaluated',3);
OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.Xmodel.Cinputnames{:})],3);
OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.Xmodel.Coutputnames{:})],3);

OpenCossan.cossanDisp(['* * Simulation method: ',class(Xobj.Xsimulator)],2);

% Show Design Paremeter
OpenCossan.cossanDisp(['* Design Parameters: ' sprintf('%s; ', Xobj.CnamesDesignVariables{:})],2);

%% Objective function
if isempty(Xobj.XobjectiveFunction)
    OpenCossan.cossanDisp('* No objective function defined',3);
else
    for n=1:length(Xobj.XobjectiveFunction)
        OpenCossan.cossanDisp(['* Objective Function #' num2str(n)],3);
        OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Cinputnames{:})],3);
        OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.XobjectiveFunction(n).Coutputnames{:})],3);
    end
end

%% constraint
if isempty(Xobj.Xconstraint)
    OpenCossan.cossanDisp('* No constraints defined',3);
else
    for n=1:length(Xop.Xconstraint)
        OpenCossan.cossanDisp(['* Constraint #' num2str(n)],3);
        OpenCossan.cossanDisp(['* * Required input: ' sprintf('%s; ',Xobj.Xconstraint(n).Cinputnames{:})],3);
        OpenCossan.cossanDisp(['* * Provided output: ' sprintf('%s; ',Xobj.Xconstraint(n).Coutputnames{:})],3);
    end
end

%% Show details for metamodel
if isempty(Xobj.SmetamodelType)
   OpenCossan.cossanDisp('* No meta-model type defined',3);
else
   OpenCossan.cossanDisp(['* Meta-model type: ' Xobj.SmetamodelType],3);
    for n=1:2:length(Xobj.CmetamodelProperties)
        OpenCossan.cossanDisp(['* * Property Name: ' Xobj.CmetamodelProperties{n}],3);
    end
end




