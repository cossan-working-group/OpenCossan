function Moutput = getValues(Xobj,varargin)
%getValues Retrieve the values of a variable present in the
%          Input Object
%
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getValues@Input
%
% ==============================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% ==============================================================================      
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
% Author: Edoardo Patelli Pierre Beaurepaire

%% Initialize variables

%%  Argument Check

OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:nargin-1,
    switch lower(varargin{k})
        case {'sname','sobjectname'}
            %check input
            if exist('Cnames','var')
                error('openCOSSAN:Input:getValues',...
                    'one and only one of the fields ''Cnames'' and ''Sname'' has to be specified')
            end
            Cnames = varargin(k+1);
        case {'cnames' 'csnames'}
            %check input
            if exist('Cnames','var')
                error('openCOSSAN:Input:getValues',...
                    'one and only one of the fields ''Cnames'' and ''Sname'' has to be specified')
            end
            Cnames = varargin{k+1};
        otherwise
            error('openCOSSAN:Input:getValues', ...
                'PropertyName %s is not valid ', varargin{k})
    end
end

if ~exist('Cnames','var')
    error('openCOSSAN:Input:getValues',...
        'It is a mandatory to specify the name(s) of the variable(s)')
end

%% Check if the variable Sname is present in the Input object
Crv        = Xobj.CnamesRandomVariable;
Civ        = Xobj.CnamesIntervalVariable;
Cfun       = Xobj.CnamesFunction;
Cparanames = Xobj.CnamesParameter;
Csp        = Xobj.CnamesStochasticProcess;
Cdv        = Xobj.CnamesDesignVariable;

% Preallocate memory
Moutput=zeros(max(Xobj.Nsamples,1),length(Cnames));

for k=1:length(Cnames)
    Sname=Cnames{k};
    %% check if the variable is a RandomVariable
    ipos=find(strcmp(Crv,Sname),1);
    if ~isempty(ipos)
        if isempty(Xobj.Xsamples)
            % if the sample object is not defined it is not possible to retrive the
            % values of the variable
            error('openCOSSAN:Input:getValues',...
                    'if the sample object is not defined it is not possible to retrive values from the RandomVariable');
                % maybe should return the median?
        else
             Moutput(:,k) = Xobj.Xsamples.MsamplesPhysicalSpace(:,ipos);
        end
    end
    
    %% check if the variable is a IntervalVariable
    ipos=find(strcmp(Civ,Sname),1);
    if ~isempty(ipos)
        if isempty(Xobj.Xsamples)
            % if the sample object is not defined it is not possible to retrive the
            % values of the variable
            error('openCOSSAN:Input:getValues',...
                    'if the sample object is not defined it is not possible to retrive values from the IntervalVariable');
                % maybe should return the centre?
        else
             Moutput(:,k) = Xobj.Xsamples.MsamplesEpistemicSpace(:,ipos);
        end
    end
    
    %% check if the variable is a Function
    ipos=find(strcmp(Cfun,Sname),1);
    if ~isempty(ipos)
        if isempty(Xobj.Xsamples)
            if ~isempty(fields(Xobj.Xrvset))
                error('openCOSSAN:Input:getValues',...
                    'Samples are required to evaluate the Function');
            end
            
        end
        Moutput(:,k) = cell2float(Xobj.evaluateFunction('Sname',Sname));
    end
    
    %% check if the variable is a Parameter
    ipos=find(strcmp(Cparanames,Sname),1);
    if ~isempty(ipos)
        % is a Parameter
        
        Nl=length(Xobj.Xparameters.(Cparanames{ipos}).value) ;
        if Nl >1
            warning('openCOSSAN:Input:getValues',...
                'Only the first member of the array Parameter is provided');
            
        end
        
        Moutput(:,k) = Xobj.Xparameters.(Cparanames{ipos}).value(1);
        
    end
    
    %% check if the variable is a StochasticProcess
    ipos=find(strcmp(Csp,Sname),1);
    if ~isempty(ipos)
        if isempty(Xobj.Xsamples)
            % if the sample object is not define it is not possible to retrive the
            % values of the StochasticProcess
        else
            Moutput(:,k) = [];
        end
    end
    
    %% check if the variable is a DesignVariable
    ipos=find(strcmp(Cdv,Sname),1);
    if ~isempty(ipos)
        if ~isempty(Xobj.Xsamples)
            Moutput(:,k) = Xobj.Xsamples.MdoeDesignVariables(:,ipos);
        else
            Moutput(:,k) = Xobj.XdesignVariable.(Cdv{ipos}).value;
            OpenCossan.cossanDisp(['getValues returns the current value of the DesignVariable ' Sname],4)
        end
    end
end






