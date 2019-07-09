function MU = cdf2stdnorm(Xin,MX)
%cdf2stdnorm   
%  This method maps a values of the RandomVariable(s) of an Input object
%  from physical space to the standard normal space.   
%
%  Arguments:
%                       MX:   Matrix of samples of RV in Physical Space (n. simulation, n. RV)
%  Example: 
%  MU=Xin.cdf2stdnorm(MX)

if ~exist('MX','var')
     error('openCOSSAN:Input:map2standnorm', ...
		'The matrix of samples of RV in Physical Space is not defined');
end

Crvname=Xin.CnamesRandomVariable;

if not(size(MX,2)==length(Crvname))
    error('openCOSSAN:Input:map2standnorm', ...
		'Number of columns must be equal to the total number of rv''s in Input object');
end

Crvsetname=Xin.CnamesRandomVariableSet;

%% Main part 
MU=zeros(size(MX));
ivar=0;

for irvs=1:length(Crvsetname)
	Nvar=length(get(Xin.Xrvset.(Crvsetname{irvs}),'Cmembers'));
	MU(:,(1:Nvar)+ivar)=cdf2stdnorm(Xin.Xrvset.(Crvsetname{irvs}),MX(:,(1:Nvar)+ivar));
	ivar=Nvar+ivar;
end


