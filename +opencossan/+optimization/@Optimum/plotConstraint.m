function varargout=plotConstraint(Xobj,varargin)
% PLOTCONSTRAINT This method plots the evolution of the constraints
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/plotConstraint@Optimum
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

%% Process inputs
Stitle=Xobj.Sdescription;
Svisible='on';
NfontSize=16;

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            SfigureName=varargin{k+1};
        case 'sexportformat'
            Sexportformat=varargin{k+1};
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
            error('openCOSSAN:Optimum:plotConstraint',...
                ['PropetyName (' varargin{k} ') not allowed']);
    end
end

%% Sort results

% Check that some constraints exist
if isempty(Xobj.Xconstrains)
    OpenCossan.cossanDisp('No contraints present in the Optimum object, nothing to do',1)
    return
end

figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;

hold on;
VXdata=Xobj.Xconstrains.Mcoord;
MYdata=zeros(length(Xobj.Xconstrains(1).Mcoord),length(Xobj.Xconstrains));

if size(Xobj.Xconstrains(1).Vdata,1)==1
    
    for n=1:length(Xobj.Xconstrains)
        MYdata(:,n)=Xobj.Xconstrains(n).Vdata;
    end
    
    plot (gca(figHandle),VXdata,MYdata);
else
    % Plot for Genetic Algorithms
    CMdataAll={Xobj.Xconstrains.Vdata};
    MXdata = repmat(VXdata,numel(CMdataAll{1})/numel(VXdata),1);
    for nconstraint = 1:length(Xobj.Xconstrains)
        plot (gca(figHandle),MXdata(:),CMdataAll{nconstraint}(:),'.','Color',rand(1,3));
    end
end


if ~isempty(Xobj.CconstraintsNames)
    for n=1:length(Xobj.CconstraintsNames)
        Clengend{n}=[Xobj.CconstraintsNames{n} ' ('   Xobj.XOptimizationProblem.Xconstraint(n).Sdescription ')']; %#ok<AGROW>
    end
    
    legend(gca(figHandle),Clengend,'Interpreter','none','FontSize',NfontSize-4)
end

set(gca(figHandle),'Box','on','FontSize',NfontSize)
title(gca(figHandle),Stitle);


xlabel(gca(figHandle),Xobj.Xconstrains(1).SindexUnit)
ylabel(gca(figHandle),Xobj.Xconstrains(1).SindexName)

% Export Figure

if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName)
    end
end

end

