classdef FailureProbability < opencossan.common.CossanObject
    %FailureProbability This class define teh FailureProbability Output.
    %   The object contains the failure probability (pf) estimated by
    %   simulation methods.
    
    properties (SetAccess = protected)
        Value(1,1) double {mustBeNonnegative, mustBeLessThanOrEqual(Value, 1)};
        SimulationData opencossan.common.outputs.SimulationData;
        Simulation
    end
    
    properties (Dependent)
        ExitFlag;
    end
    
    methods
        
        function obj = FailureProbability(varargin)
            % FAILUREPROBABILITY This method initializes the FailureProbability
            % object
            %
            % See Also http://cossan.cfd.liv.ac.uk/wiki/index.php/@FailureProbability
            
            import opencossan.*
            
            %% Process the inputs
            if nargin == 0
                super_args = {};
            else
                [required, super_args] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["value", "simulationdata", "simulation"], varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Value = required.value;
                obj.SimulationData = required.simulationdata;
                obj.Simulation = required.simulation;
            end
        end
        
        function flag = get.ExitFlag(obh)
            flag = obj.SimulationData.ExitFlag;
        end
%         
%         function Nlines = get.Nlines(Xobj)
%             Nlines = sum(Xobj.Vlines);
%         end % Modulus get method
%         
%         function pfhat = get.pfhat(Xobj)
%             if strcmpi(Xobj.Smethod,'LineSampling')
%                 Vweigths=Xobj.Vlines/Xobj.Nlines;
%             else
%                 Vweigths=Xobj.Vsamples/Xobj.Nsamples;
%             end
%             pfhat=sum(Vweigths.*Xobj.Vpf);
%         end % Modulus get method
%         
%         function variancePfhat = get.variancePfhat(Xobj)
%             % The variance of the estimator of the pfhat
%             
%             if length(Xobj.Vsamples)==1
%                 variancePfhat=Xobj.VvariancePf(1);
%             else
%                 %Vweights=Xobj.Vsamples/Xobj.Nsamples; % Weights
%                 
%                 %V2 = sum(Vweights.^2); % Correction factor for the Variance
%                 
%                 %varMeans = 1/(1-V2)*sum(Vweights.*(Xobj.Vpf - Xobj.pfhat).^2);
%                 % This is the variance of the estimator of the pfhat and
%                 % not the second moment.
%                 %variancePfhat = varMeans/Xobj.Nbatches;
%                 
%                 %meanVariances = nansum(Vweights.*Xobj.VsecondMoment);
%                 S1 = sum(Xobj.Vsamples.*Xobj.Vpf);
%                 S2 = sum(Xobj.VvariancePf.*Xobj.Vsamples.*(Xobj.Vsamples-1)+ Xobj.Vsamples.*Xobj.Vpf.^2);
%                 
%                 %variancePfhat = meanVariances/Xobj.Nbatches;
%                 variancePfhat=(S2-S1^2/Xobj.Nsamples)/(Xobj.Nsamples-1);
%                 variancePfhat=variancePfhat/Xobj.Nsamples;
%             end
%         end
%         
%         function variance = get.variance(Xobj)
%             % The variance of the total group is equal to the mean of
%             % the variances of the subgroups plus the variance of the means
%             % of the subgroups. This property is known as variance
%             % decomposition or the law of total variance.
%             % If the batches have unequal sizes, then they must be
%             % weighted proportionally to their size in the computations of
%             % the means and variances. The formula is also valid with any
%             % numbers of batch.
%             
%             if length(Xobj.Vsamples)==1
%                 %variance = Xobj.VcovPf.*Xobj.Vpf;
%                 variance=Xobj.VsecondMoment;
%             else
%                 Vweights=Xobj.Vsamples/Xobj.Nsamples; % Weights
%                 
%                 V2 = sum(Vweights.^2); % Correction factor for the Variance
%                 
%                 % Retrive the values of the variance for each batch
%                 %VarianceBatch=(Xobj.VcovPf.*Xobj.Vpf).^2;
%                 
%                 meanVariances = nansum(Vweights.*Xobj.VsecondMoment);
%                 varMeans = 1/(1-V2)*sum(Vweights.*(Xobj.Vpf - Xobj.pfhat).^2);
%                 
%                 % This is the variance (i.e. the second moment)
%                 variance = (meanVariances + varMeans);
%             end
%         end
%         
%         function cov = get.cov(Xobj)
%             % Compute the Coefficient of Variation
%             cov=Xobj.stdPfhat/Xobj.pfhat;
%         end
%         
%         function stdPfhat= get.stdPfhat(Xobj)
%             % Compute teh standard deviation of the pf estimator
%             stdPfhat=sqrt(Xobj.variancePfhat);
%         end
        
    end
end

