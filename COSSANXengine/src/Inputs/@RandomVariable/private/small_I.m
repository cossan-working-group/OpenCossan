function Xobj = small_I(Xobj)
%SMALL_I compute missing parameters (if is possible) of the small I
%distribution 
%
% Input/Output is the structure of the random variable

Xobj.Sdistribution='SMALL-I';

if ~isempty(Xobj.Vdata)
            error('openCOSSAN:RandomVariable:small_I',...
            'Vdata is not available for small_I distribution');
end
if ~isempty(Xobj.std) && ~isempty(Xobj.mean)
    return;
elseif ~isempty(Xobj.CoV) && ~isempty(Xobj.mean)
    Xobj.std=abs(Xobj.mean-Xobj.shift)*Xobj.CoV;
elseif ~isempty(Xobj.std) && ~isempty(Xobj.CoV)
    Xobj.mean=Xobj.std/Xobj.CoV+Xobj.shift;
else
    error('openCOSSAN:rv:small_I','Irrelevant parameters have been used, the distribution could not be created');
end




        