function Xrvs = remove( Xrvs, Crvname )
%REMOVE: removes a RandomVariable object from a RandomVariableSet object
%
%   MANDATORY ARGUMENTS:
%    - Xrvset:    RVSET object
%    - Crvname:   cell array of the name of RandomVariables object (in the 
%                 set) to remove
%
%    OUTPUT:
%    - Xrvset:    RVSET object without the RandomVariables of interest
%
%  Usage: Xrvs = remove(Xrvs,{'Xrv1','Xrv4'})
%
%  See also: RandomVariableSet
%

if isempty(Crvname)
   error('openCOSSAN:RandomVariableSet',...
                        'the name of the random variables to remove must be specified');
end
%% get the rv to remove



for j = 1:length(Crvname)
    isFound =0;
    for i = 1:length(Xrvs.Cmembers)
        if strcmp(Xrvs.Cmembers(i) ,Crvname(j))
            idrv(i) = true;
            isFound  = 1;
        end
    end
    if ~isFound
           warning('openCOSSAN:RandomVariableSet',...
                        'no random variables with name "%s" was found', Crvname{j});
    end
end
%% remove the rv from all the fields of the set
Xrvs.Xrv(idrv) =[];
Xrvs.Cmembers(idrv)  =[];

if ~isempty(Xrvs.Mcorrelation)
Xrvs.Mcorrelation(idrv,:)  =[];
Xrvs.Mcorrelation(:,idrv)  =[];
end

if ~isempty(Xrvs.Mcovariance)
Xrvs.Mcovariance(:,idrv)  =[];
Xrvs.Mcovariance(idrv,:)  =[];
end

if ~Xrvs.Lindependence
    Xrvs = nataftransformation(Xrvs);
end

end

