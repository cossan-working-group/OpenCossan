function failureProbability = pfIntersectionLinear(Xsys,varargin)
% Computes the area (FailureProbability) associated to the intersection between two linear limit
% states specified by the reliability indices b1 and b2 and the unit
% directions u1 and u2


Vindex=[];
Malpha=[];
Mdp=[];

for k=1:2:length(varargin)
	switch lower(varargin{k})
		case {'vindex'}
			Vindex=varargin{k+1};
		case {'malpha_u','malpha'}
			Malpha=varargin{k+1};
		case {'mdp','mdp_u'}
			Mdp=varargin{k+1};
        otherwise
		   error('openCOSSAN:reliability:SystemReliability:pfIntersectionLinear',...
                ['Property name (' varargin{k} ') not valid ']);
	end
end

if length(Vindex)~=2 && (size(Malpha,1)~=2 || size(Mdp,1)~=2  )
	error('openCOSSAN:reliability:SystemReliability:pfIntersectionLinear',...
        'Only the intersection between two limit state function can be calculated with this method');
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
b1=Xsys.XdesignPoints{Vindex(1)}.ReliabilityIndex;
b2=Xsys.XdesignPoints{Vindex(2)}.ReliabilityIndex;

if(b1<b2)
    b = b1;
    c = b2;
else
    b = b2;
    c = b1;
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
    rw = exp(-(b^2-2*w*b*c+c^2)/2/(1-w^2))/sqrt(1-w^2);
    r = r+4*rw;
    w = w+dw;
    r0 = exp(-(b^2-2*w*b*c+c^2)/2/(1-w^2))/sqrt(1-w^2);
    r = r+r0;
end
res = proj*r/6/n_int/(2*pi);
failureProbability = pf_independent+res;
