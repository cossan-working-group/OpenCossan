function varargout=plotDesignVariable(Xobj,varargin)
% plotDesignVariable This method plots the evolution of the design variable
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/plotDesignVariable@Optimum
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
Cnames=Xobj.CdesignVariableNames;

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
        case 'cnames'
            Cnames=varargin{k+1};
        case 'sname'
            Cnames=varargin(k+1);
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        case 'stitle'
            Stitle=varargin{k+1};
        otherwise
            error('openCOSSAN:Optimum:plotDesignVaraible',...
                ['PropetyName (' varargin{k} ') not allowed']);
    end
end

assert(all(ismember(Cnames,Xobj.CdesignVariableNames)),...
    'openCOSSAN:Optimum:plotDesignVaraible',...
    ['Design variable(s) not available\n', ...
    'Required variables: %s \nAvailable variables: %s'],sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.CdesignVariableNames{:}))

%% Sort results

figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;

hold on;
VXdata=Xobj.XdesignVariable.Mcoord;

MYdata=zeros(length(VXdata),length(Cnames));
VnamesIndex=find(ismember(Xobj.CdesignVariableNames,Cnames));

for n=1:length(VnamesIndex)
    MYdata(:,n)=Xobj.XdesignVariable(VnamesIndex(n)).Vdata;
end

if Xobj.XdesignVariable(1).Nsamples==1
    % if it is a classic opt. algorithm
    plot (VXdata,MYdata);
else
    % if it is an evol. algorithm
    plot (VXdata,MYdata,'.');
end

legend(gca(figHandle),Cnames)

set(gca(figHandle),'Box','on','FontSize',NfontSize)
title(gca(figHandle),Stitle);


xlabel(gca(figHandle),Xobj.XdesignVariable(1).SindexUnit)
if length(Xobj.XdesignVariable)==1
    ylabel(gca(figHandle),Xobj.XdesignVariable(1).SindexName)
else
    ylabel(gca(figHandle),'Design Variables')
end

% Export Figure

if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName)
    end
end

end

