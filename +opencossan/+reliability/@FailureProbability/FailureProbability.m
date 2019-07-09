classdef FailureProbability
    %FailureProbability This class define teh FailureProbability Output.
    %   The object contains the failure probability (pf) estimated by
    %   simulation methods.
    
    properties (SetAccess = protected) % Public get access
        Smethod                   % Simulation method used to generate samples
        Vsamples                  % Number of samples associated to each batch
        Vlines                    % Number of lines associated to each batch
        Vpf                       % failure probability associated to each batch
        VvariancePf               % variance of the pf estimator of each batch
        VsecondMoment             % variance of the quantity of interest
        SperformanceFunction      % Name of the performance function
        SweigthsName              % Name of the weigths
        stdDeviationIndicatorFunction  % Standard deviation associated with
        % indicator function; in case this value is different from zero,
        % the original indicator function, i.e a Heaviside function, is
        % replaced by the CDF of a Gaussian distribution with zero mean
        % and the std. deviation equal to stdDeviationIndicatorFunction
    end
    
    properties  % Public  access
        Sdescription              % Description of the object
        SexitFlag                 % Description of the termination criteria
    end
    
    properties (Dependent = true, SetAccess = protected)
        Nbatches                  % Description of the object
        Nsamples                  % Total numeber of samples
        Nlines                    % Number of processed line
        pfhat                     % Estimated failure probability (first moment)
        variancePfhat             % Variance of the estimator of pfhat
        stdPfhat                  % Standard Deviation of the pfhat estimator
        cov                       % Coefficient of variation
        variance                  % Estimated second moment
    end
    
    methods
        
        %% constructor
        function Xobj=FailureProbability(varargin)
            % FAILUREPROBABILITY This method initializes the FailureProbability
            % object
            %
            % See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@FailureProbability
            %
            % Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
            % Author: Edoardo-Patelli
            % Author: Edoardo Patelli
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
            import opencossan.*
            
            %% Process the inputs
            if nargin==0
                % Create an empty object
                return
            end
            
            %% Validate input arguments
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'xsimulationdata'}
                        Xoutput=varargin{k+1};
                    case {'smethod'}
                        Xobj.Smethod=varargin{k+1};
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sexitflag'}
                        Xobj.SexitFlag=varargin{k+1};
                    case {'sperformancefunction'}
                        Xobj.SperformanceFunction=varargin{k+1};
                    case ('pf')
                        pf=varargin{k+1};
                    case ('variancepf')
                        variancePf=varargin{k+1};
                    case ('secondmoment')
                        secondMoment=varargin{k+1};
                    case ('nsamples')
                        Nsamples=varargin{k+1};
                    case ('nlines')
                        Nlines=varargin{k+1};
                    case {'sweigthsname'}
                        Xobj.SweigthsName=varargin{k+1};
                    case {'csmembers'} % Pass the object by names
                        for imem=1:length(varargin{k+1})
                            Xmem=evalin('base',varargin{k+1}{imem});
                            if isa(Xmem,'opencossan.reliability.ProbabilisticModel')
                                Xobj.SperformanceFunction=Xmem.XperformanceFunction.Soutputname;
                                Xobj.stdDeviationIndicatorFunction=Xmem.XperformanceFunction.StdDeviationIndicatorFunction;
                            elseif isa(Xmem,'opencossan.reliability.PerformanceFunction')
                                Xobj.SperformanceFunction=Xmem.Soutputname;
                                Xobj.stdDeviationIndicatorFunction=Xmem.StdDeviationIndicatorFunction;
                            elseif isa(Xmem,'opencossan.common.outputs.SimulationData')
                                Xoutput=Xmem;
                            else
                                if strcmp(superclasses(Xmem),'opencossan.simulations.Simulations')
                                    Xobj.Smethod=class(Xmem);
                                else
                                    error('openCOSSAN:output:FailureProbability',...
                                        [' The object (' varargin{k+1}{imem} ...
                                        ' must be a Simulations or ProbabilisticModel PerformanceFunction or SimulationData']);
                                end
                                
                            end
                        end
                        
                    case {'cxmembers'} % Pass object by reference
                        for n=1:length(varargin{k+1})
                            switch class(varargin{k+1}{n})
                                case {'opencossan.reliability.ProbabilisticModel','opencossan.reliability.PerformanceFunction'}
                                    Xobj.SperformanceFunction=varargin{k+1}{n}.PerformanceFunctionVariable;
                                    Xobj.stdDeviationIndicatorFunction=varargin{k+1}{n}.StdDeviationIndicatorFunction;
                                case 'opencossan.common.outputs.SimulationData'
                                    Xoutput=varargin{k+1}{n};
                                otherwise
                                    if strcmp(superclasses(Xmem),'opencossan.simulations.Simulations')
                                        Xobj.Smethod=class(Xmem);
                                    else
                                        error('openCOSSAN:output:FailureProbability',...
                                            [' The object type not valid (' mc.Name ...
                                            ')']);
                                    end
                            end
                        end
                    otherwise
                        error('openCOSSAN:output:FailureProbability',...
                            ['Input argument (' varargin{k} ') not allowed'])
                end
            end
            
            %% Perform the simulation if the object Xoutput does not
            %% exist
            if isempty(Xobj.Smethod)
                error('openCOSSAN:output:FailureProbability',...
                    'Simulation method not defined')
            end
            
            if strcmp(Xobj.Smethod,'ImportanceSampling') && isempty(Xobj.SweigthsName)
                error('openCOSSAN:output:FailureProbability',...
                    'The name of the weigths (SweigthsName) must be defined for the ImportanceSampling simulation ')
            end
            
            if exist('Xoutput','var')
                assert(~isempty(Xobj.SperformanceFunction),...
                    'openCOSSAN:output:FailureProbability',...
                    'It is necessary to specify the name of the performance function')
                
                if exist('pf','var') && exist('variancePf','var')
                    if exist ('secondMoment','var')
                        Xobj = addBatch(Xobj,'XsimulationData',Xoutput,'pf',pf,'variancePf',variancePf,'secondMoment',secondMoment);
                    else
                        Xobj = addBatch(Xobj,'XsimulationData',Xoutput,'pf',pf,'variancePf',variancePf);
                    end
                else
                    Xobj = addBatch(Xobj,'XsimulationData',Xoutput);
                end
            else
                
                if ~exist('pf','var')
                    Xobj.Vpf(1)=NaN;
                else
                    Xobj.Vpf(1)=pf;
                end
                
                if ~exist('variancePf','var')
                    Xobj.VvariancePf(1)=NaN;
                else
                    Xobj.VvariancePf(1)=variancePf;
                end
                
                if ~exist('secondMoment','var')
                    Xobj.VsecondMoment(1)=NaN;
                else
                    Xobj.VsecondMoment(1)=secondMoment;
                end
                
                if ~exist('Nsamples','var')
                    Xobj.Vsamples(1)=0;
                else
                    Xobj.Vsamples(1)=Nsamples;
                end
                
                if ~exist('Nlines','var')
                    Xobj.Vlines(1)=0;
                else
                    Xobj.Vlines(1)=Nlines;
                end
                
            end
        end
        
        %% Dependent Properties
        function Nbatches = get.Nbatches(Xobj)
            Nbatches = length(Xobj.Vpf);
        end % Modulus get method
        
        function Nsamples = get.Nsamples(Xobj)
            Nsamples = sum(Xobj.Vsamples);
        end % Modulus get method
        
        function Nlines = get.Nlines(Xobj)
            Nlines = sum(Xobj.Vlines);
        end % Modulus get method
        
        function pfhat = get.pfhat(Xobj)
            if strcmpi(Xobj.Smethod,'LineSampling')
                Vweigths=Xobj.Vlines/Xobj.Nlines;
            else
                Vweigths=Xobj.Vsamples/Xobj.Nsamples;
            end
            pfhat=sum(Vweigths.*Xobj.Vpf);
        end % Modulus get method
        
        function variancePfhat = get.variancePfhat(Xobj)
            % The variance of the estimator of the pfhat
            
            if length(Xobj.Vsamples)==1
                variancePfhat=Xobj.VvariancePf(1);
            else
                %Vweights=Xobj.Vsamples/Xobj.Nsamples; % Weights
                
                %V2 = sum(Vweights.^2); % Correction factor for the Variance
                
                %varMeans = 1/(1-V2)*sum(Vweights.*(Xobj.Vpf - Xobj.pfhat).^2);
                % This is the variance of the estimator of the pfhat and
                % not the second moment.
                %variancePfhat = varMeans/Xobj.Nbatches;
                
                %meanVariances = nansum(Vweights.*Xobj.VsecondMoment);
                S1 = sum(Xobj.Vsamples.*Xobj.Vpf);
                S2 = sum(Xobj.VvariancePf.*Xobj.Vsamples.*(Xobj.Vsamples-1)+ Xobj.Vsamples.*Xobj.Vpf.^2);
                
                %variancePfhat = meanVariances/Xobj.Nbatches;
                variancePfhat=(S2-S1^2/Xobj.Nsamples)/(Xobj.Nsamples-1);
                variancePfhat=variancePfhat/Xobj.Nsamples;
            end
        end
        
        function variance = get.variance(Xobj)
            % The variance of the total group is equal to the mean of
            % the variances of the subgroups plus the variance of the means
            % of the subgroups. This property is known as variance
            % decomposition or the law of total variance.
            % If the batches have unequal sizes, then they must be
            % weighted proportionally to their size in the computations of
            % the means and variances. The formula is also valid with any
            % numbers of batch.
            
            if length(Xobj.Vsamples)==1
                %variance = Xobj.VcovPf.*Xobj.Vpf;
                variance=Xobj.VsecondMoment;
            else
                Vweights=Xobj.Vsamples/Xobj.Nsamples; % Weights
                
                V2 = sum(Vweights.^2); % Correction factor for the Variance
                
                % Retrive the values of the variance for each batch
                %VarianceBatch=(Xobj.VcovPf.*Xobj.Vpf).^2;
                
                meanVariances = nansum(Vweights.*Xobj.VsecondMoment);
                varMeans = 1/(1-V2)*sum(Vweights.*(Xobj.Vpf - Xobj.pfhat).^2);
                
                % This is the variance (i.e. the second moment)
                variance = (meanVariances + varMeans);
            end
        end
        
        function cov = get.cov(Xobj)
            % Compute the Coefficient of Variation
            cov=Xobj.stdPfhat/Xobj.pfhat;
        end
        
        function stdPfhat= get.stdPfhat(Xobj)
            % Compute teh standard deviation of the pf estimator
            stdPfhat=sqrt(Xobj.variancePfhat);
        end
        
        disp(Xobj);                  % Display method
        
        Xobj=addBatch(Xobj,varargin);   % Add batch
        
    end % end method
    
    
end

