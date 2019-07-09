function varargout = getBounds(Xobj,varargin)
%GETBOUNDS  Retrieve the bounds of variables defined in the Input object. 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getBounds@Input
%
% $Copyright~1993-2012,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo-Patelli$

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

%%  Argument Check
error('opencossan:Input:getBounds','Method to be removed to Imprecise Input!')
OpenCossan.validateCossanInputs(varargin{:});

CnamesDV=Xobj.CnamesDesignVariable;
CnamesRV=Xobj.CnamesRandomVariable;
CnamesIV=Xobj.CnamesIntervalVariable;
Cnames = [CnamesRV,CnamesIV CnamesDV];
CnamesRVSET = Xobj.CnamesRandomVariableSet;

for k=1:2:nargin-1,
    switch lower(varargin{k})
        case 'sname'
            %check input
            if ~exist('Cnames','var')
                error('openCOSSAN:Input:getBounds',...
                    'one and only one of the fields ''Cnames'' and ''Sname'' has to be specified')
            end
            Cnames = varargin(k+1);
        case {'csnames'}
            %check input
            if ~exist('Cnames','var')
                error('openCOSSAN:Input:getBounds',...
                    'one and only one of the fields ''Cnames'' and ''Sname'' has to be specified')
            end
            Cnames = varargin{k+1};
        otherwise
            error('openCOSSAN:Input:getBounds',...
                'The field (%s) is not valid for this function!',varargin{k})
    end
end


%% Check if the variable Sname is present in the Input object
% Preallocate memory


VposRandomVariable=find(ismember(Cnames,CnamesRV));
VposIntervalVariable=find(ismember(Cnames,CnamesIV));
VposDesignVariable=find(ismember(Cnames,CnamesDV));

Moutput=zeros(length(VposRandomVariable)+length(VposIntervalVariable)+length(VposDesignVariable),2);

% Collect number of random variable present for each set. 

VnumberRV=zeros(length(CnamesRVSET),1);
for n=1:length(VnumberRV)
    VnumberRV(n)=Xobj.Xrvset.(CnamesRVSET{n}).Nrv;
end
VendIndex=cumsum(VnumberRV);

% Get the values for RandomVariables
for k=1:length(CnamesRVSET)
    if k==1
        [~,VrsetIndex]=find(VposRandomVariable<=VendIndex(k));
    else
        [~,VrsetIndex]=find(VposRandomVariable<=VendIndex(k) & VposRandomVariable>VendIndex(k-1));
    end
    VboundLower=(Xobj.Xrvset.(CnamesRVSET{k}).get('lowerBound'));
    VboundUpper=(Xobj.Xrvset.(CnamesRVSET{k}).get('upperBound')); 
    
    Moutput(VposRandomVariable(VrsetIndex),:)=[VboundLower VboundUpper];
end


% Get the values for Interval Variables
if ~isempty(VposIntervalVariable)
    CBounds=cell(1,length(Xobj.CnamesBoundedSet));
    for k=1:length(Xobj.CnamesBoundedSet)
        VLB=Xobj.Xbset.(Xobj.CnamesBoundedSet{k}).VlowerBounds;
        VUB=Xobj.Xbset.(Xobj.CnamesBoundedSet{k}).VupperBounds;
        CBounds{k}=[VLB;VUB];
    end
    MBounds=cell2mat(CBounds);
    Moutput(VposIntervalVariable,:)=MBounds';
end



% Get the values for Design Variables
for k=1:length(VposDesignVariable)
    Moutput(VposDesignVariable(k),1)=...
        Xobj.XdesignVariable.(CnamesDV{VposDesignVariable(k)}).lowerBound;
    Moutput(VposDesignVariable(k),2)=...
        Xobj.XdesignVariable.(CnamesDV{VposDesignVariable(k)}).upperBound;
end

varargout{1}=Moutput(:,1)';
if nargout>1
    varargout{2}=Moutput(:,2)';
end
