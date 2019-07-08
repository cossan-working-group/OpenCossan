function MX = cdf2physical(Xin,MU)
%cdf2physical   
% This method maps realizations of the RandomVariables from cdf
% space to the physical space. 

if ~exist('MU','var')
     error('openCOSSAN:Input:map2standnorm', ...
		'The matrix of samples of RV in standard normal is not defined');
end
Crvname=Xin.CnamesRandomVariable;

if not(size(MU,2)==length(Crvname))
    error('openCOSSAN:Input:map2physical', ...
		'Number of columns of MU must be equal to the total number of rv''s in Input object');
end

Crvsetname=Xin.CnamesRandomVariableSet;

%% Main part 
MX=zeros(size(MU));
ivar=0;

for irvs=1:length(Crvsetname)
	Nvar=length(get(Xin.Xrvset.(Crvsetname{irvs}),'Cmembers'));
	MX(:,(1:Nvar)+ivar)=cdf2physical(Xin.Xrvset.(Crvsetname{irvs}),MU(:,(1:Nvar)+ivar));
	ivar=Nvar+ivar;
end


