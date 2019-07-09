function display(Xobj)
%DISPLAY  Displays the object Optimum%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Optimum
%
% Copyright 1983-2013 COSSAN Working Group
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

%%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([ class(Xobj) ' Object  -  Description: ' Xobj.Sdescription],1);
OpenCossan.cossanDisp('===================================================================',3);

% Set default values
tolerance =1e-2;

%% Design Variable
if isempty(Xobj.CdesignVariableNames)
    OpenCossan.cossanDisp('|- Design Variables: not DEFINED ',2);
else
    OpenCossan.cossanDisp(['|- Design Variables: ' sprintf('%s ',Xobj.CdesignVariableNames{:})],2);
end

%% Show values of the Design Variables
Vdesign=Xobj.getOptimalDesign; 
for n=1:length(Vdesign)
    if isempty(Vdesign(n))
        OpenCossan.cossanDisp('|-- Values: no values available ',2);
    else
        OpenCossan.cossanDisp(['|-- Values: ' sprintf('%8.3e ',Vdesign(n)) ],2);
    end
end

%% Show value of the objective function and constrain at the optimum
Voptimum=Xobj.getOptimalObjective;    

for n=1:length(Voptimum)
    if isempty(Voptimum(n))
        OpenCossan.cossanDisp(['|-- Objective function #' num2str(n) ...
            ' at the optimum: no values available'],2)
    else
        OpenCossan.cossanDisp(['|-- Objective function #' num2str(n) ...
            ' at the optimum: ' sprintf('%8.3e ',Voptimum(n))],2)
    end
end

OpenCossan.cossanDisp('|',2)

if isempty(Xobj.XOptimizationProblem)
    OpenCossan.cossanDisp('|-- Optimization Problem not defined',2)
else
    
    Vconstraint=Xobj.getOptimalConstraint;
    for nCon=1:length(Vconstraint)
        if Xobj.XOptimizationProblem.Xconstraint(nCon).Linequality
            Sstring='Inequality';
        else
            Sstring='Equality';
        end
        
        if isempty(Vconstraint(nCon))
            
            OpenCossan.cossanDisp('|-- NO DATA available for constraint(s)',2)
            
        else
            if Xobj.XOptimizationProblem.Xconstraint(nCon).Linequality
                if Vconstraint(nCon)<tolerance
                    Sstatus=' Ok ';
                else
                    Sstatus=' NOT SATISFIED ';
                end
            else
                if abs(Vconstraint(nCon))<tolerance
                    Sstatus=' Ok ';
                else
                    Sstatus=' NOT SATISFIED ';
                end
            end
            
            OpenCossan.cossanDisp(['|-- ' Sstring ' constraint (' ...
                Xobj.XOptimizationProblem.Xconstraint(nCon).Coutputnames{:} ...
                ') values at the optimum: ' sprintf('%+8.3e ',Vconstraint(nCon)) ...
                ' Status: ' Sstatus],2)
        end
        
        
        
        
    end
end
OpenCossan.cossanDisp('|',2)
%% Statistics report
OpenCossan.cossanDisp(['|-- Evaluations of the objective function : '  sprintf('%3u',Xobj.NevaluationsObjectiveFunctions)],2);
OpenCossan.cossanDisp(['|-- Evaluations of the constraints        : ' sprintf('%3u',Xobj.NevaluationsConstraints)],2);
OpenCossan.cossanDisp(['|-- Evaluations of Phisical Model         : ' sprintf('%3u',Xobj.NevaluationsModel)],2);
OpenCossan.cossanDisp(['|-- Number of candidate solutions         : ' sprintf('%3u',Xobj.NcandidateSolutions)],2);



%% 5.   Termination criterion of optimization algorithm
if ~isempty(Xobj.Sexitflag)
    OpenCossan.cossanDisp(['|-- Termination criterion : ' Xobj.Sexitflag],1);
end

%% 6.   CPU time
if ~isempty(Xobj.totalTime)
    OpenCossan.cossanDisp([' Total time:    ' num2str(Xobj.totalTime) ' seconds'],2);
end

return
