function Xobj = normt(Xobj)
%NORMT compute missing parameters (if is possible) of the normal
%                       distribution
% Input/Output is the structure of the random variable
%
% The distribution is defiined using four parameters
% parameter1: mean of the untrucated distribution
% parameter2: standart deviation of the untrucated distribution
%lowerBound: lower bound of the distribution (can be equal to -Inf)
% upperBound : upper bound of the distribution (can be equal to Inf)

if Xobj.shift ~= 0;
    error('openCOSSAN:rv:normal','shifted normal distributions can not be defined, use mean');
end

if ~isempty(Xobj.Vdata)
    
            error('openCOSSAN:RandomVariable:normt',...
            'Vdata is not available for normt distribution');
end



if isempty(Xobj.Cpar{1,2}) || isempty(Xobj.Cpar{2,2})  || isempty(Xobj.lowerBound)  ||isempty(Xobj.upperBound)
    error('openCOSSAN:rv:truncnormal','truncated normal can be defined only via 2 parameters and the uuper and lower truncation bounds');
end
% Xobj.Cpar{1,1}    = 'm';
% Xobj.Cpar{2,1}    = 's';

Xobj.Sdistribution='NORMT';
%parameters of the untruncated normal distribution
m=Xobj.Cpar{1,2};
s=Xobj.Cpar{2,2};
% truncation limits
a=Xobj.lowerBound;
b=Xobj.upperBound;
if a==b
    error('openCOSSAN:rv:truncnormal','parameter3 and parameter4 can not be equal');
elseif a>b
    c=a;
    a=b;
    b=c;

end
    Xobj.Cpar{3,2}=a;
    Xobj.Cpar{4,2}=b;
% 'truncation limits' in the normal space
aa = (a-m)/s;
bb = (b-m)/s;

Nmean = m + s*(normpdf(aa,0,1) - normpdf(bb,0,1))/(normcdf(bb,0,1) - normcdf(aa,0,1));
if aa==-Inf
    Nvar = s^2 *(1 + ( - bb*normpdf(bb,0,1))/(normcdf(bb,0,1) - normcdf(aa,0,1)) - ((normpdf(aa,0,1) - normpdf(bb,0,1))/(normcdf(bb,0,1) - normcdf(aa,0,1)))^2 );
elseif bb==Inf
    Nvar = s^2 *(1 + (aa*normpdf(aa,0,1))/(normcdf(bb,0,1) - normcdf(aa,0,1)) - ((normpdf(aa,0,1) - normpdf(bb,0,1))/(normcdf(bb,0,1) - normcdf(aa,0,1)))^2 );
else
    Nvar = s^2 *(1 + (aa*normpdf(aa,0,1) - bb*normpdf(bb,0,1))/(normcdf(bb,0,1) - normcdf(aa,0,1)) - ((normpdf(aa,0,1) - normpdf(bb,0,1))/(normcdf(bb,0,1) - normcdf(aa,0,1)))^2 );
end

Xobj.mean = Nmean; 
Xobj.std  = sqrt(Nvar);
%Xobj.CoV   = Xobj.std/abs(Xobj.mean);


  
end
