function display(Xobj)
%DISPLAY  Displays the object SensitivityMeasures
%
% See also: https://cossan.co.uk/wiki/index.php/@SensitivityMeasures
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

for n=1:length(Xobj)

    %% Name and description
    OpenCossan.cossanDisp('===================================================================',3);
    OpenCossan.cossanDisp([ class(Xobj(n)) ' -  Description: ' Xobj(n).Sdescription ],1);
    OpenCossan.cossanDisp('===================================================================',3);
    
    
    %% Show values of the Design Variables
    if isempty(Xobj(n).XevaluatedObject)
        OpenCossan.cossanDisp(' * No model defined ',2);
    else
        if isempty(Xobj(n).SevaluatedObjectName)
            SevaluatedObjectName= ' N/A ';
        else
            SevaluatedObjectName=Xobj(n).SevaluatedObjectName;
        end
        OpenCossan.cossanDisp([' * Model name:  ' SevaluatedObjectName ' (type: ' ...
            class(Xobj(n).XevaluatedObject) ') Output of interest: ' Xobj(n).SoutputName ],2);
    end
    
    
    %% Show Total indices
    if isempty(Xobj(n).VtotalIndices)
        OpenCossan.cossanDisp(' * No total indices available ',2)
    else
        % Coefficient of Variation
        if isempty(Xobj(n).VtotalIndicesCoV)
            Vcov=nan(size(Xobj(n).VtotalIndices));
        else
            Vcov=Xobj(n).VtotalIndicesCoV;
        end
        % Confidence Intervals
        if isempty(Xobj(n).MtotalIndicesCI)
            Mci=nan(2,length(Xobj(n).VtotalIndices));
        else
            Mci=Xobj(n).MtotalIndicesCI;
        end
        showIndices('Total effect',Xobj(n).CinputNames,Xobj(n).VtotalIndices,Vcov,Mci,Xobj(n).Valpha)
    end
    
    %% Show upperBounds indices
    if isempty(Xobj(n).VupperBounds)
        OpenCossan.cossanDisp(' * No upper bounds of the total indices available',2)
    else
        % Coefficient of Variation
        if isempty(Xobj(n).VupperBoundsCoV)
            Vcov=nan(size(Xobj(n).VupperBounds));
        else
            Vcov=Xobj(n).VupperBoundsCoV;
        end
        % Confidence Intervals
        if isempty(Xobj(n).MupperBoundsCI)
            Mci=nan(2,length(Xobj(n).VupperBounds));
        else
            Mci=Xobj(n).MupperBoundsCI;
        end
        showIndices('Upper Bounds',Xobj(n).CinputNames,Xobj(n).VupperBounds,Vcov,Mci,Xobj(n).Valpha)
    end
    
    %% Show First order Sobol' indices
    if isempty(Xobj(n).VsobolFirstIndices)
        OpenCossan.cossanDisp(' * No First order Sobol'' indices available',2)
    else
        % Coefficient of Variation
        if isempty(Xobj(n).VsobolFirstIndicesCoV)
            Vcov=nan(size(Xobj(n).VsobolFirstIndices));
        else
            Vcov=Xobj(n).VsobolFirstIndicesCoV;
        end
        % Confidence Intervals
        if isempty(Xobj(n).MsobolFirstIndicesCI)
            Mci=nan(2,length(Xobj(n).VsobolFirstIndices));
        else
            Mci=Xobj(n).MsobolFirstIndicesCI;
        end
        showIndices('First order',Xobj(n).CinputNames,Xobj(n).VsobolFirstIndices,Vcov,Mci,Xobj(n).Valpha)
    end
    
    if isempty(Xobj(n).VsobolIndices)
        OpenCossan.cossanDisp(' * High order Sobol'' indices not available ',2)
    else
        % Coefficient of Variation
        if isempty(Xobj(n).VsobolIndicesCoV)
            Vcov=nan(size(Xobj(n).VsobolIndices));
        else
            Vcov=Xobj(n).VsobolIndicesCoV;
        end
        % Confidence Intervals
        if isempty(Xobj(n).MsobolIndicesCI)
            Mci=nan(2,length(Xobj(n).VsobolIndices));
        else
            Mci=Xobj(n).MsobolIndicesCI;
        end
        showIndices('High order',Xobj(n).CsobolComponentsNames,Xobj(n).VsobolIndices,Vcov,Mci,Xobj(n).Valpha)
    end
    
    
    %% Show Estimation method
    if ~isempty(Xobj(n).SestimationMethod)
        OpenCossan.cossanDisp(['* Sensitivity measures estimated by means of: ' Xobj(n).SestimationMethod],2);
        OpenCossan.cossanDisp(' ',2);
    end
    
end
end

function showIndices(Sparameter,CinputNames,Vindices,Vcov,Mci,Valpha)
% Private function to show details of the indices
OpenCossan.cossanDisp([' * ' Sparameter ':'],2)
OpenCossan.cossanDisp(sprintf('%12s\t%11s\t%11s\t%11s %3.2f%% %3.2f%% %s', ...
    'Input Name',  Sparameter, 'Coef.of Var.','Conf.Int. (',Valpha*100,')'),2)

for n=1:length(Vindices)
    OpenCossan.cossanDisp(sprintf(' %12s\t%10.3e\t%10.3e\t%10.3e %10.3e', ...
        CinputNames{n},Vindices(n),Vcov(n),Mci(:,n)),2)
end

end
