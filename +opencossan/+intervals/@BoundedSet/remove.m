function Xbset = remove( Xbset, CSintervalName )
%REMOVE: removes an Interval object from a BoundedSet object
%
%   MANDATORY ARGUMENTS:
%    - Xbset:       BoundedSet object
%    - IntervalName:cell array of the name of IntervalName object (in the 
%                 set) to remove
%
%    OUTPUT:
%    - Xbset:    BoundedSet object without the IntervalName of interest
%
%

if isempty(CSintervalName)
   error('openCOSSAN:intervals:BoundedSet',...
                        'the name of the random variables to remove must be specified');
end


%% get the interval to remove

[~, V2remove] = intersect(Xbset.Cmembers,CSintervalName,'stable');

%% remove the rv from all the fields of the set
Xbset.CXint(V2remove) =[];
Xbset.Cmembers(V2remove)  =[];

if ~isempty(Xbset.Mcorrelation)
Xbset.Mcorrelation(V2remove,:)  =[];
Xbset.Mcorrelation(:,V2remove)  =[];
end

if ~isempty(Xbset.Mcovariance)
Xbset.Mcovariance(:,V2remove)  =[];
Xbset.Mcovariance(V2remove,:)  =[];
end

end
