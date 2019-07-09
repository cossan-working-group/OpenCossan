function Vx = getPercentile(Xobj,Vvalues)
%GETPERCENTILE This method returns the percentile value of the current values of
%the Design Variable or the percentile of the passed value
%
%
%
%  Usage: GETPERCENTILE(Xdv,[0.2; 0.4])
%
%  See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/getPercentile@DesignVariable

%   Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
%   Author: Edoardo-Patelli


if nargin==0
    Vvalues=Xobj.value;
end

if length(Xobj.Vsupport)>1
    [~,pos]=find(Xobj.Vsupport==Vvalues);
    
    assert(~isempty(pos),'openCOSSAN:DesignVariable:percentile', ...
        'The provided value %e is not part of the value set of DesignVariable',Vvalues);
        
    Vx=pos/length(Xobj.Vsupport);
else
    Vx=unifcdf(Vvalues,Xobj.lowerBound,Xobj.upperBound);
end

