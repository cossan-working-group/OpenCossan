function [Xobj] = normal(Xobj)
%UNIFORM compute missing parameters (if is possible) of the lognormal
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Sdistribution='NORMAL';

if Xobj.shift ~= 0;
    error('openCOSSAN:RandomVariable:normal','shifted normal distributions can not be defined, use the moments');
end
if ~isempty(Xobj.Vdata)
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:normal',...
            'Vdata must be a vector');
    end
    a= mle(Xobj.Vdata,'distribution','normal','frequency',Xobj.Vfrequency, 'censoring',  Xobj.Vcensoring, ...
      'alpha',Xobj. confidenceLevel);
  
    Xobj.mean=a(1); Xobj.std=a(2);
    
    if length(Xobj.Vdata)>15 && chi2gof(Xobj.Vdata,'cdf',@(z)normcdf(z,a(1),a(2)),'nparams',2)
       warning('openCOSSAN:RandomVariable:normal',...
            'The distribution badly fits the input values'); 
    end
end

assert(~isempty(Xobj.std),'openCOSSAN:RandomVariable','Not enough parameters defined to identify the distribution');
