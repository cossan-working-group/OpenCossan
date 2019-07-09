classdef KarhunenLoeve < opencossan.common.inputs.stochasticprocess.StochasticProcess
    %KarhunenLoeve This class defines a stochastic process based on
    %Karhunen-Loeve expansion
    %
    % See also OPENCOSSAN.COMMON.INPUT.STOCHASTICPROCESS
    
    properties
        EigenVectors double             % Kept eigenvectors of covariance matrix (for KL-decomposition)
        EigenValues  double      % Kept eigenvalues of covariance matrix (for KL-decomposition)
    end
    
    properties (Constant)
        SupportedDistributions = {'normal'}
    end
    
    methods
        function Xobj = KarhunenLoeve(varargin)
            %KarhunenLoeve This class defines a stochastic process based on
            %Karhunen-Loeve expansion
            
            if nargin == 0
                return                 % Create empty object
            else
                
                % Process inputs via inputParser
                p = inputParser;
                p.FunctionName = 'opencossan.common.inputs.stochasticprocess.KarhunenLoeve';
                
                % Use default values
                p.addParameter('Description',Xobj.Description);
                p.addParameter('Distribution',Xobj.Distribution);
                p.addParameter('Mean',Xobj.Mean);
                p.addParameter('CoordinateNames',Xobj.CoordinateNames);
                p.addParameter('CoordinateUnits',Xobj.CoordinateUnits);
                p.addParameter('Coordinates',Xobj.Coordinates);
                p.addParameter('CovarianceFunction',Xobj.CovarianceFunction);
                p.addParameter('CovarianceMatrix',Xobj.CovarianceMatrix);
                p.addParameter('IsHomogeneous',Xobj.IsHomogeneous);
                p.addParameter('EigenVectors',Xobj.EigenVectors);
                p.addParameter('EigenValues',Xobj.EigenValues);
                
                % Parse inputs
                p.parse(varargin{:});
                
                % Assign input to objects properties
                Xobj.Description = p.Results.Description;
                 
                % Check distribution
                assert(ismember(p.Results.Distribution,Xobj.SupportedDistributions),...
                    'OpenCossan:KarhunenLoeve:unsupportedDistribution', ...
                    'Unsupported distribution! \nValid distributions are: %s', ...
                    sprintf('"%s" ',Xobj.SupportedDistributions{:}))
                
                Xobj.Distribution = p.Results.Distribution;
                Xobj.Mean = p.Results.Mean;
                Xobj.CoordinateNames = p.Results.CoordinateNames;
                Xobj.CoordinateUnits = p.Results.CoordinateUnits;
                Xobj.Coordinates = p.Results.Coordinates;
                Xobj.CovarianceFunction = p.Results.CovarianceFunction;                
                Xobj.CovarianceMatrix = p.Results.CovarianceMatrix;
                
                Xobj.IsHomogeneous = p.Results.IsHomogeneous;
                Xobj.EigenVectors = p.Results.EigenVectors;
                Xobj.EigenValues = p.Results.EigenValues;
                              

                                
                % Check if the CovarianceMatrix is lower triangular
                if istril(p.Results.CovarianceMatrix) || istriu(p.Results.CovarianceMatrix)
                    % assemble full covariance
                    Xobj.CovarianceMatrix=p.Results.CovarianceMatrix+...
                        p.Results.CovarianceMatrix'-diag(diag(p.Results.CovarianceMatrix));
                end
            end            
            
            % check for mandatory inputs
            assert(~isempty(Xobj.Coordinates),...
                'OpenCossan:KarhunenLoeve:noCoordinates',...
                'It is necessary to specify the matrix of the coordinates (Coordinates)')
            
            % input argument checks
            if length(Xobj.Mean)==1
                Xobj.Mean=Xobj.Mean*ones(1,size(Xobj.Coordinates,2));
            end
            
            % assign default coordinate names
            if isempty(Xobj.CoordinateNames)
                Xobj.CoordinateNames = strings(1,Xobj.Ndimensions);
                for idim=1:Xobj.Ndimensions
                    Xobj.CoordinateNames{1} = strcat('Coordinate_',num2str(idim));
                end
            end
            
            % assign default coordinate units
            if isempty(Xobj.CoordinateUnits)
                Xobj.CoordinateUnits = strings(1,Xobj.Ndimensions);
            end
            
            assert(length(Xobj.Mean)== size(Xobj.Coordinates,2), ...
                'OpenCossan:KarhunenLoeve:WrongMeanCoordinate',...
                'Length of mean vector (%d) and no. of columns of Coordinates (%d) are not the same',...
                length(Xobj.Mean), size(Xobj.Coordinates,2));
            
            assert(length(Xobj.CoordinateNames)==size(Xobj.Coordinates,1),...
                'OpenCossan:KarhunenLoeve:WrongDimensionCoordinates',...
                'The dimension of the coordinates (%d) names and the number of rows Coordinates (%d) are not the same',...
                length(Xobj.CoordinateNames), size(Xobj.Coordinates,1))
            
            if ~isempty(Xobj.CovarianceMatrix)
                assert(size(Xobj.CovarianceMatrix,1)==size(Xobj.Coordinates,2), ...
                    'OpenCossan:KarhunenLoeve:WrongCovarianceMatrix',...
                    'Size of covariance matrix not correct');
            end
            
        end      % end constructor
        
        Xobj=computeTerms(Xobj,varargin)
    end
    
    methods (Static)
        b=matvecprodHomogeneous(x,Vx,Xfun);
        b=matvecprodNonhomogeneous(x,Vx,Xfun);
    end
end

