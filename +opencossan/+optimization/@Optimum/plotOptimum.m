function varargout=plotOptimum(Xobj,varargin)
% plotOptimum This methods plots the requested variables stored in the
% Optimum object
%
% See Also: OPTIMUM, TutorialOptimum
%
% Author: Edoardo Patelli 

%{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.
    
    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
%}

%% Process inputs
Stitle=Xobj.Sdescription;
Svisible='on';
NfontSize=16;
Cnames=Xobj.CdesignVariableNames;
Cmarkers={'*' 'o' '+' 'x' 's' '^' 'v' 'p' 'h'};

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})    
        case 'vxdata'
            VXdata=varargin{k+1};
        case 'mydata'
            MYdata=varargin{k+1};
        case 'sylabel'
            Sylabel=varargin{k+1};
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
        case 'cmarkers'
            Cmarkers=varargin(k+1);
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        case 'stitle'
            Stitle=varargin{k+1};
        otherwise
            error('openCOSSAN:Optimum:plotOptimum',...
                ['PropetyName (' varargin{k} ') not allowed']);
    end
end

%% Sort results
figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;

hold on;

if length(unique(Xobj.TablesValues.Iteration))==length(Xobj.TablesValues.Iteration)
    % if it is a classic opt. algorithm
    p=plot (VXdata,MYdata); %#ok<NASGU>
else
    % if it is an evolution algorithm (i.e. repeated values at each
    % iteration)
    p=plot (VXdata,MYdata,'*'); %#ok<NASGU>
    
    for i=2:length(Cnames)
        if i>length(Cmarkers)
            eval(['p(' num2str(i) ').Marker=''' Cmarkers{randi(length(Cnames))} ''';' ]);
        else
            eval(['p(' num2str(i) ').Marker=''' Cmarkers{i} ''';' ]);
        end
    end
 
end

legend(gca(figHandle),Cnames)
set(gca(figHandle),'Box','on','FontSize',NfontSize)
title(gca(figHandle),Stitle);


xlabel(gca(figHandle),'Iteration')
ylabel(gca(figHandle),Sylabel)

% Export Figure

if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('figureHandle',figHandle,'SfigureName',SfigureName)
    end
end