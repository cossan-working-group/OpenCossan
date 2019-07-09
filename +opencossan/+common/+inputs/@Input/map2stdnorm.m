function MU = map2stdnorm(Xin,MX)
%map2stdnorm   
%  This method maps a values of the RandomVariable(s) of an Input object
%  from physical space to the standard normal space.   
%
%  Arguments:
%                       MX:   Matrix of samples of RV in Physical Space (n. simulation, n. RV)
%  Example: 
%  MU=Xin.map2stdnorm(MX)

if ~exist('MX','var')
     error('openCOSSAN:Input:map2standnorm', ...
		'The matrix of samples of RV in Physical Space is not defined');
end

Crvname=Xin.RandomVariableNames;

if size(MX,2)==length(Crvname)
    Mx=MX;
elseif size(MX,1)==length(Crvname)
    Mx=transpose(MX);
else
    error('openCOSSAN:Input:map2standnorm', ...
		'Number of columns must be equal to the total number of rv''s in Input object');
end

Crvsetname=Xin.RandomVariableSetNames;

%% Main part 
MU=zeros(size(Mx));
ivar=0;

for irvs=1:length(Crvsetname)
	Nvar=length(Xin.RandomVariableSets.(Crvsetname{irvs}).Members);
	MU(:,(1:Nvar)+ivar)=map2stdnorm(Xin.RandomVariableSets.(Crvsetname{irvs}),Mx(:,(1:Nvar)+ivar));
	ivar=Nvar+ivar;
end

% temporary fix, I think it is better to use Samples...
maxSNSvalue = norminv(1-0.5*eps(1));
MU(MU>maxSNSvalue) = maxSNSvalue;
MU(MU<-maxSNSvalue) = -maxSNSvalue;

% return the matrix in the original order
if size(MU,2)==size(MX,1)
    MU=transpose(MU);  
end
