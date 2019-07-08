classdef RandomVariableSet
    %RANDOMVARIABLESET   Construct object RANDOMVARIABLESET
    %   RANDOMVARIABLESET   constructs COSSAN-X object representing a set of rv's (COSSAN-X
    %           object representing a random variable).
    %           The rv's are assumed to be independent, unless the covariance
    %           or correlation matrix is provided. In this case, the
    %           corresponding Nataf model is constructed (to generate samples)
    %
    %   MANDATORY ARGUMENTS: -
    %
    %   OPTIONAL ARGUMENTS:
    %
    %   - Sdescription: description
    %   - Cmembers:     cell array containing names of RVs to be included
    %                   if Cmembers contains only the string '*all*', then all
    %                   the RVs in the workspace are included into the RVSET
    %   - Xrv:          array of RV objects
    %                   If the Xrv is not provided by the user the RV are loaded from the (base) workspace
    %					WARNING: The length of Xrv and Cmembers must be the same.
    %   - Nrviid:        length of the rvset of Nrv iid rv (length of Cmebers and
    %					Xrv must be 1)
    %
    %   - Mcorrelation: correlation matrix
    %   - Mcovariance: covariance matrix
    %   - Lindependence: logical variable, true if rv's are independent
    %
    %   - Nmaxeigs:  maximum number of largest magnitude eigenvalues
    %						  default value is = length(Cmembers)
    %
    %
    %   EXAMPLES:
    %
    %   Xrvs=RandomVariableSet('Sdescription','set w/ 2 rvs','Cmembers',{'X1', 'X2'});
    %   Xrvs=RandomVariableSet('Sdescription','set w/ 2 rvs','Cmembers',{'X1', 'X2'},'Xrv',Xrv);
    %   Xrvs=RandomVariableSet('Sdescription','set w/ all rvs of workspace','Cmembers',{'*all*'});
    %   Xrvs=rvRandomVariableSet('Cmembers',{'X1','X2'},'Mcorrelation',Mcorrelation);
    %
    %   See also: RandomVariable, Input
    %
    % See also: https://cossan.co.uk/wiki/index.php/@RandomVariable
    %
    % Author: Pierre Beaurepaire, Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    
    %% Public fields
    properties
        Sdescription % Description of the object
    end
    
    %% Protected fields
    properties (SetAccess=private)
        Xrv                  % Cell Array of RandomVariable objects
        Cmembers             % Names of the RandomVariable objects
        Mcorrelation         % Correlation matrix
        Mcovariance          % Covariance matrix
        Lindependence        % Flag for independent RandomVariable
        LanalyticalCopula=true % Use analytical formula to compute the nataf transformation
        McorrelationNataf    % Correlation matrix in the standard normal space
        McovarianceNataf     % Covariance matrix in the standard normal space
        MUY %matrix transforming rv's from uncorrelated std. norm. space (U) to correlated std. norm. space (Y)
        MYU %matrix transforming rv's from correlated std. norm. space (Y) to uncorrelated std. norm. space (U)
        Nmaxeigs
        Scopulatype = 'Gaussian'
        Ncopulasamples = 15000
        Ncopulabatches = 20
    end
    
    properties (Dependent = true, SetAccess = protected)
        Nrv    % Number of RandomVariable defined in the RandomVariableSet
    end
    
    %% Methods
    methods
        %% Constructor
        function Xrvset = RandomVariableSet(varargin)
            
            
            %% 1. Processing Inputs
            
            if isempty(varargin) % create an empty object
                return;
            else
                OpenCossan.validateCossanInputs(varargin{:});
                for iVopt=1:2:length(varargin)
                    switch lower(varargin{iVopt})
                        case {'sdescription'}
                            Xrvset.Sdescription=varargin{iVopt+1};
                        case {'cmembers','csmembers'}
                            Xrvset.Cmembers=varargin{iVopt+1};
                            %transpose Cmembers if inputed as a column
                            %vector
                            if size(Xrvset.Cmembers,2)==1
                                Xrvset.Cmembers=Xrvset.Cmembers';
                            end
                            % Only for IID rv
                            Sname=varargin{iVopt+1}{1};
                        case 'mcorrelation'
                            Xrvset.Mcorrelation=varargin{iVopt+1};
                            %check if the correlation matrix is symetrical
                            %with only ones on the diagonal
                            
                            if size(Xrvset.Mcorrelation,1) ~= size(Xrvset.Mcorrelation,2)
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The correlation matrix must be square');
                            end
                            for i=1:length(Xrvset.Mcorrelation)
                                if Xrvset.Mcorrelation(i,i) ~=1
                                    error('openCOSSAN:Inputs:RandomVariableSet',...
                                        'The diagonal terms of the correlation matrix must be equal to one');
                                end
                                
                                for j=i+1:length(Xrvset.Mcorrelation)
                                    if Xrvset.Mcorrelation(i,j)==0;
                                        Xrvset.Mcorrelation(i,j)= Xrvset.Mcorrelation(j,i);
                                    elseif  Xrvset.Mcorrelation(j,i)==0;
                                        Xrvset.Mcorrelation(j,i)= Xrvset.Mcorrelation(i,j);
                                    end
                                    if Xrvset.Mcorrelation(i,j) ~= Xrvset.Mcorrelation(j,i)
                                        error('openCOSSAN:Inputs:RandomVariableSet',...
                                            'The correlation matrix must be symetrical');
                                    end
                                    
                                    if abs(Xrvset.Mcorrelation(i,j))>1
                                        error('openCOSSAN:Inputs:RandomVariableSet',...
                                            'The terms of the correlation matrix must be in the range [0 1]');
                                    end
                                end
                            end
                            if min(eig(Xrvset.Mcorrelation))<0
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The correlation matrix must be positive');
                            end
                            
                            
                            
                        case 'mcovariance'
                            Xrvset.Mcovariance=varargin{iVopt+1};
                            %check if the covariance matrix is symetrical
                            %with only ones on the diagonal
                            
                            if size(Xrvset.Mcovariance,1) ~= size(Xrvset.Mcovariance,2)
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The covariance matrix must be square');
                            end
                            for i=1:length(Xrvset.Mcovariance)
                                if Xrvset.Mcovariance(i,i) <= 0
                                    error('openCOSSAN:Inputs:RandomVariableSet',...
                                        'The diagonal terms of the covariance matrix must be greater than zero');
                                end
                                
                                for j=i+1:length(Xrvset.Mcovariance)
                                    if Xrvset.Mcovariance(i,j)==0;
                                        Xrvset.Mcovariance(i,j)= Xrvset.Mcovariance(j,i);
                                    elseif  Xrvset.Mcovariance(j,i)==0;
                                        Xrvset.Mcovariance(j,i)= Xrvset.Mcovariance(i,j);
                                    end
                                    if Xrvset.Mcovariance(i,j) ~= Xrvset.Mcovariance(j,i)
                                        error('openCOSSAN:Inputs:RandomVariableSet',...
                                            'The covariance matrix must be symetrical');
                                    end
                                    
                                    if Xrvset.Mcovariance(i,j)^2 > Xrvset.Mcovariance(i,i)*Xrvset.Mcovariance(j,j)
                                        error('openCOSSAN:Inputs:RandomVariableSet',...
                                            'The correlation matrix is not valid');
                                    end
                                end
                            end
                            if min(eig(Xrvset.Mcovariance))<0
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The covariance matrix must be positive');
                            end
                        case {'nrviid','niid'}
                            Nrviid=varargin{iVopt+1};
                        case {'xrv','vxrv','xrandomvariable'}
                            Xrvset.Xrv=num2cell(varargin{iVopt+1});
                            % Only for IID rv
                            Sname=inputname(iVopt+1);
                        case {'cxrv','cxrandomvariables','cxmembers'}
                            Xrvset.Xrv=varargin{iVopt+1};
                        case {'ccxmembers'}
                            for n=1:length(varargin{iVopt+1})
                                Xrvset.Xrv{n}=varargin{iVopt+1}{n}{1};
                            end
                        case 'nmaxeigs'
                            Xrvset.Nmaxeigs=varargin{iVopt+1};
                            
                        case 'ncopulabatches'
                            Xrvset.Ncopulabatches =varargin{iVopt+1};
                        case 'ncopulasamples'
                            Xrvset.Ncopulasamples =varargin{iVopt+1};
                        otherwise
                            if isfield(Xrvset,varargin(iVopt))
                                Xrvset.(varargin{iVopt})=varargin{iVopt+1};
                            else
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    ['The PropertyName ' varargin{iVopt} ' is not valid']);
                            end
                            
                    end
                    
                end
                
                
            end
            
            %% Create an RVSET of IID RV.
            % The rv are renamed as the name of the passed rv plus _ and a progressive number
            if exist('Nrviid','var')
                
                if isempty( Xrvset.Xrv)
                    [~,Xrvset.Xrv] = addrv(Xrvset.Cmembers);
                end
                
                assert(length( Xrvset.Xrv)==1,...
                    'openCOSSAN:RandomVariableSet:WrongNumberRandomVariables',...
                        'An independant indically distributed set of RandomVariable can only be created from a single RandomVariable')
                assert(~isempty(Xrvset.Xrv),...
                    'openCOSSAN:RandomVariableSet:NoRandomVariables',...
                        'It is not possible to construct a RandomVariableSet without RandomVariable')
                
                for k=1:Nrviid
                    Xrvset.Cmembers{k}=[Sname '_' num2str(k)];
                    if ~isempty(Xrvset.Xrv)
                        Xrvset.Xrv{k}=Xrvset.Xrv{1};
                    end
                end
            end
            
            %% Check inputs
            assert(isa(Xrvset.Cmembers,'cell'),...
                'openCOSSAN:RandomVariableSet',...
                'It is mandatory to pass the name of the RandomVariables using the field Cmembers\n See help rvset')
            
            
            if ~isempty(Xrvset.Xrv) && length(Xrvset.Xrv)~=length(Xrvset.Cmembers)
                error('openCOSSAN:Inputs:RandomVariableSet',...
                    'The length of the Cmembers does NOT correspont to the length of the Xrv')
            end
            
            %% Update object fields
            if ~isempty(Xrvset.Cmembers)
                if length(Xrvset.Cmembers)==1 && strcmpi(Xrvset.Cmembers{1},'*all*')
                    OpenCossan.cossanDisp('All the RVs present in the workspace will be added to the RandomVariableSet')
                    [Xrvset.Cmembers, Xrvset.Xrv]= addall;
                    Lcheck=true;
                elseif isempty(Xrvset.Xrv)
                    [Lcheck, Xrvset.Xrv] = addrv(Xrvset.Cmembers);
                else
                    Lcheck=true;
                end
                
                if Lcheck
                    if (isequal(Xrvset.Mcorrelation,eye(size(Xrvset.Mcorrelation,1))) && ...
                            isequal(Xrvset.Mcovariance,diag(diag(Xrvset.Mcovariance)))   ),
                        Xrvset.Lindependence=true;
                        Xrvset.Mcorrelation = sparse(1:length(Xrvset.Cmembers),1:length(Xrvset.Cmembers),1);
                    else
                        
                        if ~isempty(Xrvset.Mcorrelation) % Mcorrelation given as an input
                            
                            if size(Xrvset.Mcorrelation,1) ~= Xrvset.Nrv
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The size of the covariance matrix must be equal to the number of RandomVariables')
                            end
                            
                            if ~isempty(Xrvset.Mcovariance)
                                warning('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The correlation matrix has been recalculated from the correlation matrix')
                            end
                            
                            if ~issparse(Xrvset.Mcorrelation)
                                Xrvset.Mcorrelation=sparse(Xrvset.Mcorrelation);
                            end
                            %% Compute the covariance matrix
                            Vstd=get(Xrvset,'Cmembers','std');
                            % check if the diagonal term of the correlation
                            % matrix is the variance of the random variable
                            
                            Xrvset.Mcovariance = Vstd(:) * Vstd(:)' .* Xrvset.Mcorrelation;
                        else %the covariance matrix is given as an input
                            if size(Xrvset.Mcovariance,1) ~= Xrvset.Nrv
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The size of the covariance matrix must be equal to the number of RandomVariables')
                            end
                            if ~issparse(Xrvset.Mcovariance)
                                Xrvset.Mcovariance=sparse(Xrvset.Mcovariance);
                            end
                            
                            % check if the diagonal terms are equal to the
                            % variance of the randon variables
                            Vstd=get(Xrvset,'Cmembers','std');
                            Lmod=false;
                            for iCov = 1:length(Xrvset.Mcovariance)
                                if Xrvset.Mcovariance(iCov,iCov) ~= Vstd(iCov)^2
                                    PrevValue = Xrvset.Mcovariance(iCov,iCov);
                                    Xrvset.Mcovariance(iCov,:) = Xrvset.Mcovariance(iCov,:) *Vstd(iCov)/sqrt(PrevValue);
                                    Xrvset.Mcovariance(:,iCov) = Xrvset.Mcovariance(:,iCov) *Vstd(iCov)/sqrt(PrevValue);
                                    Xrvset.Mcovariance(iCov,iCov)  = 1;
                                    Lmod=true;
                                    warning('openCOSSAN:Inputs:RandomVariableSet',...
                                        'Terms of the covariance matrix have been recalculated from variance of random variable')
                                end
                            end
                            
                            if Lmod
                                Xrvset.Mcovariance = 0.5*(Xrvset.Mcovariance + Xrvset.Mcovariance');
                            end
                            if min(eig(Xrvset.Mcovariance))<0
                                error('openCOSSAN:Inputs:RandomVariableSet',...
                                    'The covariance matrix must be positive');
                            end
                            
                            
                            %% Compute the correlation matrix
                            [~, Xrvset.Mcorrelation] = cov2corr(Xrvset.Mcovariance);
                            
                            if ~issparse(Xrvset.Mcorrelation)
                                Xrvset.Mcorrelation=sparse(Xrvset.Mcorrelation);
                            end
                        end
                        Xrvset.Lindependence = false;
                    end
                    
                    
                    %% Compute NATAF model
                    if ~Xrvset.Lindependence
                        Xrvset = natafTransformation(Xrvset);
                    end
                else
                    error('openCOSSAN:RandomVariableSet',...
                        'the RandomVariableSet can not be build because not all the random variable are present in the workspace');
                end
            end
            
            for iRv=1:length(Xrvset.Xrv)
                if isempty(Xrvset.Xrv{iRv}.Sdistribution) ||  strcmp(Xrvset.Xrv{1}.Sdistribution,'')
                    error('openCOSSAN:RandomVariableSet',...
                        'the RandomVariableSet can not be build because it contains empty random variable(s)');
                end
            end
        end %end constructor
        
        [varargout] = get(Xrvs,varargin)
        Xrvset = set(Xrvset,varargin)
        Xsample = sample(Xrvs,varargin)
        MS = map2stdnorm(Xrvs,varargin)
        MX = map2physical(Xrvs,varargin)
        varargout = evalpdf(Xrvset,varargin)
        display(Xrvset)
        MJ=jacobian(Xrvset,varargin) % Calculates the Jacobian of the Nataf model
        Vout = pdfRatio(Xrvset,varargin) % Computes the ratio between two points of the pdf
        Xrvs = remove(Xrvs, varargin)
        MX = cdf2physical(Xrvs,varargin)
        MS = cdf2stdnorm(Xrvs,varargin)
        MU = physical2cdf(Xrvs,varargin)
        MU = stdnorm2cdf(Xrvs,varargin)
        
        %% function for dependent field
        function outdata = get.Nrv(Xobj)
            outdata  = length(Xobj.Cmembers);
        end
        
        
    end % end public methods
    
    %% Private methods
    methods (Access=private)
        Xrvset=natafTransformation(Xrvset)
        Xrvset = update(Xrvset,varargin)
        Xrvset = addAllRandomVariables(Xrvset)
        Xrvset = addRandomVariable(Cmembers)
    end
    
end
