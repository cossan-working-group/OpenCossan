function Xinput = add(Xinput,varargin)
%ADD This method add an object to the Input object.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Add@Input
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$

%% Process inputs
OpenCossan.validateCossanInputs(varargin{:});

if strcmpi(inputname(2),'')
    for k=1:2:length(varargin)
        switch lower(varargin{k})
            case {'xmember'} 
                XaddObject = varargin{k+1};
            case {'sname'} 
                Sname = varargin{k+1};
            otherwise
                error('openCOSSAN:Input:add:wronginput',...
                    'Argument name %s not valid',varargin{k})
        end
    end
end

%% Processing Inputs
switch class(XaddObject)
    case 'Parameter'
        if ~isfield(Xinput.Xparameters,Sname)
            Xinput.Xparameters.(Sname)=XaddObject;
            % OpenCossan.cossanDisp('Parameter object added to Input object');
        else
            warning('openCOSSAN:inputs:Inputs:add', ...
                'The object %s of type %s is already present in the Input object', ...
                Sname,class(XaddObject));
        end
    case 'DesignVariable'
        Xinput.Xsamples =[];
        if ~isfield(Xinput.XdesignVariable,Sname)
            Xinput.XdesignVariable.(Sname)=XaddObject;
            % OpenCossan.cossanDisp('Parameter object added to Input object');
        else
            warning('openCOSSAN:inputs:Inputs:add', ...
                'The object %s of type %s is already present in the Input object', ...
                Sname,class(XaddObject));
        end
    case {'RandomVariableSet','GaussianMixtureRandomVariableSet'}
        
        %% Check for duplicated Input variables
        assert(sum(ismember(Xinput.CnamesRandomVariable,XaddObject.Cmembers))==0, ...
            'openCOSSAN:Inputs:merge', ...
            strcat('It is not possible to add the object %s (of type %s) to the Input objects!\n', ...
            'Receiver object contains the following variables: %s\n', ...
            'The applied object contains the following variables: %s'), ...
            Sname,class(XaddObject),sprintf('"%s" ',Xinput.CnamesRandomVariable{:}),...
            sprintf('"%s" ',XaddObject.Cmembers{:}))
        
        Xinput.Xsamples =[]; % Remove Samples object
        if ~isfield(Xinput.Xrvset,Sname),
            Xinput.Xrvset.(Sname)=XaddObject;
            % OpenCossan.cossanDisp('RandomVariableSet object added to Input object');
        else
            warning('openCOSSAN:inputs:Inputs:add', ...
                'The object %s of type %s is already present in the Input object', ...
                Sname,class(XaddObject));
        end
        
    case 'StochasticProcess'
        Xinput.Xsamples =[];
        if ~isfield(Xinput.Xsp,Sname)
            Xinput.Xsp.(Sname)=XaddObject;
            %  OpenCossan.cossanDisp('XStochasticProcess object added to Xinput');
            
            if isempty(Xinput.Xsp.(Sname).McovarianceEigenvectors)
                error('openCOSSAN:Input',...
                    'The KL-terms of the stochastic process are not determined');
            end
            
        else
            warning('openCOSSAN:inputs:Inputs:add', ...
                'The object %s of type %s is already present in the Input object', ...
                inputname(2),class(XaddObject));
        end
    case 'Function'
        Xinput.Xsamples =[];
        if ~isfield(Xinput.Xfunctions,Sname)
            Xinput.Xfunctions.(Sname)=XaddObject;
            %  OpenCossan.cossanDisp('Function object added to Input');
            
        else
            warning('openCOSSAN:inputs:Inputs:add', ...
                'The object %s of type %s is already present in the Input object', ...
                inputname(2),class(XaddObject));
        end
    case 'Samples'
        if ~isa(Xinput.Xsamples,'Samples')
            Xinput.Xsamples     = XaddObject;
        else
            Xinput.Xsamples     = add(Xinput.Xsamples,'Xsamples', XaddObject);
        end
    otherwise
        error('openCOSSAN:inputs:Inputs:add', ...
            'The object type %s can not be added to the Input object',class(XaddObject));
end


if Xinput.LcheckFunctions
    checkFunction( Xinput );
end


