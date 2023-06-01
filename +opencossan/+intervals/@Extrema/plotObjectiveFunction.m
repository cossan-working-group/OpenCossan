function varargout=plotObjectiveFunction(Xobj,varargin)
% PLOTOBJECTIVEFUNCTION This method plots the evolution of the objective function
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/plotObjectiveFunction@Extrema
%
% Author:
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
LlogPlot=false;
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
        case 'llogplot'
            LlogPlot=varargin{k+1};
        otherwise
            error('openCOSSAN:Extrema:plotDesignVariable',...
                ['PropetyName (' varargin{k} ') not allowed']);
    end
end

%% Sort results

NtotalIterations=size(Xobj.MatrixOfResults,1);
VXdata=1:NtotalIterations;


VobjData=Xobj.MatrixOfResults(:,end-2);
VflagMax=logical(1-Xobj.MatrixOfResults(:,end));


figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;
hold all;
if ~LlogPlot
    if sum(VflagMax)==length(VflagMax) || sum(VflagMax)==0
        plot (VXdata(VflagMax),VobjData(VflagMax));
        legend(gca(figHandle),{'objective Min/Max'})
    else
        hp1=plot (VXdata(VflagMax),VobjData(VflagMax));
        hp2=plot (VXdata(~VflagMax),VobjData(~VflagMax),'r');
        legend([hp1,hp2],{'objective Minimization','objective Maximization'})
    end
else
    if all(~VflagMax)
        hp1=plot (VXdata(VflagMax),log10(VobjData(VflagMax)));
        hp2=plot (VXdata(~VflagMax),log10(VobjData(~VflagMax),'r'));
        legend([hp1,hp2],{'objective Minimization','objective Maximization'})
    else
        plot (VXdata(VflagMax),log10(VobjData(VflagMax)));
        legend(gca(figHandle),{'objective'})
    end
end


set(gca(figHandle),'Box','on','FontSize',NfontSize)
title(gca(figHandle),Stitle);


xlabel(gca(figHandle),'Iteration #')
if ~LlogPlot
    ylabel(gca(figHandle),'failure Probability')
else
    ylabel(gca(figHandle),'Log_{10} failure Probability')
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

