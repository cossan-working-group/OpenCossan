function [ varargout ] = plot(Xobj,varargin)
%PLOT Plot dataseries
%   plot(Xds) produce a plot of the Dataseries property Vdata vs the
%   property Mcoord, with dimension of Mcoord up to 3. 
%
% See also: https://cossan.co.uk/wiki/index.php/plot@Dataseries
%
% Author: Matteo Broggi
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

% assert(length(Xobj)==1,'OpenCossan:Dataseries:plot',...
%     'Cannot call method plot on an array of Dataseries')

NfontSize=16;
Svisible='on';
Stitle='';
Lsorted=false;
Sstyle='';

% Object Check
assert(size(Xobj,2)==1,'openCOSSAN:Dataseries:addData', ...
    'plot method can only be applied to a single Dataseries object or to a Dataseries array');

Vsamples = 1:size(Xobj,1);
%% Parse varargin input
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case{'vsamples'}
            Vsamples = varargin{k+1};
        case{'nsample'}            
            Vsamples = varargin{k+1};
        case{'sfigurename'}
            SfigureName = varargin{k+1};
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
        case 'sstyle'
            Sstyle=varargin{k+1};
        case 'lsorted'
            Lsorted=varargin{k+1};
        otherwise
            error('openCOSSAN:MetaModel:plotregression',...
                'Field name %s not valid', varargin{k} );
    end
end

figHandle=figure('Visible',Svisible);
varargout{1}=figHandle;

%% create plot according to 
Mcoord = Xobj(1).Xcoord.Mcoord;
Mdata = zeros(length(Vsamples),Xobj(1).VdataLength);
for i=1:length(Vsamples)
    Mdata(i,:) = Xobj(Vsamples(i)).Vdata; 
end
switch size(Mcoord,1)
    case 1
        set(gca(figHandle), 'ColorOrder', varycolor(length(Vsamples)));
        if Lsorted
            [~,isort]=sort(Mcoord);
        else
            isort = 1:length(Mcoord);
        end
        if isempty(Sstyle)
            plot(gca(figHandle),Mcoord(isort),Mdata(Vsamples,isort))
        else
            plot(gca(figHandle),Mcoord(isort),Mdata(Vsamples,isort),Sstyle)
        end
        axis(gca(figHandle), [min(Mcoord) max(Mcoord)...
            min(min(Mdata(Vsamples,:)))*0.98 max(max(Mdata(Vsamples,:)))*1.02])
        xlabel(gca(figHandle),[Xobj(1).Xcoord.CSindexName{1} ' [' Xobj(1).Xcoord.CSindexUnit{1} ']'],...
            'FontSize',NfontSize);
        ylabel(gca(figHandle),'Data values','FontSize',NfontSize);
    case 2
        if length(Vsamples)~=1
            warning('openCOSSAN:Dataseries:plot',...
            'It is possible to draw only one data for 2d dataseries')
        end
        [Lequallyspaced, Mcoordsorted, idxsorted] = isequallyspaced(Mcoord);
        if ~Lequallyspaced
            x = Mcoord(1,:);
            y = Mcoord(2,:);
            z = Mdata(1,:);
            gx = linspace(min(x),max(x),101);
            gy = linspace(min(y),max(y),101);
            g=gridfit(x,y,z,gx,gy);
            surf(gx,gy,g);
        else
            diffs = unique(diff(Mcoordsorted(1,:)));
            ncuts = length(find(diff(Mcoordsorted(1,:))==diffs(2)))+1;
            XX = reshape(Mcoordsorted(1,:),[],ncuts);
            YY = reshape(Mcoordsorted(2,:),[],ncuts);
            ZZ = reshape(Xobj(Vsamples(1)).Vdata(idxsorted),[],ncuts);
            surf(XX,YY,ZZ)
        end
        xlabel(gca(figHandle),[Xobj(1).Xcoord.CSindexName{1} ' [' Xobj(1).Xcoord.CSindexUnit{1} ']'],...
            'FontSize',NfontSize);
        ylabel(gca(figHandle),[Xobj(1).Xcoord.CSindexName{2} ' [' Xobj(1).Xcoord.CSindexUnit{2} ']'],...
            'FontSize',NfontSize);
        zlabel(gca(figHandle),'Data values','FontSize',NfontSize);
    case 3
        if length(Vsamples)==1
            warning('openCOSSAN:Dataseries:plot',...
            'It is possible to draw only one data for 3d dataseries')
        end
        CScoordinateNames = regexp(Xobj(1).Xcoord.CSindexName{1,1},',','split');
        CScoordinateUnits = regexp(Xobj(1).Xcoord.CSindexUnit{1,1},',','split');
        scatter3(Mcoord(1,:),Mcoord(2,:),Mcoord(3,:),12,Mdata(1,:),'filled')
        xlabel(gca(figHandle),[CScoordinateNames{1} ' [' CScoordinateUnits{1} ']'],...
            'FontSize',NfontSize);
        ylabel(gca(figHandle),[CScoordinateNames{2} ' [' CScoordinateUnits{2} ']'],...
            'FontSize',NfontSize);
        zlabel(gca(figHandle),[CScoordinateNames{3} ' [' CScoordinateUnits{3} ']'],...
            'FontSize',NfontSize);
        colorbar
    otherwise
        % You cannot plot higher than dimesion 3.
        warning('openCOSSAN:Dataseries:plot',...
            'It is not possible to draw data higher than dimension 3')
end

title(gca(figHandle),Stitle,'FontSize',NfontSize);

%% Export Figure
if exist('SfigureName','var')
    if exist('Sexportformat','var')
        exportFigure('HfigureHandle',figHandle,'SfigureName',SfigureName,'SexportFormat',Sexportformat)
    else
        exportFigure('HfigureHandle',figHandle,'SfigureName',SfigureName)
    end
end

end


function ColorSet=varycolor(NumberOfPlots)
% VARYCOLOR Produces colors with maximum variation on plots with multiple
% lines.
%
%     VARYCOLOR(X) returns a matrix of dimension X by 3.  The matrix may be
%     used in conjunction with the plot command option 'color' to vary the
%     color of lines.  
%
%     Yellow and White colors were not used because of their poor
%     translation to presentations.
% 
%     Example Usage:
%         NumberOfPlots=50;
%
%         ColorSet=varycolor(NumberOfPlots);
% 
%         figure
%         hold on;
% 
%         for m=1:NumberOfPlots
%             plot(ones(20,1)*m,'Color',ColorSet(m,:))
%         end

% Copyright (c) 2008, Daniel Helmick
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%Created by Daniel Helmick 8/12/2008

narginchk(1,1)%correct number of input arguements??
nargoutchk(0, 1)%correct number of output arguements??

%Take care of the anomolies
if NumberOfPlots<1
    ColorSet=[];
elseif NumberOfPlots==1
    ColorSet=[0 1 0];
elseif NumberOfPlots==2
    ColorSet=[0 1 0; 0 1 1];
elseif NumberOfPlots==3
    ColorSet=[0 1 0; 0 1 1; 0 0 1];
elseif NumberOfPlots==4
    ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1];
elseif NumberOfPlots==5
    ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1; 1 0 0];
elseif NumberOfPlots==6
    ColorSet=[0 1 0; 0 1 1; 0 0 1; 1 0 1; 1 0 0; 0 0 0];

else %default and where this function has an actual advantage

    %we have 5 segments to distribute the plots
    EachSec=floor(NumberOfPlots/5); 
    
    %how many extra lines are there? 
    ExtraPlots=mod(NumberOfPlots,5); 
    
    %initialize our vector
    ColorSet=zeros(NumberOfPlots,3);
    
    %This is to deal with the extra plots that don't fit nicely into the
    %segments
    Adjust=zeros(1,5);
    for m=1:ExtraPlots
        Adjust(m)=1;
    end
    
    SecOne   =EachSec+Adjust(1);
    SecTwo   =EachSec+Adjust(2);
    SecThree =EachSec+Adjust(3);
    SecFour  =EachSec+Adjust(4);
    SecFive  =EachSec;

    for m=1:SecOne
        ColorSet(m,:)=[0 1 (m-1)/(SecOne-1)];
    end

    for m=1:SecTwo
        ColorSet(m+SecOne,:)=[0 (SecTwo-m)/(SecTwo) 1];
    end
    
    for m=1:SecThree
        ColorSet(m+SecOne+SecTwo,:)=[(m)/(SecThree) 0 1];
    end
    
    for m=1:SecFour
        ColorSet(m+SecOne+SecTwo+SecThree,:)=[1 0 (SecFour-m)/(SecFour)];
    end

    for m=1:SecFive
        ColorSet(m+SecOne+SecTwo+SecThree+SecFour,:)=[(SecFive-m)/(SecFive) 0 0];
    end
    
end

end