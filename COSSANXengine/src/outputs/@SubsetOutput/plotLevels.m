function varargout=plotLevels(Xobj,varargin)
%PLOTLEVEL. This method plots the values of the performance function
%calucalated at each level and the corresponding samples
%
% See also:
% https://cossan.co.uk/wiki/index.php/plot@SubsetOutput
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

Stitle='Subset simulation output';
SyLabel=Xobj.SperformanceFunctionName;
Smarker='o';
SmarkerRejected='*';
Svisible='on';
Lseeds=false; % show the seeds for each level and the final samples
NplotLevels=length(Xobj.VsubsetThreshold);
NfontSize=12;

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'sfigurename'
            Sfigurename=varargin{k+1};
        case 'stitle'
            Stitle=varargin{k+1};
        case 'nmaxlevels'
            NplotLevels=varargin{k+1};
        case 'smarker'
            Smarker=varargin{k+1};
        case 'smarkerrejected'
            SmarkerRejected=varargin{k+1};
        case 'nfontsize'
            NfontSize=varargin{k+1};
        case 'lseeds'
            Lseeds=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        otherwise
            error('openCOSSAN:SubsetOutput:plotLevels:wrongArguments',...
                'Field name %s is not valid',varargin{k});
    end
end

%% Check data
Vg=Xobj.getValues('Sname',Xobj.SperformanceFunctionName);

%% Initialize figure
fh=figure('Visible',Svisible);
varargout{1}=fh;

Haxes = gca; % handle of current axes
hold(Haxes,'on');

scatter(ones(Xobj.NinitialSamples,1),Vg(1:Xobj.NinitialSamples),Smarker);
line([0 NplotLevels+1],[Xobj.VsubsetThreshold(1) Xobj.VsubsetThreshold(1)])

for n=2:NplotLevels
    VindexData=Xobj.MchainIndices(:,:,n-1);
    MrejData=ismember(VindexData,Xobj.VrejectedSamplesIndices);
    
    if Lseeds
        VseedIndex=Xobj.VseedsIndices(Xobj.Nmarkovchains*(n-2)+1:Xobj.Nmarkovchains*(n-1));
        scatter(n*ones(Xobj.Nmarkovchains,1)-0.1,Xobj.VsubsetPerformance(VseedIndex),'.')
    end
    
    if any(~MrejData(:))
        scatter(n*ones(length(VindexData(~MrejData)),1),Vg(VindexData(~MrejData)),Smarker)
    end
    if any(MrejData(:))
        scatter(n*ones(length(VindexData(MrejData)),1),Vg(VindexData(MrejData)),SmarkerRejected)
    end
    
    if Lseeds
        VgIndex=Xobj.NinitialSamples*(n-1)+1:Xobj.NinitialSamples*(n);
        scatter(n*ones(Xobj.NinitialSamples,1)+0.1,Xobj.VsubsetPerformance(VgIndex),'.')
    end
    
    line([0 NplotLevels+1],[Xobj.VsubsetThreshold(n) Xobj.VsubsetThreshold(n)])
end

% Custumize figure
box(Haxes,'on');
grid(Haxes,'on');

xlabel(Haxes,'Subset levels','FontSize',NfontSize)
ylabel(Haxes,SyLabel,'FontSize',NfontSize)
title(Haxes,Stitle);

set(Haxes,'FontSize',NfontSize);

if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
    saveas(fh,Sfigurename,'fig')
end

varargout{1}=fh;
end



