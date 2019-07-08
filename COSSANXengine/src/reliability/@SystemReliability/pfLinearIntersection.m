function [Xcutset, varargout] = pfLinearIntersection(Xsys,varargin)
% PFLINEARINTERSECTION Computes the area (i.e. the FailureProbability) 
% associated to the intersection between two linear limit states functions.
% The limit state function are defined by their reliability indeces and the
% unit directions. 
% If the reliability indices and the unit direction are not passed as input
% arguments these values are retrieved from the SystemReliability object.
%
% This method returns a CutSet object and as optional output argument the
% (varargout{1}) the estimated failure probability
%
%
% Input arguments:
%   - Ccutset:  Cell of the minimal cut sets that identify 
%   - Vbeta:     Vector of the reliability indeces
%   - Malpha:    Matrix of the unit direction of each limit state function
%  Ouput arguments
%  - Xcutset:  Cut set object
%  - varargout{1}: estimated failure probability 

%% Initialize the variables
Vindex=[];
Malpha=[];
Vbeta=[];

for k=1:2:length(varargin)
	switch lower(varargin{k})
        case ('ccutset')
            Vindex=cell2mat(varargin{k+1});% User defined cut-set
        case ('malpha')
            Malpha=varargin{k+1};
        case ('vbeta')
            Vbeta=varargin{k+1};
        otherwise
		   error('openCOSSAN:reliability:SystemReliability:pfLinearIntersection',...
                ['Property name (' varargin{k} ') not valid ']);
	end
end

if length(Vindex)~=2 && (size(Malpha,1)~=2 || size(Vbeta,1)~=2  )
	error('openCOSSAN:reliability:SystemReliability:pfIntersectionLinear',...
        'Only the intersection between two limit state functions can be calculated with this method');
end

%% Get direction u1 and u2
if isempty(Malpha)
	u1=Xsys.XdesignPoints{Vindex(1)}.VDirectionDesignPointStdNormal';
	u2=Xsys.XdesignPoints{Vindex(2)}.VDirectionDesignPointStdNormal';
else
	u1=Malpha(1,:);
	u2=Malpha(2,:);
	
	if size(u1,2)~=1
		u1=u1';
		u2=u2';
	end
end

%% Get reliability index b1 and b2
if isempty(Vbeta)
    Vbeta(1)=Xsys.XdesignPoints{Vindex(1)}.ReliabilityIndex;
    Vbeta(2)=Xsys.XdesignPoints{Vindex(2)}.ReliabilityIndex;
end

if(Vbeta(1)<Vbeta(2))
    b = Vbeta(1);
    c = Vbeta(2);
else
    b = Vbeta(2);
    c = Vbeta(1);
end

%% different cases depending on alpha
%
pf_independent = cdf('norm',-b,0,1)*cdf('norm',-c,0,1);

proj = u1'*u2;
n_int = 1+round(abs(proj)*40);
dw = proj/2/n_int;
r = 0;
w = 0;
r0 = exp(-b^2/2-c^2/2);
for k=1:n_int
    r = r+r0;
    w = w+dw;
    if w>1
       break
    end
    rw = exp(-(b^2-2*w*b*c+c^2)/2/(1-w^2))/sqrt(1-w^2);
    r = r+4*rw;
    w = w+dw;
    if w>1
       break
    end
    r0 = exp(-(b^2-2*w*b*c+c^2)/2/(1-w^2))/sqrt(1-w^2);
    r = r+r0;
end
res = proj*r/6/n_int/(2*pi);
failureProbability = pf_independent+res;

%% Export variables
Xpf=FailureProbability('Smethod','LinearIntersection','pf',failureProbability);

if isempty(Xsys.XFaultTree)
    Xcutset=CutSet('VcutsetIndex',Vindex,...
                   'XFailureProbability',Xpf); 
else
    Xcutset=CutSet('XFaultTree',Xsys.XFaultTree,'VcutsetIndex',Vindex,...
                'XFailureProbability',Xpf);     
end

% Export failure probability
varargout{1}=failureProbability;
