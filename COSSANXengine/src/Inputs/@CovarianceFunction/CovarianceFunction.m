classdef CovarianceFunction < Mio
    %COVARIANCEFUNCTION The class CovarianceFunction defines the covariance
    %function for a stochastic process
    %   This class is a generalization of the Mio class
                
    methods
            function Xobj= CovarianceFunction(varargin)
                
            % Use the constructor of the MIO
            
            Xobj = Xobj@Mio(varargin{:});
            if nargin==0
                return;
            end
                        
            %% Check inputs
           
            % The objective function must have a single output
            if length(Xobj.Coutputnames)~=1 
               error('openCOSSAN:CovarianceFunction',...
                     'A single output (Coutputnames) must be defined');
            end
            if length(Xobj.Cinputnames)~=2 
               error('openCOSSAN:CovarianceFunction',...
                     'Two input names (Cinputnames) must be defined');
            end            

        end % constructor
        Vcov = evaluate(Xobj,varargin) % Evaluate the covariance function
    end
            
end

