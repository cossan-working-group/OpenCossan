function Xobj = setDesignVariable(Xobj,varargin)
%SETDESIGNVARIABLE This method is used to change the samples of the design variable present in the object
%
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

OpenCossan.validateCossanInputs(varargin{:});

if isempty(varargin)
    error('COSSAN:Input:setDesignVariable',...
        'The set method makes no sense without arguments');
end

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'csnames'}
            Cnames=varargin{k+1};
            
            assert(all(ismember(Cnames,Xobj.CnamesDesignVariable)),...
                'COSSAN:Input:setDesignVariable',...
                ['Name of the design variable does not match with the names of the design variable present in the input object\n',...
                '\nAvailable DesignVariables: ' sprintf('\n* "%s"',Xobj.CnamesDesignVariable{:}), ...
                '\nRequired DesignVariables: ' sprintf('\n* "%s"',Cnames{:})])
          case {'msamples','mvalues'}
            Msamples=varargin{k+1};
         otherwise
            error('COSSAN:Input:setDesignVariable', ...
                'The PropertyName %s is not valid',varargin{k});
            
    end
end

assert(size(Msamples,2)==length(Cnames),...
      'COSSAN:Input:setDesignVariable',...
      'Number of colums of Msamples is %i, number of Design variable %i ',size(Msamples,2),length(Cnames))
    

%% DO SET
Xobj.Xsamples=Samples('Xinput',Xobj,'Msamplesdoedesignvariables',Msamples);
end



