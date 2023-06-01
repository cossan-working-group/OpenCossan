classdef InferenceOutput < opencossan.common.CossanObject
    % INFERENCEOUTPUT construct the object InferenceOutput to collect the 
    % result of the inference analysis.
    
    
    properties %Public access
        MarginalProbability  table  
        JointProbability     table
        Evidence             table
        Info                 table          
    end
   
   
    
    methods
        %% constructor
        function obj = InferenceOutput(varargin)
            %BAYESIANNETWORK Constructor for BayesianNetwork object.
            
            if nargin == 0
                % Create empty object
                return
            else
                % Process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.bayesiannetworks.InferenceOutput';
                
                % Class properties
                p.addParameter('MarginalProbability',obj.MarginalProbability);
                p.addParameter('Evidence',obj.Evidence);
                p.addParameter('Info',obj.Evidence);
                p.addParameter('JointProbability',obj.Evidence);
 
                p.parse(varargin{:});
                
                % Assign input to objects properties
                obj.MarginalProbability = p.Results.MarginalProbability;
                obj.Evidence            = p.Results.Evidence;
                obj.Info                = p.Results.Info;
                obj.JointProbability    = p.Results.JointProbability;       
            end
        end
        
        
end %of constructor


end




