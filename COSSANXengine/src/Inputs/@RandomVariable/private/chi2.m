function Xobj = chi2(Xobj)
%chi2 compute missing parameters (if is possible) of the exponential
%                       distribution
% Input/Output is the structure of the random variable

% EP: the parameter Cpar are necessary only to define the distribution
% probably it is not necessary to include them as a field of the rv

Xobj.Sdistribution='CHI2';

if ~isempty(Xobj.Vdata)
    
            error('openCOSSAN:RandomVariable:chi2',...
            'Vdata is not available for chi2 distribution');
end


if ~isempty(Xobj.Cpar{1,2})
    Xobj.Cpar{1,1}    = 'nu';
    [Xobj.mean,var] = chi2stat(Xobj.Cpar{1,2});
    Xobj.mean=Xobj.mean+Xobj.shift;
    Xobj.std=sqrt(var);
%    Xobj.CoV=Xobj.std/abs(Xobj.mean);
else
    if ~isempty(Xobj.mean)
        if Xobj.shift ~= 0;
            warning('openCOSSAN:rv:chi2',...
                'mean is computed considering shift, if possible use parameters to define shifted rv')
        end
        Xobj.std=sqrt(2*abs(Xobj.mean-Xobj.shift));
        %Xobj.CoV=Xobj.std/abs(Xobj.mean);
        Xobj.Cpar{1,1}    = 'nu';
        Xobj.Cpar{1,2}    = Xobj.mean-Xobj.shift;
    elseif ~isempty(Xobj.std) 
        if Xobj.shift ~= 0;
            warning('openCOSSAN:rv:chi2',...
                'mean is computed considering shift, if possible use parameters to define shifted rv')
        end
        Xobj.mean=(Xobj.std)^2/2+Xobj.shift;
       % Xobj.CoV=Xobj.std/abs(Xobj.mean);
        Xobj.Cpar{1,1}    = 'nu';
        Xobj.Cpar{1,2}    = Xobj.mean-Xobj.shift;
    else
        error('openCOSSAN:rv:chi2','Not enough parameters defined to identify the distribution');
    end
end
Xobj.lowerBound=Xobj.shift;

        


        