function varargout=plotDesignVariable(Xobj,varargin)
% plotDesignVariable This method plots the evolution of the design variable
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/plotDesignVariable@Extrema
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
Stitle='Solution patterns of the search within the bounds';
Svisible='on';
NfontSize=16;
Cnames=Xobj.CdesignVariableNames;
LplotAll=false;
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
        case 'lplotall'
            LplotAll=varargin{k+1};
        otherwise
            error('openCOSSAN:Extrema:plotDesignVariable',...
                ['PropetyName (' varargin{k} ') not allowed']);
    end
end

assert(all(ismember(Cnames,Xobj.CdesignVariableNames)),...
    'openCOSSAN:Optimum:plotDesignVaraible',...
    ['Design variable(s) not available\n', ...
    'Required variables: %s \nAvailable variables: %s'],sprintf('"%s" ',Cnames{:}),sprintf('"%s" ',Xobj.CdesignVariableNames{:}))

%% Sort results

NtotalIterations=size(Xobj.MatrixOfResults,1);
VXdata=1:NtotalIterations;
[Vlb,Vub]=Xobj.XuncertaintyPropagation.XinputMapping.getBounds;

MdvData=Xobj.MatrixOfResults(:,1:end-3);
VobjData=Xobj.MatrixOfResults(:,end-2);
[~,indexes]=sort(VobjData,'ascend');
VnamesIndex=find(ismember(Xobj.CdesignVariableNames,Cnames));

for n=1:length(Cnames)
    String1=Xobj.XuncertaintyPropagation.CdesignMapping{n,2};
    String2=Xobj.XuncertaintyPropagation.CdesignMapping{n,3};
    Clabels{n}=[String1,'-',String2];
end

assert(length(VnamesIndex)==length(Cnames),...
    'OpenCOSSAN:Extrema:plotDesignVariable',...
    'Please provide a valid name for the variable to be plotted')

for n=1:length(VnamesIndex)
    MYdata(:,n)=MdvData(:,VnamesIndex(n));
    lB(n)=Vlb(VnamesIndex(n));
    uB(n)=Vub(VnamesIndex(n));
end



if LplotAll
    for n=1:length(Cnames)
        figHandle=figure('Visible',Svisible);
        varargout{n}=figHandle;
        hold all;
        axis([VXdata(1) VXdata(end) 0.999*lB(n) 1.001*uB(n)])
        hp=plot (VXdata,MYdata(:,n));
        hl1=line([1,NtotalIterations],[lB(n),lB(n)]);
        hl2=line([1,NtotalIterations],[uB(n),uB(n)]);
        hl3=line([1,NtotalIterations],[(uB(n)+lB(n))/2,(uB(n)+lB(n))/2]);
        hs1=scatter(VXdata(indexes(1)),MYdata(indexes(1),n),'o','filled');           % minimum 
        hs2=scatter(VXdata(indexes(end)),MYdata(indexes(end),n),'square','filled');  % maximum
        set(hl1,'linewidth',3,'color','black')
        set(hl2,'linewidth',3,'color','black')
        set(hl3,'linewidth',0.5,'color','green','linestyle','--')
        
        legend(gca(figHandle),[hp,hs1,hs2,hl1],{[Clabels{n},' pattern'],'minimum','maximum','U/L bounds'})
        
        set(gca(figHandle),'Box','on','FontSize',NfontSize)
        title(gca(figHandle),Stitle);
        
        xlabel(gca(figHandle),'Iteration #')
        ylabel(gca(figHandle),Clabels{n})
    end
    
else
    figHandle=figure('Visible',Svisible);
    varargout{n}=figHandle;
    hold all;
    if length(Cnames)==1
        axis([VXdata(1) VXdata(end) 0.999*lB 1.001*uB])
        hp=plot (VXdata,MYdata);
        hl1=line([1,NtotalIterations],[lB,lB]);
        hl2=line([1,NtotalIterations],[uB,uB]);
        hl3=line([1,NtotalIterations],[(uB+lB)/2,(uB+lB)/2]);
        hs1=scatter(VXdata(indexes(1)),MYdata(indexes(1)),'o','filled');              % minimum 
        hs2=scatter(VXdata(indexes(end)),MYdata(indexes(end)),'square','filled');     % maximum   
        legend(gca(figHandle),[hp,hs1,hs2,hl1],{[Clabels{n},' pattern'],'minimum','maximum','U/L bounds'})
    else % make a normalized parallel plot
        MlB=repmat(lB,NtotalIterations,1);
        MuB=repmat(uB,NtotalIterations,1);
        M0=(MYdata-MlB)./(MuB-MlB);
        axis([VXdata(1) VXdata(end) -0.05 1.05])
        plot(VXdata,M0);
        hl1=line([1,NtotalIterations],[0,0]);
        hl2=line([1,NtotalIterations],[1,1]);
        hl3=line([1,NtotalIterations],[0.5,0.5]);
        legend(gca(figHandle),Clabels)
    end
    set(hl1,'linewidth',3,'color','black')
    set(hl2,'linewidth',3,'color','black')
    set(hl3,'linewidth',0.5,'color','green','linestyle','--')
    
    
    
    
    set(gca(figHandle),'Box','on','FontSize',NfontSize)
    title(gca(figHandle),Stitle);
    
    
    xlabel(gca(figHandle),'Iteration #')
    if length(Cnames)==1
        ylabel(gca(figHandle),Clabels{1})
    else
        ylabel(gca(figHandle),'Design Variables')
    end
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

