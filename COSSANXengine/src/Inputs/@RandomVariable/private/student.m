function Xobj = student(Xobj)
%STUDENT compute missing parameters (if is possible) of the student
%                       distribution
% Input/Output is the structure of the random variable

Xobj.Cpar{1,1}    = 'nu';
Xobj.Sdistribution='STUDENT';

if ~isempty(Xobj.Vdata)
    
            error('openCOSSAN:RandomVariable:student',...
            'Vdata is not available for student distribution');
end

if isempty(Xobj.Cpar{1,2})
    error('openCOSSAN:RandomVariable:student','student can be defined only via parameter1');
end


if Xobj.Cpar{1,2}<=0
    error('openCOSSAN:RandomVariable:student','the parameter defining student distribution must be greater than zero');
end


[Nmean,Nvar]=tstat(Xobj.Cpar{1,2});


Xobj.mean = Nmean+Xobj.shift; 
Xobj.std  = sqrt(Nvar);

