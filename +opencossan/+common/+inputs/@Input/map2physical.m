function MX = map2physical(Xin,varargin)
%MAP2PHYSICAL   
% This method maps realizations of the RandomVariables from standard normal
% space to the physical space. 

% if ~exist('MU','var')
%      error('openCOSSAN:Input:map2standnorm', ...
% 		'The matrix of samples of RV in standard normal is not defined');
% end
MU=[];
MHS=[];
if length(varargin)==1 % only RVs
    MU=varargin{1};
    if not(or(size(MU,2)==length(Xin.RandomVariableNames),size(MU,1)==length(Xin.RandomVariableNames)))
        error('openCOSSAN:Input:map2physical', ...
            'Number of columns of MU must be equal to the total number of rv''s in Input object');
    end
    
    if size(MU,1)==(Xin.NrandomVariables)
        MU=transpose(MU);
    end
else
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'msamplestandardnormalspace','msns'}
                MU=varargin{k+1};
                if not(or(size(MU,2)==length(Xin.RandomVariableNames),size(MU,1)==length(Xin.RandomVariableNames)))
                    error('openCOSSAN:Input:map2physical', ...
                        'Number of columns of MU must be equal to the total number of rv''s in Input object');
                end
                if size(MU,1)==(length(Xin.RandomVariableNames))
                    MU=transpose(MU);
                end
            case {'msampleshypersphere','mhs'}
                MHS=varargin{k+1};
                if not(or(size(MHS,2)==length(Xin.CnamesIntervalVariable),size(MHS,1)==length(Xin.CnamesIntervalVariable)))
                    error('openCOSSAN:Input:map2physical', ...
                        'Number of columns of MU must be equal to the total number of rv''s in Input object');
                end
                if size(MHS,1)==(length(Xin.CnamesIntervalVariable))
                    MHS=transpose(MHS);
                end
            otherwise
                error('openCOSSAN:Input:map2physical',...
                    [' PropertyName %s not valid', varargin{k}'])
        end
    end
end

if isempty(MHS)
    MX=zeros(size(MU));
elseif isempty(MU)
    MX=zeros(size(MHS));
else
    assert(size(MU,1)==size(MHS,1),...
         'openCOSSAN:Input:map2physical',...
                ['The number of samples of Random Variables (%i) must be ' ...
                'equal to the number of samples of Interval Variables (%i)'])
    MX=zeros(size(MU,1),size(MU,2)+size(MHS,2));
end
        
Crvsetname=Xin.RandomVariableSetNames;
%Cbsetname=Xin.CnamesBoundedSet;
%% Main part : MAP!
ivar=0;
int=0;
for irvs=1:length(Crvsetname)
	NRvs=Xin.RandomVariableSets.(Crvsetname{irvs}).Nrv;
	MX(:,(1:NRvs)+ivar)=map2physical(Xin.RandomVariableSets.(Crvsetname{irvs}),MU(:,(1:NRvs)+ivar));
	ivar=NRvs+ivar;
end

% for ics=1:length(Cbsetname)
% 	NInt=length(get(Xin.Xbset.(Cbsetname{ics}),'Cmembers'));
% 	MX(:,Xin.NrandomVariables+(1:NInt)+int)=map2physical(Xin.Xbset.(Cbsetname{ics}),'msampleshypersphere',MHS(:,(1:NInt)+int));
% 	int=NInt+ivar;
% end

