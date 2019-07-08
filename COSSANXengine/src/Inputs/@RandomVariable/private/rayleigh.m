function Xobj = rayleigh(Xobj)
%RAYLEIGH compute missing parameters (if is possible) of the rayleigth
%distribution
%
% Input/Output is the structure of the random variable


Xobj.Sdistribution='RAYLEIGH';
Xobj.Cpar{1} = 'sigma';

if ~isempty(Xobj.Vdata)
    
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:rayleigh',...
            'Vdata must be a vector');
    end
    
    
    
    if sum(Xobj.Vcensoring)
        error('openCOSSAN:RandomVariable:rayleigh',...
            'Censoring is not supported for the rayleigh distribution');
    end
    
    a= mle(Xobj.Vdata,'distribution','rayleigh','frequency',floor(Xobj.Vfrequency),  ...
      'alpha',Xobj. confidenceLevel);
  
    Xobj.Cpar{1,2}=a(1);
     
    if length(Xobj.Vdata)>15 && chi2gof(Xobj.Vdata,'cdf',@(z)cdf('rayleigh',z,a(1)),'nparams',1)
       warning('openCOSSAN:RandomVariable:normal',...
            'The distribution may badly fit the input values'); 
    end
 
 
end


if ~isempty(Xobj.Cpar{1,2})
    if ~isempty(Xobj.Cpar{2,2})
        Xobj.shift = Xobj.Cpar{2,2};
    end
     [Xobj.mean,var]     =  raylstat(Xobj.Cpar{1,2});
     Xobj.mean = Xobj.mean +Xobj.shift; 
     Xobj.std  = sqrt(var);
%     Xobj.CoV=Xobj.std/abs(Xobj.mean);
else
    % In rayleigh distribution, the CoV is constant
    if ~isempty(Xobj.mean) && ~isempty(Xobj.std)
        error('openCOSSAN:rv:rayleigh','It is not possible to set the mean and standard deviation in a Rayleigh distribution');
    elseif ~isempty(Xobj.mean) && ~isempty(Xobj.CoV)
        error('openCOSSAN:rv:rayleigh','It is not possible to set the mean and CoV in a Rayleigh distribution');
    elseif ~isempty(Xobj.std) && ~isempty(Xobj.CoV)
        error('openCOSSAN:rv:rayleigh','It is not possible to set the standard deviation and CoV in a Rayleigh distribution');
    elseif ~isempty(Xobj.CoV)
        error('openCOSSAN:rv:rayleigh','It is not possible to set the CoV of a Rayleigh distribution');
    elseif ~isempty(Xobj.CoV)
        error('openCOSSAN:rv:rayleigh','It is not possible to set the CoV of a Rayleigh distribution');
    end
    % In rayleigh distribution, the CoV is constant
    [mu, sigma2] = raylstat(1);
    CoV = sqrt(sigma2)/mu;
    if ~isempty(Xobj.mean)
        Xobj.Cpar{1,2} = (Xobj.mean-Xobj.shift)/sqrt(pi/2);
        Xobj.std = CoV/abs(Xobj.mean);
      %  Xobj.CoV=Xobj.std/abs(Xobj.mean);
    elseif ~isempty(Xobj.std)
        Xobj.Cpar{1,2} = Xobj.std/sqrt((4-pi)/2);
        Xobj.mean = CoV/Xobj.std+Xobj.shift;
      %  Xobj.CoV=Xobj.std/abs(Xobj.mean);
    else
        error('openCOSSAN:rv:rayleigh','Not enough parameters defined to identify the distribution');
    end
end
Xobj.lowerBound=Xobj.shift;


        
