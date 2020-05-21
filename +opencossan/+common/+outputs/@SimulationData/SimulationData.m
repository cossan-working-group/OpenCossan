classdef SimulationData < opencossan.common.CossanObject
    %SIMULATIONDATA Class definition of the SimulationData object
    %
    % See Also: Also: http://cossan.co.uk/wiki/index.php/@SimulationData
    
    properties
        ExitFlag(1,1) string = "";
        Samples(:,:) table = table();   % Store data in a table format
    end
    
    properties (Dependent = true)
        Names           % Names of the variables present in the object
        DataSeriesName % Extract the names of dataseries
        NumberOfSamples         % Number of samples
        NumberOfBatches
        NumberOfMissingData    % number of missing data
    end
    
    properties (SetAccess=private)
        LisDataseries   % flag for dataseries
    end
    
    methods
        % SIMULATIONDATA This method constructs a SimulationData object. The
        % object is used to store the results of the simulation.
        %
        % See Also: http://cossan.co.uk/wiki/index.php/@SimulationData
        %
        % Author: Edoardo Patelli
        % Institute for Risk and Uncertainty, University of Liverpool, UK
        % email address: openengine@cossan.co.uk
        % Website: http://www.cossan.co.uk
        
        function obj = SimulationData(varargin)
            
            if nargin == 0
                super_args = {};
            else
               [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                   ["Samples", "ExitFlag"], {table(), ""}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Samples = optional.samples;
                obj.ExitFlag = optional.exitflag;
            end            
        end
        
        Xobj=plus(Xobj,XsimOut2);    % add SimulationData
        
        Xobj=minus(Xobj,XsimOut2);   % subtract SimulationData
        
        VOut=compute(varargin);       % performe operation on SimulationData
        
        Xobj=addData(Xobj,varargin);  % Add variable to SimulationData
        
        Xobj=merge(Xobj,XsimOut2);    % Merge 2 SimulationData Objects
        
        Xobj=removeData(Xobj,varargin); % Remove data from the SimulatioData Objects
        
        [Mvalues, varargout]=getValues(Xobj,varargin);  % Retrieve values of a specific variable
        
        Cdataseries=getDataseries(Xobj,varargin);  % Retrieve Dataseries of a specific variable
        
        [Mstats, Mdata]=getStatistics(Xobj,varargin); % Compute the statistic of the Data
        
        h=plotData(Xobj,varargin);  % plot variables
        
        function n = get.NumberOfSamples(obj)
            n = height(obj.Samples) / obj.NumberOfBatches;
        end
        
        function n = get.NumberOfBatches(obj)
            if ~contains(obj.Samples.Properties.VariableNames, 'Batch')
                n = 1;
            else
                n = numel(unique(obj.Samples.Batch));
            end
        end
        
        function n = get.NumberOfMissingData(obj)
            n =sum(ismissing(obj.Samples), 'all');
        end 
    end
end

