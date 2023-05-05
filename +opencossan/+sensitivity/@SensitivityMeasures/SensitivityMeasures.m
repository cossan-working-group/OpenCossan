classdef SensitivityMeasures
    %SENSITIVITYMEASURES Summary of this class goes here
    %   Detailed explanation goes here
    %
    % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SensitivityMeasures
    %
    % Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$
    % Author: Edoardo Patelli
    
    properties
        Valpha=[.05 .95];       % Confidence Intervals
        Sdescription            % Description of the object
        VtotalIndices           % Total sensitivity indices
        VtotalIndicesCoV        % Estimated error of the total sensitivity indices
        MtotalIndicesCI         % Confidence interval of the total sensitivity
                                % indices
        VupperBounds            % Upper bounds of the Total sensitivity indices
        VupperBoundsCoV         % Estimated error of the upper bounds of
                                % the total sensitivity indices
        MupperBoundsCI          % Confidence interval of the upper bounds of the
                                % total sensitivity indices
        VsobolFirstIndices      % First Sobol' indices
        VsobolFirstIndicesCoV   % Estimated error of the first order sensitivity indicies
        MsobolFirstIndicesCI    % Confidence interval of the First sensitivity indicies
        VsobolIndices           % Values of the Sobol' indices
        VsobolIndicesCoV        % Estimated error of the Sobol' indices
        MsobolIndicesCI         % Confidence interval of the  Sobol' sensitivity indicies
        CsobolComponentsIndices % Cell array of the indices of the Sobol'
        % measure
        SestimationMethod       % Method used to estimate the sensitivity
        % indices
        CinputNames             % Names of the input factors (variables)
        SoutputName             % Names of the input factors (variables)
        XevaluatedObject        % a Cossan object used to compute the
        % SoutputName factor
        SevaluatedObjectName    % Name of the Cossan object used to compute
        % the SoutputName factor
    end
    
    properties (Dependent=true)
        CsobolComponentsNames   % Names of the Components od the Sobol' indices
    end
    
    methods
        
        display(Xobj) % Show summary of the object
        
        figHandle=plot(Xobj,varargin) % Plot the Sensitivity Indices
        figHandle=plot3d(Xobj,varargin) % Plot the Sensitivity Indices in a 3d plot
        
        Xobj=merge(Xobj,Xobj2) % Merge two sensitivity measures objects
        
        function Xobj  = SensitivityMeasures(varargin) % Constructor of the SensitivityMeasures
            %% Constructor
            % This method constructs a SensitivityMeasure object. The
            % object contains the solutions of the sensitivity analysis. It
            % is constructed automatically by the methods sobol, fast,
            % morris of the sensitivity toolbox.
            % The constructor takes as inputs a variable number of optional
            % pair tokens of PropertyName and values.
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SensitivityMeasures
            %
            % Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo Patelli
            
            %% Validate input arguments
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            %%  Set values passed by the user
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case 'valpha'
                        Xobj.Valpha=varargin{k+1};
                        assert(length(Xobj.Valpha)==2,...
                            'openCOSSAN:output:SensitivityMeasures',...
                            'The length of confidence intervals (Valpha) must be 2')
                    case 'cinputnames'
                        Xobj.CinputNames=varargin{k+1};
                    case {'soutputname','soutput'}
                        Xobj.SoutputName=varargin{k+1};
                    case {'xevaluatedobject','xobject'}
                        Xobj.XevaluatedObject=varargin{k+1};
                        Xobj.SevaluatedObjectName=inputname(k+1);
                    case 'sevaluatedobjectname'
                        Xobj.SevaluatedObjectName=varargin{k+1};
                    case 'vtotalindices'
                        if iscolumn(varargin{k+1})
                            Xobj.VtotalIndices=varargin{k+1}';
                        else
                            Xobj.VtotalIndices=varargin{k+1};
                        end
                    case 'vtotalindicescov'
                        if iscolumn(varargin{k+1})
                            Xobj.VtotalIndicesCoV=varargin{k+1}';
                        else
                            Xobj.VtotalIndicesCoV=varargin{k+1};
                        end
                    case 'mtotalindicesci'
                        Xobj.MtotalIndicesCI=varargin{k+1};
                    case 'vupperbounds'
                        if iscolumn(varargin{k+1})
                            Xobj.VupperBounds=varargin{k+1}';
                        else
                            Xobj.VupperBounds=varargin{k+1};
                        end
                    case 'vupperboundscov'
                        if iscolumn(varargin{k+1})
                            Xobj.VupperBoundsCoV=varargin{k+1}';
                        else
                            Xobj.VupperBoundsCoV=varargin{k+1};
                        end
                    case 'mupperboundsci'
                        Xobj.MupperBoundsCI=varargin{k+1};
                    case 'vsobolindices'
                        if iscolumn(varargin{k+1})
                            Xobj.VsobolIndices=varargin{k+1}';
                        else
                            Xobj.VsobolIndices=varargin{k+1};
                        end
                    case 'vsobolindicescov'
                        if iscolumn(varargin{k+1})
                            Xobj.VsobolIndicesCoV=varargin{k+1}';
                        else
                            Xobj.VsobolIndicesCoV=varargin{k+1};
                        end
                    case 'msobolindicesci'
                        Xobj.MsobolIndicesCI=varargin{k+1};
                    case 'csobolcomponentsindices'
                        Xobj.CsobolComponentsIndices=varargin{k+1};
                    case {'vsobolfirstorder','vsobolfirstindices'}
                        if iscolumn(varargin{k+1})
                            Xobj.VsobolFirstIndices=varargin{k+1}';
                        else
                            Xobj.VsobolFirstIndices=varargin{k+1};
                        end
                    case {'vsobolfirstordercov','vsobolfirstindicescov'}
                        if iscolumn(varargin{k+1})
                            Xobj.VsobolFirstIndicesCoV=varargin{k+1}';
                        else
                            Xobj.VsobolFirstIndicesCoV=varargin{k+1};
                        end
                    case {'msobolfirstorderci','msobolfirstindicesci'}
                        Xobj.MsobolFirstIndicesCI=varargin{k+1};
                    case 'sestimationmethod'
                        Xobj.SestimationMethod=varargin{k+1};
                    otherwise
                        error('openCOSSAN:output:SensitivityMeasures', ...
                            ['The PropertyName ' varargin{k} ' has been ignored']);
                end
            end
            
            %% Check Object
            Ninput=length(Xobj.CinputNames);
            % Total indices
            if ~isempty(Xobj.VtotalIndices)
                assert(Ninput==length(Xobj.VtotalIndices), ...
                    'openCOSSAN:output:SensitivityMeasures',...
                    ['The length of total sensitivity indices (' ...
                    num2str(length(Xobj.VtotalIndices)) ...
                    ') must be equal to the number of input factors (' ...
                    num2str(Ninput) ')'])
            end
            % Upper bounds
            if ~isempty(Xobj.VupperBounds)
                assert(Ninput==length(Xobj.VupperBounds), ...
                    'openCOSSAN:output:SensitivityMeasures',...
                    ['The length of the  upper bounds (' ...
                    num2str(length(Xobj.VupperBounds)) ...
                    ') must be equal to the number of input factors (' ...
                    num2str(Ninput) ')'])
            end
            % Sobol' first indices
            if ~isempty(Xobj.VsobolFirstIndices)
                assert(Ninput==length(Xobj.VsobolFirstIndices), ...
                    'openCOSSAN:output:SensitivityMeasures',...
                    ['The length of First Sobol'' indices (' ...
                    num2str(length(Xobj.VsobolFirstIndices)) ...
                    ') must be equal to the number of input factors (' ...
                    num2str(Ninput) ')'])
            end
            
            assert(length(Xobj.CsobolComponentsIndices)==length(Xobj.VsobolIndices), ...
                'openCOSSAN:output:SensitivityMeasures',...
                ['The length of Sobol'' sensitivity indices (VsobolIndices) must be equal to the ' ...
                'length of CsobolComponentsIndices '])
            
            if ~isempty(Xobj.CinputNames)
                assert(isstring(Xobj.CinputNames),...
                    'openCOSSAN:output:SensitivityMeasures',...
                    'The CinputNames must be a string vector')
            end
            
            %% Check consistency of input parameters
            
            for n=1:length(Xobj.CsobolComponentsIndices)
                assert( length(Xobj.CsobolComponentsIndices{n})<= Ninput, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['It is not possible to define a Sobol'' indices of order ' ...
                    num2str(length(Xobj.CsobolComponentsIndices{n})) ' with only ' ...
                    num2str(Ninput) ' input factors']);
                
                assert( max(Xobj.CsobolComponentsIndices{n})<= Ninput, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['CsobolComponentsIndices{' num2str(n) '} refers to a component #' ...
                    num2str(max(Xobj.CsobolComponentsIndices{n})) ' but CinputNames has only ' ...
                    num2str(Ninput) ' input factors']);
                
                if length(Xobj.CsobolComponentsIndices{n})==1
                    warning('openCOSSAN:output:SensitivityMeasures', ...
                        ['CsobolComponentsIndices{' num2str(n) '} is a First Order Sobol'' indices.\n' ...
                        ' Please use VsobolFirstIndices to store this value']);
                end
                
            end
            
            %% Check Confidence Intervals
            % Total indices
            if ~isempty(Xobj.MtotalIndicesCI)
                assert(size(Xobj.MtotalIndicesCI,1)== 2, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of rows of MtotalIndicesCI (' ...
                    num2str(size(Xobj.MtotalIndicesCI,1)) ...
                    ') must be 2' ]);
                
                assert(size(Xobj.MtotalIndicesCI,2)== Ninput, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of columns of MtotalIndicesCI (' ...
                    num2str(size(Xobj.MtotalIndicesCI,2)) ...
                    ') does not match with the number of input factors ' ...
                    num2str(Ninput) ]);
            end
            % Upper bounds
            if ~isempty(Xobj.MupperBoundsCI)
                assert(size(Xobj.MupperBoundsCI,1)== 2, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of rows of MupperBoundsCI (' ...
                    num2str(size(Xobj.MupperBoundsCI,1)) ...
                    ') must be 2' ]);
                
                assert(size(Xobj.MupperBoundsCI,2)== Ninput, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of columns of MupperBoundsCI (' ...
                    num2str(size(Xobj.MupperBoundsCI,2)) ...
                    ') does not match with the number of input factors ' ...
                    num2str(Ninput) ]);
            end
            % sobol first indices
            if ~isempty(Xobj.MsobolFirstIndicesCI)
                assert(size(Xobj.MsobolFirstIndicesCI,1)== 2, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of rows of MsobolFirstIndicesCI (' ...
                    num2str(size(Xobj.MsobolFirstIndicesCI,1)) ...
                    ') must be 2' ]);
                
                assert(size(Xobj.MsobolFirstIndicesCI,2)== Ninput, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of columns of MsobolFirstIndicesCI (' ...
                    num2str(size(Xobj.MsobolFirstIndicesCI,2)) ...
                    ') does not match with the number of input factors ' ...
                    num2str(Ninput) ]);
            end
            % Sobol' indices
            if ~isempty(Xobj.MsobolIndicesCI)
                assert(size(Xobj.MsobolIndicesCI,1)== 2, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of rows of MsobolIndicesCI (' ...
                    num2str(size(Xobj.MsobolIndicesCI,1)) ...
                    ') must be 2' ]);
                
                assert(size(Xobj.MsobolIndicesCI,2)== Ninput, ...
                    'openCOSSAN:output:SensitivityMeasures', ...
                    ['Number of columns of MsobolIndicesCI (' ...
                    num2str(size(Xobj.MsobolIndicesCI,2)) ...
                    ') does not match with the number of input factors ' ...
                    num2str(Ninput) ]);
            end
            
            
        end  % end constructor
        
        function CsobolComponentsNames=get.CsobolComponentsNames(Xobj)       % number of evaluations of the constraints
            CsobolComponentsNames=cell(size(Xobj.CsobolComponentsIndices));
            for nInd=1:length(CsobolComponentsNames)
                CsobolComponentsNames{nInd}=Xobj.CinputNames{Xobj.CsobolComponentsIndices{nInd}(1)};
                for nComp=2:length(Xobj.CsobolComponentsIndices{nInd})
                    CsobolComponentsNames{nInd}=[CsobolComponentsNames{nInd} ...
                        '; ' Xobj.CinputNames{Xobj.CsobolComponentsIndices{nInd}(nComp)}];
                end
            end
        end
    end % end methods
    
end

