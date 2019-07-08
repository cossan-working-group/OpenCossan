function [Xobj] = uniform(Xobj)
%UNIFORM compute missing parameters (if is possible) of the lognormal
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Sdistribution='UNIFORM';
Xobj.Cpar{1,1}='lowerbound';
Xobj.Cpar{2,1}='upperbound';


if ~isempty(Xobj.Vdata)
    
    if min(size(Xobj.Vdata)) ~= 1 
            error('openCOSSAN:RandomVariable:beta',...
            'Vdata must be a vector');
    end
    
    if sum(Xobj.Vcensoring)
        error('openCOSSAN:RandomVariable:uniform',...
            'Censoring is not supported for the uniform distribution');
    end
    
    a= mle(Xobj.Vdata,'distribution','uniform','frequency',floor(Xobj.Vfrequency),...
        'alpha',Xobj. confidenceLevel);
    Xobj.Cpar{1,2}=a(1); Xobj.Cpar{2,2}=a(2);
 
    if length(Xobj.Vdata)> 100 && chi2gof(Xobj.Vdata,'cdf',@(z)cdf('uniform',z,a(1),a(2)),'nparams',2)
       warning('openCOSSAN:RandomVariable:uniform',...
            'The distribution may badly fit the input values'); 
    end
    
end


if Xobj.shift ~= 0;
    error('openCOSSAN:RandomVariable:uniform','shifted uniform distributions can not be defined, use lowerBound and upperBound ');
end
if ~isempty(Xobj.Cpar{1,2}) && ~isempty(Xobj.Cpar{2,2})
    
%     if ~isempty(Xobj.Vbounds) % gives the warning if Vbounds is not empty (Vbounds(1) exists) 
%         warning('openCOSSAN:rv:uniform','Lower bound overwitten by the parameter 1');
%     end
    Xobj.lowerBound    = Xobj.Cpar{1,2};
    
%     if length(Xobj.Vbounds)>1 % now Vbounds exists, so gives the warning if Vbounds(2) exists
%         warning('openCOSSAN:rv:uniform','Upper bound overwitten by the parameter 2');
%     end
    Xobj.upperBound    = Xobj.Cpar{2,2};
end


if ~isinf(Xobj.lowerBound) || ~isinf(Xobj.upperBound)
    if ~isempty(Xobj.lowerBound) && ~isempty(Xobj.upperBound)
        if Xobj.lowerBound> Xobj.upperBound,
            error('openCOSSAN:rv:uniform','Upper bound (2nd argument) must be greater than lower bound (1st argument).');
        end
        Xobj.mean = (Xobj.lowerBound + Xobj.upperBound) / 2;
        Xobj.std = (Xobj.upperBound - Xobj.lowerBound) / (2 * sqrt(3));
%         if Xobj.mean==0
%             Xobj.CoV=Inf;
%         else
% %             Xobj.CoV=Xobj.std/abs(Xobj.mean);
%         end
    end
    Xobj.Cpar{1,2}=Xobj.lowerBound;
    Xobj.Cpar{2,2}=Xobj.upperBound;
else
    if ~isempty(Xobj.std) && ~isempty(Xobj.mean)
         
    elseif ~isempty(Xobj.CoV) && ~isempty(Xobj.mean)
        Xobj.std=abs(Xobj.mean)*Xobj.CoV;
    elseif ~isempty(Xobj.std) && ~isempty(Xobj.CoV)
        Xobj.mean=Xobj.std/Xobj.CoV;
    else
        error('openCOSSAN:rv:normal','Not enough parameters defined to identify the distribution');
    end
    Xobj.lowerBound    = Xobj.mean-sqrt(3)*Xobj.std;
    Xobj.upperBound    = Xobj.mean+sqrt(3)*Xobj.std;
    Xobj.Cpar{1,2} = Xobj.lowerBound;
    Xobj.Cpar{2,2} = Xobj.upperBound;
end
