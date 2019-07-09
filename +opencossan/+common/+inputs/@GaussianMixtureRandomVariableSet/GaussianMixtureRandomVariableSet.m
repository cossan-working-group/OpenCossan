classdef GaussianMixtureRandomVariableSet 
    %GAUSSIANMIXTURERANDOMVARIABLESET Summary of this class goes here 
    % An object of the GaussianRandomVariableSet class defines a Gaussian
    % mixture distribution, which is a multivariate distribution that consists
    % of a mixture of one or more multivariate Gaussian distribution components.
    % The number of components for a given gmdistribution object is fixed. Each
    % multivariate Gaussian component is defined by its mean and covariance, and
    % the mixture is defined by a vector of mixing proportions.    
    
    properties % Public Properties
        Sdescription  % GaussianMixtureDistribution 
        Cmembers      % Covariance Matrix
        Lrejection = false;
    end
    
    properties (Dependent)
        Vweights       % Weights  
        Nrv            % Number of RandomVariable
        Ncomponents    % Number of components 
    end
    
    properties (SetAccess=private)
        MdataSet          % UserData point
        Mcoeff            % Matrix of Coeff Hyperplane equation (nconstraints x ndim) 
        Vconstraints      % Constraints
        RhoThr            % Rejection rate (sampling from truncated )
        gmDistribution    % GaussianMixtureDistribution 
        Mcovariance       % Covariance Matrix
        MgmCovariance     % Covariance Matrix of the gaussian mixture distribution
        Mcorrelation      % Correlation Matrix (of the full distribution)
        Vsigma            % std in each direction 
        Mcdfs             % CDF (support) of the uncorrelated  data 
        McdfsValues       % Values of the CDFs of the uncorrelated data
        Hcdf              % Handle of the Peacewise linear interpolation for the cdf
        Hicdf             % Handle of the Peacewise linear interpolation for the inverse cdf
        MUY               % Matrix to map uncorrelated samples to correlated 
    end
    
    properties (SetAccess=private,Hidden)
        alpha=0.05              % Factor used to rescale the bandwidth 
        NcdfPoints=100          % Points used to fit the cdf
        NsamplesMapping=10000   % Samples used to estimate the covariance of the gmDistribution
        Ncopulasamples = 15000
        Ncopulabatches = 20
    end
    
    methods
        
        %% Constructor
        function Xobj = GaussianMixtureRandomVariableSet(varargin)
           % GaussianMixtureRandomVariableSet 
           % Constructor of the class GaussianMixtureRandomVariableSet

            %% Processing Inputs
            if isempty(varargin) % create an empty object
                return;
            else
                opencossan.OpenCossan.validateCossanInputs(varargin{:});
            end
            % Optional arguments
            for iVopt=1:2:length(varargin)
                    switch lower(varargin{iVopt})
                        case {'sdescription'}
                            Xobj.Sdescription=varargin{iVopt+1};
                        case {'cmembers' 'csmembers'}
                            Xobj.Cmembers=varargin{iVopt+1};
                        case 'mcovariance'
                            Xobj.Mcovariance=varargin{iVopt+1};
                        case 'mcorrelation'
                            Xobj.Mcorrelation=varargin{iVopt+1};
                        case 'vstandarddeviation'
                            VstandardDeviation=varargin{iVopt+1};
                        case 'vweights'
                            Vweights=varargin{iVopt+1};
                                                 
                        case {'mdataset','mmeans'}
                            Xobj.MdataSet=varargin{iVopt+1};
                        case 'ncomponents'
                            Ncomponents=varargin{iVopt+1};
                        case 'mcoeff'
                            Xobj.Mcoeff=varargin{iVopt+1};
                        case 'vconstraints'
                            Xobj.Vconstraints=varargin{iVopt+1};
                                                 
                        otherwise
                            error('openCOSSAN:GaussianMixtureRandomVariableSet',...
                                'PropertyName %s not allowed', varargin{iVopt})
                    end
            end
            
            %% Check Inputs
            % Mandatory fields
            assert(~isempty(Xobj.Cmembers),'openCOSSAN:GaussianMixtureRandomVariableSet',...
                   'Cmembers is required to construct an object GaussianMixtureRandomVariableSet')
             
            assert(~isempty(Xobj.MdataSet),'openCOSSAN:GaussianMixtureRandomVariableSet',...
                   'MdataSet is required to construct an object GaussianMixtureRandomVariableSet')


            % Check covariance Matrix
            if ~isempty(Xobj.Mcovariance)
                assert(size(Xobj.Mcovariance,1)==size(Xobj.Mcovariance,2), ...
                'openCOSSAN:GaussianRandomVariableSet',...
                    'The covariance matrix must be square (for each component)');
                 %TODO: Add additional checking 
            elseif ~isempty(Xobj.Mcorrelation)
              assert(logical(exist('VstandardDeviation','var')), ...
                  'openCOSSAN:GaussianMixtureRandomVariableSet',...
                   strcat('VstandardDeviation is required to construct an ', ...
                   'object GaussianMixtureRandomVariableSet using the correlation matrix'))

              assert(length(VstandardDeviation)==length(Xobj.Cmembers), ...
                'openCOSSAN:GaussianRandomVariableSet',...
                'The length of standard deviation (%i) must be equal to the number of components (%i) defined',...
                length(VstandardDeviation)==length(Xobj.Cmembers));
               
             % Compute the global covariance function from the correlation
             % function and the standard deviation vectors
%                 Xobj.Mcovariance=corr2cov(VstandardDeviation, Xobj.Mcorrelation);
                Xobj.Mcovariance=VstandardDeviation'*VstandardDeviation.*Xobj.Mcorrelation;
            else       
                % Construct covariance Matrix
                assert(size(Xobj.MdataSet,2)==length(Xobj.Cmembers),'openCOSSAN:GaussianMixtureRandomVariableSet',...
                    ['Number of colums of MdataSet (' ...
                    num2str(size(Xobj.MdataSet,2)) ...
                    ') must be equal to the number of random variable defined in the Cmembers (' ...
                    num2str(length(Xobj.Cmembers)) ')' ])

                Xobj=Xobj.computeCovarianceMatrix;
            end
            
            % Construct gmdistribution
            if exist('Ncomponents','var')
                if exist('Vweights','var')
                    warning('openCOSSAN:GaussianMixtureRandomVariableSet',...
                        'Weights ingored with fit method')
                end
                
                assert(size(Xobj.MdataSet,1)>size(Xobj.MdataSet,2),'openCOSSAN:GaussianMixtureRandomVariableSet',...
                    'Number of realizations (%i) must be larger then the number of variables (%i)', ...
                size(Xobj.MdataSet,1),size(Xobj.MdataSet,2))
                
                % Using matlab fit method
                 Xobj.gmDistribution = gmdistribution.fit(Xobj.MdataSet,Ncomponents);  
                 
                 % Overwrite Mcovariance
                 Xobj.Mcovariance=Xobj.gmDistribution.Sigma;
            else
            % Construct gmdistribution
            if exist('Vweights','var')
                assert(length(Vweights)==size(Xobj.MdataSet,1), ...
                    'openCOSSAN:GaussianMixtureRandomVariableSet',...
                    [ 'Lenght of Vweight (' num2str(length(Vweights)) ...
                      ') must be equal to the number of components (' ...
                      num2str(size(Xobj.MdataSet,1)) ')' ] );
                  
                Xobj.gmDistribution = gmdistribution(Xobj.MdataSet,Xobj.Mcovariance,Vweights);               
            else
                Xobj.gmDistribution = gmdistribution(Xobj.MdataSet,Xobj.Mcovariance);             
            end
            end
                       
            % Compute the values of the CDF for the mapping
            Xobj=computeCDF(Xobj);
            
            % Compute Mapping
            Xobj=computeMapping(Xobj);
        end
        
        function Vpdf=evalpdf(Xobj,Msamples)
            % Only evaluation in the Physical Space makes sense.
            % In the hypercube use unipdf 
            Vpdf = Xobj.gmDistribution.pdf(Msamples);
        end
         
         %% Dependen properties
        
         function Vweights=get.Vweights(Xobj)
             Vweights=Xobj.gmDistribution.PComponents;
         end
         
         function Nrv=get.Nrv(Xobj)
             Nrv=length(Xobj.Cmembers);
         end
         
         function Ncomponents=get.Ncomponents(Xobj)
             Ncomponents=Xobj.gmDistribution.NComponents;
         end

    end % method
    
    %% Private methods
    methods (Access=private)       
        Xobj=computeCovarianceMatrix(Xobj)
        Xobj=computeCDF(Xobj) % Compute the CDF and ICDF
        MphysicalSpace = generatePhysicalSamples(Xobj,Nsamples)
    end 
    
end

