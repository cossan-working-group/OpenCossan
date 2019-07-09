function Vx = getValue(Xobj,Vvalues)
%GETVALUE This method returns the value that correspond to a specific
%percentile
%
%
%
%  Usage: GETVALUE(Xdv,[0.2; 0.4])
%
%  See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/GetValue@DesignVariable
%
%   Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
%   Author: Edoardo-Patelli

if nargin==1
    Vx=Xobj.value;
else
    
    if Xobj.Ldiscrete
        Vx = Xobj.Vsupport(floor(Vvalues*(length(Xobj.Vsupport)-1))+1);
    else
        Vx=unifinv(Vvalues,Xobj.lowerBound,Xobj.upperBound);
    end
end

