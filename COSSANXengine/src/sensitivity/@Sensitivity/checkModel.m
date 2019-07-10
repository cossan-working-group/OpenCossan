function [Xinput,perturbation,Coutputname]=checkModel(Xtarget,perturbation,LperformanceFunction,Coutputname)
% CHECKMODEL This is a private function for the sensitivity methods.
%
% See Also: http://cossan.co.uk/wiki/index.php/GradientMonteCarlo@Sensitivity
% See Also: http://cossan.co.uk/wiki/index.php/localMonteCarlo@Sensitivity
% See Also: http://cossan.co.uk/wiki/index.php/GradientFiniteDifferences@Sensitivity
% See Also: http://cossan.co.uk/wiki/index.php/localFiniteDifferences@Sensitivity
%
%
% $Copyright~1993-2012,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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

switch class(Xtarget)
    case 'Model'
        Xinput=Xtarget.Xinput;
        if isempty(perturbation)
            perturbation=1e-4; % default value for cheap function evaluations
            for isolver = 1:length(Xtarget.Xevaluator.CXsolvers)
                if isa(Xtarget.Xevaluator.CXsolvers{isolver},'Connector') 
                    % if there is a Connector, the evaluation is expensive
                    % and the perturbation is set to a lower value
                    perturbation=1e-2; 
                end
            end
        end
        if isempty(Coutputname)
            if length(Xtarget.Coutputnames)==1
                Coutputname=Xtarget.Coutputnames;
            else
                error('openCOSSAN:sensitivity',...
                    'The model contains more than 1 outputs and it is necessary specify the quantity of interest');
            end
        end
        
    case {'PolyharmonicSplines','NeuralNetwork','ResponseSurface'}
        if ~isempty(Xtarget.XFullmodel)
            Xinput=Xtarget.XFullmodel.Xinput;
        else
            Xinput=Xtarget.XcalibrationInput;
        end
        if isempty(perturbation)
            perturbation=1e-4; % evaluating a metamodel is not expensive!
        end
        if isempty(Coutputname)
            if length(Xtarget.Coutputnames)==1
                Coutputname=Xtarget.Coutputnames;
            else
                error('openCOSSAN:sensitivity',...
                    'The metamodel contains more than 1 outputs and it is necessary specify the quantity of interest');
            end
        end

        
    case 'ProbabilisticModel'
        
        Xinput=Xtarget.Xmodel.Xinput;
        if isempty(Coutputname)
            if LperformanceFunction
                Coutputname={Xtarget.XperformanceFunction.Soutputname};
            else
                Coutputname=Xtarget.Coutputnames;
            end
        end
        
       if isempty(perturbation)
            perturbation=1e-4; % default value for cheap function evaluations
            for isolver = 1:length(Xtarget.Xmodel.Xevaluator.CXsolvers)
                if isa(Xtarget.Xmodel.Xevaluator.CXsolvers{isolver},'Connector') 
                    % if there is a Connector, the evaluation is expensive
                    % and the perturbation is set to a lower value
                    perturbation=1e-2; 
                end
            end
        end
        
    case 'Function'
        %% Implement control of the perturbation
        error('openCOSSAN:sensitivity',...
            'Gradient estimation of a Function not implemented, yet');
    otherwise
        
        error('openCOSSAN:sensitivity',...
            'Sensitivity analysis estimation for input of type %s not allowed',class(Xtarget));
end