function varargout=plotregression(Xobj,varargin)
% PLOTREGRESSION plots the output of the full model (target) and of the
% meta-model
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/Plotregression@Metamodel
%
% Author: Matteo Broggi & Edoardo Patelli
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

%% Check input
OpenCossan.validateCossanInputs(varargin{:})

NfontSize=16;
Svisible='on';
Lcalibration=Xobj.Lcalibrated;
Lvalidation=Xobj.Lvalidated;
Cplotnames=Xobj.Coutputnames;
Stitle='';

%% Parse varargin input
for k=1:2:length(varargin)
    switch lower(varargin{k}),
        case {'stype'}
            switch  lower(varargin{k+1})
                case {'calibration'}
                    Lcalibration=true;
                case {'validation'}
                    Lvalidation=true;
                case {'both','calibration&validation'}
                    Lcalibration=true;
                    Lvalidation=true;
                otherwise
                    error('openCOSSAN:MetaModel:plotregression',...
                        'Field type (%s) not valid', varargin{k+1} );
            end
        case{'cplotnames'}
            Cplotnames = varargin{k+1};
        case{'soutputname'}
            Cplotnames = varargin(k+1);
        case{'sfigurename'}
            CfigureNames = varargin(k+1);
        case{'cfigurenames'}
            CfigureNames = varargin{k+1};
        case{'sexportformat'}
            Sexportformat = varargin{k+1};
        case 'nfontsize'
            NfontSize=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        case 'stitle'
            Stitle=varargin{k+1};
        otherwise
            error('openCOSSAN:MetaModel:plotregression',...
                'Field name %s not valid', varargin{k} );
    end
end

% Check plot
assert(all(ismember(Cplotnames,Xobj.Coutputnames)), ...
    'openCOSSAN:metamodel:plotregression',...
    'Requested output(s) is not present in the output of the model.\n',...
    'Required variables: %s\nAvailable variables: %s',...
    sprintf('"%s" ',Cplotnames{:}),sprintf('"%s" ',Xobj.Coutputnames{:}));

if ~Lcalibration && ~Lvalidation
    varargout{1}=[];
    OpenCossan.cossanDisp('Nothing to plot',1)
    return
end


if Lcalibration
    assert(Xobj.Lcalibrated,'openCOSSAN:metamodel:plotregression',...
        'MetaModel not calibrated, no calibration plot available');
    
    XSimOut_fullmodelCalibration = Xobj.XcalibrationOutput;
    if ~isempty(Xobj.XcalibrationInput)
        XSimOut_metamodelCalibration = apply(Xobj,Xobj.XcalibrationInput);
    else
        XSimOut_metamodelCalibration = apply(Xobj,Xobj.XcalibrationOutput.Tvalues);
    end
end

if Lvalidation
    assert(Xobj.Lvalidated,'openCOSSAN:metamodel:plotregression',...
        'MetaModel not validated, no validation plot available');
    
    XSimOut_fullmodelValidation = Xobj.XvalidationOutput;
    if ~isempty(Xobj.XvalidationInput)
        XSimOut_metamodelValidation = apply(Xobj,Xobj.XvalidationInput);
    else
        XSimOut_metamodelValidation = apply(Xobj,Xobj.XvalidationOutput.Tvalues);
    end
end

for n=1:length(Cplotnames)
    figHandle=figure('Visible',Svisible);
    varargout{1}=figHandle;
    hold on;
    
    if Lvalidation && Lcalibration
        Hcalidation=subplot(211);
        Hvalidation=subplot(212);
    else
        Hcalidation=gca;
        Hvalidation=gca;
    end

    
    index = find(ismember(Xobj.Coutputnames,Cplotnames{n}),1);
    
    %% Plot calibration
    if Lcalibration
        % Get target values from output object stored in the meta-model
        VtargetsCalibration = getValues(XSimOut_fullmodelCalibration,'Sname',Cplotnames{n});
        % Get output values obtained with the meta-model
        VoutputsCalibration = getValues(XSimOut_metamodelCalibration,'Sname',Cplotnames{n});   
        
    plot(Hcalidation,VtargetsCalibration,VoutputsCalibration,'ko',...
        [min(VtargetsCalibration) max(VtargetsCalibration)], ...
        [min(VtargetsCalibration) max(VtargetsCalibration)]);
    grid(Hcalidation,'on');
    xlabel(Hcalidation,'Target','FontSize',NfontSize);
    ylabel(Hcalidation,'Output','FontSize',NfontSize);
    legend(Hcalidation,{'Meta-model','Full-model'}, ...
        'Interpreter','none','FontSize',NfontSize-2,'Location','NorthWest');
    
    title(Hcalidation,strcat(Cplotnames{n}, ...
        ': R^2=',sprintf('%4.3f',Xobj.VcalibrationError(index)),' (calibration) ',Stitle), ...
        'FontSize',NfontSize);
        
    end
    
    if Lvalidation
        % Get target values from output object stored in the meta-model
        VtargetsValidation = XSimOut_fullmodelValidation.getValues('Sname',Cplotnames{n});
        % Get output values obtained with the meta-model
        VoutputsValidation = XSimOut_metamodelValidation.getValues('Sname',Cplotnames{n});
            plot(Hvalidation,VtargetsValidation,VoutputsValidation,'ko',...
        [min(VtargetsValidation) max(VtargetsValidation)], ...
        [min(VtargetsValidation) max(VtargetsValidation)]);
    grid(Hvalidation,'on');
    xlabel(Hvalidation,'Target','FontSize',NfontSize);
    ylabel(Hvalidation,'Output','FontSize',NfontSize);
    legend(Hvalidation,{'Meta-model','Full-model'}, ...
        'Interpreter','none','FontSize',NfontSize-2,'Location','NorthWest');
    
    title(Hcalidation,strcat(Cplotnames{n}, ...
        ': R^2=',sprintf('%4.3f',Xobj.VvalidationError(index)),' (validation) ',Stitle), ...
        'FontSize',NfontSize);

    end
    
    %% Export Figure
    if exist('CfigureNames','var')
        if exist('Sexportformat','var')
            exportFigure('HfigureHandle',figHandle,'SfigureName',CfigureNames{n},'SexportFormat',Sexportformat)
        else
            exportFigure('HfigureHandle',figHandle,'SfigureName',CfigureNames{n})
        end
    end
    
end
return;
