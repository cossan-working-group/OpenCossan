function varargout=plotMarkovChains(Xobj,varargin)
%PLOTMARKOVCHAIN This method plots the markov chains for each level of the
%subset simulation
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

Stitle='Subset simulation';
Smarker='o';
Svisible='on';
NplotLevels=length(Xobj.VsubsetThreshold);
NfontSize=12;
LconnectChains=false;
Vchains=Xobj.Nmarkovchains;

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
        case 'lconnectchains'
            LconnectChains=varargin{k+1};
        case 'cnames'
            Cnames=varargin{k+1};
        case 'vchains'
            Vchains=varargin{k+1};  % Chain ID to be plotted
        case 'nfontsize'
            NfontSize=varargin{k+1};
        case 'lvisible'
            if varargin{k+1}
                Svisible='on';
            else
                Svisible='off';
            end
        otherwise
            error('openCOSSAN:SubsetOutput:plotMarkovChain:wrongArguments',...
                'Field name %s is not valid',varargin{k});
    end
end

%% Check data
assert(logical(exist('Cnames','var')),'openCOSSAN:SubsetOutput:plotMarkovChain:noCnames', ...
    'It is necessary to specify the names of the variable to be display')

assert(length(Cnames)==2,'openCOSSAN:SubsetOutput:plotMarkovChain:wrongLengthCnames', ...
    'Only 2 variables can be display with this method')

Vg=Xobj.getValues('Sname',Xobj.SperformanceFunctionName);

%% Initialize figure
fh=figure('Visible',Svisible);
varargout{1}=fh;
Haxes = gca; % handle of current axes
hold(Haxes,'on');

Mdata=Xobj.getValues('Cnames',Cnames);

scatter(Mdata(1:Xobj.NinitialSamples,1),Mdata(1:Xobj.NinitialSamples,2),'.')
Clabels{1}='Level 1 (MCS)';

for iLevel=1:NplotLevels-1
    if LconnectChains
        for jc=1:length(Vchains)
            VindexData=Xobj.MchainIndices(Vchains(jc),:,iLevel);
            VrejData=ismember(VindexData,Xobj.VrejectedSamplesIndices);
            VrejIndex=find(VrejData);
            
            VindexDataRejected(1:VrejIndex(1))=VindexData(1:VrejIndex(1));
            for n=2:sum(VrejData)
                VindexDataRejected=[VindexDataRejected VindexDataRejected(end-1)]; %#ok<AGROW>
                VindexDataRejected=[VindexDataRejected VindexData(VrejIndex(n-1)+1:VrejIndex(n))]; %#ok<AGROW>
            end
            
            VindexDataRejected=[VindexDataRejected VindexDataRejected(end-1) VindexData(VrejIndex(end)+1:end)]; %#ok<AGROW>
            
            %  Plot connected chain rejected samples
            plot(Mdata(VindexDataRejected,1),Mdata(VindexDataRejected,2),['-' Smarker]);
            Clabels{end+1}=sprintf('Level %i (Chain %i)',iLevel+1,Vchains(jc)); %#ok<AGROW>  
        end

    else
        VindexData=Xobj.MchainIndices(:,:,iLevel);
        MrejData=ismember(VindexData,Xobj.VrejectedSamplesIndices);
        if any(MrejData(:))
        % Plot rejected samples
            plot(Mdata(VindexData(MrejData),1),Mdata(VindexData(MrejData),2),'*');
            Clabels{end+1}=sprintf('Level %i (rejected)',iLevel+1); %#ok<AGROW>
        end
        % Plot accepted samples
        if any(~MrejData(:))
            plot(Mdata(VindexData(~MrejData),1),Mdata(VindexData(~MrejData),2),Smarker);
            Clabels{end+1}=sprintf('Level %i (accepted)',iLevel+1); %#ok<AGROW>
        end
    end
end

% Custumize figure
box(Haxes,'on');
grid(Haxes,'on');

xlabel(Haxes,Cnames{1},'FontSize',NfontSize)
ylabel(Haxes,Cnames{2},'FontSize',NfontSize)
title(Haxes,Stitle);
legend(Haxes,Clabels{:})

set(Haxes,'FontSize',NfontSize);

if exist('Sfigurename','var')
    saveas(fh,Sfigurename,'eps')
end

varargout{1}=fh;
end


