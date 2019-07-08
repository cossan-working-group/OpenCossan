classdef RandomVariable
%RANDOMVARIABLE this class define a RandomVariable objects
%    
%  See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@RandomVariable
%
% $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% Author: Edoardo Patelli and Pierre Beaurepiere
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
    
    properties
        Sdescription              % descriptions of the object
    end
    
    properties (SetAccess=protected)
        Sdistribution             % distribution name
        mean                      % mean value
        std                       % standard deviation
        upperBound=Inf            % lower bound for truncated distribution and uniform
        lowerBound=-Inf           % upper bound for truncated distribution and uniform
        Cpar=cell(4,2)            % cell array of parameters of the random variable (content depends on the distribution)
        shift=0                   % shift of distribution
                                  %* data related to fitted distributions
        Vdata=[]                  % array of data containing realizations of the distribution
        Vfrequency =[]            % array of frequency of the realizations of Vdata
        Vcensoring =[]            % array of booleens of censoring of Vdata
        confidenceLevel=.05       % confidence lvl
    end
    %
    properties (Dependent = true, SetAccess = protected)
        CoV                       % Coefficient of Variation
    end
    %
    methods
        %% constructor
        function Xobj=RandomVariable(varargin)
            %RANDOMVARIABLE   The constructor RANDOMVARIABLE takes a variable number of token value pairs.
            %   These pairs set properties (optional values) of the RandomVariable method.
            %
            % See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@RandomVariable
            %
            % $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
            % $Author: Edoardo-Patelli$
            
            % Return an empty object if not input arguments are passed 
            if isempty(varargin)
                return
            end
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sdistribution'}
                        Xobj.Sdistribution=varargin{k+1};
                    case {'mean'}
                        Xobj.mean=varargin{k+1};
                    case {'std','standarddeviation'}
                        % check  std>=0
                        if varargin{k+1}>0
                            Xobj.std=varargin{k+1};
                        else
                            error('openCOSSAN:RandomVariable:RandomVariable',...
                                'The standard deviation has to be greater than zero');
                        end
                    case {'var','variance'}
                        if varargin{k+1}>0
                            Xobj.std=sqrt(varargin{k+1});
                        else
                            error('openCOSSAN:RandomVariable:RandomVariable',...
                                'The variance has to be greater than zero');
                        end
                    case {'vdata'}
                        Xobj.Vdata=(varargin{k+1});
                    case {'upperbound'}
                        Xobj.upperBound=varargin{k+1};
                    case {'lowerbound'}
                        Xobj.lowerBound=varargin{k+1};
                    case {'cpar'}                        
                        %transpose Cmembers if inputed as a column
                        %vector
                        if ~isa(varargin{k+1}{1,2},'numeric')
                            varargin{k+1}=varargin{k+1}';
                        end
                        
                        for i=1:size(varargin{k+1},1);
                            if ~isa(varargin{k+1}{i,2},'numeric')
                                error('openCOSSAN:RandomVariable:RandomVariable',...
                                    'the syntax of the field Cpar is not valid');
                            end
                            Xobj.Cpar{i,2}=varargin{k+1}{i,2};
                        end
                    case {'parameter1','par1'}
                        Xobj.Cpar{1,1}='par1';
                        Xobj.Cpar{1,2}=varargin{k+1};
                    case {'parameter2','par2'}
                        Xobj.Cpar{2,1}='par2';
                        Xobj.Cpar{2,2}=varargin{k+1};
                    case {'parameter3','par3'}
                        Xobj.Cpar{3,1}='par3';
                        Xobj.Cpar{3,2}=varargin{k+1};
                    case {'parameter4','par4'}
                        Xobj.Cpar{4,1}='par4';
                        Xobj.Cpar{4,2}=varargin{k+1};
                    case {'shift'}
                        Xobj.shift=varargin{k+1};
                        %CoV, is not cumputed now
                    case {'cov'}
                        if varargin{k+1}<=0
                            error('openCOSSAN:RandomVariable:RandomVariable',...
                                'The coefficient of variation (CoV) of a RandomVariable must be strictly greater than zero');
                        end
                        CoV =varargin{k+1};
                        
                    case {'vfrequency'}
                        % check that all the values in Vfrequency are
                        % integers
                        assert(all(varargin{k+1}==floor(varargin{k+1})),...
                            'openCOSSAN:RandomVariable:RandomVariable',...
                            'All the elements of Vfrequency must be integers')
                        Xobj.Vfrequency=varargin{k+1};
                    case {'vcensoring'}
                        assert(all(varargin{k+1}==logical(varargin{k+1})),...
                            'openCOSSAN:RandomVariable:RandomVariable',...
                            'All the elements of Vcensoring must be logicals')
                        Xobj.Vcensoring=varargin{k+1};
                    case {'confidencelevel'}
                        Xobj.confidenceLevel=varargin{k+1};
                    otherwise
                        error('openCOSSAN:RandomVariable:RandomVariable',...
                            'PropertyName %s is not allowed', varargin{k});
                end
            end
            
            if exist('CoV','var')
                if isinf(CoV)
                    error('openCOSSAN:RandomVariable:RandomVariable',...
                        'CoV = +/- Inf is not allowed in the constructor');
                end
                if ~isempty(Xobj.mean)
                    Xobj.std=abs(Xobj.mean)*CoV;
                elseif ~isempty(Xobj.std)
                    Xobj.mean=abs(Xobj.std)/CoV;
                end
            end
            
            if ~isempty(Xobj.Vdata)
                
                if isempty(Xobj.Vfrequency)
                    Xobj.Vfrequency = ones(size(Xobj.Vdata));
                elseif size(Xobj.Vdata,1) ~=size(Xobj.Vfrequency,1) || ...
                        size(Xobj.Vdata,2) ~=size(Xobj.Vfrequency,2)
                    error('openCOSSAN:RandomVariable:RandomVariable',...
                        'Vdata and Vfrequency must have the same size');
                end
                
                if isempty(Xobj.Vcensoring)
                    Xobj.Vcensoring = false(size(Xobj.Vdata));
                elseif size(Xobj.Vdata,1) ~=size(Xobj.Vcensoring,1) || ...
                        size(Xobj.Vdata,2) ~=size(Xobj.Vcensoring,2)
                    error('openCOSSAN:RandomVariable:RandomVariable',...
                        'Vdata and Vcensoring must have the same size');
                end
            end
            
            % Check the defined distributions
            Xobj=checkDistribution(Xobj);
        end % end constructor
        
        % Method for dependent properties
        function CoV = get.CoV(Xobj)
            CoV = Xobj.std/abs(Xobj.mean);
        end 
        
        % Methods
        Xobj=display(Xobj);
        Xobj=evalpdf(Xobj,Vx);
        Xobj=get(Xobj,varargin);
        Xobj=map2physical(Xobj,varargin);
        Xobj=sample(Xobj,varargin);
        Xobj=set(Xobj,varargin);
        Xdv=randomVariable2designVariable(Xobj);
        VU = physical2cdf(Xobj,VX)
        VX = cdf2physical(Xobj,VU)        
        [Vbins, Vpdf]=getPdf(Xobj,varargin)
    end
    
    methods(Static)
        VU = stdnorm2cdf(VX)
        VX = cdf2stdnorm(VU)
    end
    
    methods (Access=private) % This methods are acceccible only from this class
        Xobj=checkDistribution(Xobj);
        % supported distributions
        Xobj=weibull(Xobj);
        Xobj=chi2(Xobj);
        Xobj=betaDistribution(Xobj);
        Xobj=gammaDistribution(Xobj);
        Xobj=exponential(Xobj);
        Xobj=generalizedPareto(Xobj)
        Xobj=large_I(Xobj);
        Xobj=large_II(Xobj);
        Xobj=lognormal(Xobj);
        Xobj=logistic(Xobj);
        Xobj=normt(Xobj);
        Xobj=rayleigh(Xobj);
        Xobj=student(Xobj);
        Xobj=small_I(Xobj);
        Xobj=uniform(Xobj);
        Xobj=uniformdiscrete(Xobj);
        Xobj=fDistribution(Xobj);
        Xobj=poisson(Xobj);
        Xobj=binomial(Xobj);
        Xobj=geometric(Xobj);
        Xobj=hypergeometric(Xobj);
        Xobj=negativebinomial(Xobj);
    end          
end

