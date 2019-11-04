classdef ModelUpdating
    %The ModelUpdating class contains all the methods that are implemented to perform parameters Model updating
    % Detailed explanation goes here
    properties
        Sdescription         % String describing the used class
        Xmodel                 % Handle for object 'Xmodel' that will be updated
        XupdatingData     % Names of the input-output data (Experimental or synthetic) that will be used for updating
        Cinputnames        % Cell names of the input variables of the model 'Xmodel'
        Coutputnames      % Cell names of the output variables of the model 'Xmodel'
        VupperBounds      % Bounds of the updating space
        VlowerBounds      % Bounds of the updating space
        XmodelOut           % Output of the ModelUpdate process
        Regularizationfactor =0.01 %Default regularisation factor
        LuseRegularization = false %Flag for indicating the use of regularisation
        Mweighterror
        Mweightregularisation
    end
    methods
        % 'ModelUpdating' constructor that receives the passed arguments to
        % the ModelUpdating Class
        function Xobj= ModelUpdating(varargin)
            % Validation of the input arguments
            % Check varargin
            if nargin==0
                return                         % Return an empty object
            end
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            %%  Set the values of the previous defined public properties
            for k=1:2:nargin
                switch lower(varargin{k}),
                    case {'sdescription'}          %Description of the object
                        Xobj.Sdescription=varargin{k+1};
                    case {'xmodel','cxmodel'}  %Model to be updated
                        if isa(varargin{k+1},'cell'),
                            Xobj.Xmodel=varargin{k+1}{1};
                        else
                            Xobj.Xmodel=varargin{k+1};
                        end
                    case {'cinputnames'}           % The names of the updating variables
                        Xobj.Cinputnames=varargin{k+1};
                    case {'coutputnames'}           % The names of the output variables that will the needed to construct the error function
                        Xobj.Coutputnames=varargin{k+1};
                        % Assign the object that contains all the input/output data
                        % that will be sued in updating to the property 'XupdatingData'
                    case {'xupdatingdata'}
                        Xobj.XupdatingData=varargin{k+1};
                    case {'vupperbounds'}
                        Xobj.VupperBounds=varargin{k+1};
                    case {'vlowerbounds'}
                        Xobj.VlowerBounds=varargin{k+1};
                    case{'regularizationfactor'} % regularization factor
                        Xobj.Regularizationfactor = varargin{k+1};
                    case{'luseregularization'} % regularization factor
                        Xobj.LuseRegularization = varargin{k+1};
                    case{'mweightregularization'} % regularization factor
                        Xobj.Mweightregularisation = varargin{k+1};
                    case{'mweighterror'} % regularization factor
                        Xobj.Mweighterror = varargin{k+1};
                        % Other cases
                    otherwise
                        error('openCOSSAN:ModelUpdating',...
                                 'PropertyName %s not allowed for a ModelUpdating object', varargin{k})
                end
            end
            %% Input validation
            % Verify if the 'Xmodel' property is valid
            assert(~isempty(Xobj.Xmodel), ...
                'openCOSSAN:ModelUpdating','A model is required to construct a ModelUpdating object')
            %Verify if the 'cinputnames' property is valid
            if isempty(Xobj.Cinputnames)  %If there is not a 'Cinputnames' assume all the 'Cinputnames' from Xmodel as parameters to be updated
                Xobj.Cinputnames=Xobj.Xmodel.InputNames;
            else
                CinputnamesModel=Xobj.Xmodel.InputNames;  %If there exists, verify if it is a subset from Cinputnames of the Xmodel
                for n=1:length(Xobj.Cinputnames)  %If some of the 'Xobj.Cinputnames' does not belong to 'Xobj.Xmodel.Cinputnames' property give an warning message
                    assert(any(strcmp(Xobj.Cinputnames{n},CinputnamesModel)), ...
                        'openCOSSAN:ModelUpdating',...
                        strcat('The user required input ''subset'' is not available in the inputs'' model: \n', ...
                        sprintf('%s ',Xobj.Cinputnames{:}), ...
                        ' \nProvided inputs: \n', ...
                        sprintf('%s ',CinputnamesModel{:})))
                end
            end
            %%Verify if the 'CrequiredOutputs' property is valid
            if isempty(Xobj.Coutputnames)  %If there is not a 'CrequiredOutputs' assume all the 'Coutputnames' as 'CrequiredOutputs'
                Xobj.Coutputnames=Xobj.Xmodel.OutputNames;
            else
                CoutputnamesModel=Xobj.Xmodel.Coutputnames;
                for n=1:length(Xobj.Coutputnames)   %If some of the 'CrequiredOutputs' does not belong to 'CrequiredOutputs' property give an warning message
                    assert(any(strcmp(Xobj.Coutputnames{n},CoutputnamesModel)), ...
                        'openCOSSAN:ModelUpdating',...
                        strcat('The user required output ''subset'' is not available in the output'' model: \n', ...
                        sprintf('%s ',Xobj.Coutputnames{:}), ...
                        ' \nProvided inputs: \n', ...
                        sprintf('%s ',CoutputnamesModel{:})))
                end
            end
            % Verify if the 'VupperBounds' property is valid
            if isempty(Xobj.VupperBounds)
                assert(~isempty(Xobj.VupperBounds), ...
                    'openCOSSAN:ModelUpdating','Upper Bounds should be given by the user')
            else
                assert((length(Xobj.VupperBounds)==length(Xobj.Cinputnames)), ...
                    'openCOSSAN:ModelUpdating','Length of Upper Bounds should be equal to length of design variables')
            end
            % Verify if the 'VlowerBounds' property is valid
            if isempty(Xobj.VlowerBounds)
                assert(~isempty(Xobj.VlowerBounds), ...
                    'openCOSSAN:ModelUpdating','Lower Bounds should be given by the user')
            else
                assert((length(Xobj.VlowerBounds)==length(Xobj.Cinputnames)), ...
                    'openCOSSAN:ModelUpdating','Length of Lower Bounds should be equal to length of design variables')
            end
            % Verify if the 'Mweigherror' property is valid
            if isempty(Xobj.Mweighterror)
                Xobj.Mweighterror={};
            end
            % Verify if the 'Mweighregularisation' property is valid
            if isempty(Xobj.Mweightregularisation)
                Xobj.Mweightregularisation={};
            end
        end
        %% Method to show the properties of the ModelUpdating class
        % show object details
        display(Xobj);
        %%Assign to 'XmodelOut' property the resulted value of the
        %'update' method performed over 'Xobj'
        [XmodelOut,varargout] = updateSensitivity(Xobj,varargin);        
        Vout=evaluateFitness(Xobj,Minput);
    end
end

