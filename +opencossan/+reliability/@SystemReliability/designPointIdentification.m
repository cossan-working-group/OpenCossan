function Xsys = designPointIdentification(Xsys,varargin)
% designPointIdentification search the so-called "design point" for each
% limit state function defined in the SystemReliability object.
% 
%   Input arguments must be passed as pairs 'PropertyName' 'PropertyValue' 
%
%   Valid PropertyName:
%    Lverbose          be verbose
%    minitialpoint     Array of Initial guess for the design point (in standard normal space);
%    Optimizator       Optimizator object
%
%   The method returns a SystemReliability Object
%
%   Usage: 
%   Xsys = Xsys.designPointIdentification('PropertyName',PropertyValue)
%
%   Example
%   Xsys = Xsys.designPointIdentification('Lvervose',true,'Xoptimizator',Xcobyla)
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

% This method requires as argoments the seme inputs required by the method
% designPointIdentification@ProbabilisticModel

%% Set default values
for imem=1:length(Xsys.XperformanceFunctions)
    
    OpenCossan.cossanDisp(['Identify Design Point for the Performance Function ' Xsys.Cnames{imem}],2)

    % Create a probabilistic model to compute the design point for each
    % performance function
    
    Xprobmodel=ProbabilisticModel ...
        ('Xmodel',Xsys.Xmodel,'XperformanceFunction',Xsys.XperformanceFunctions(imem));
    
    Xsys.XdesignPoints{imem}= Xprobmodel.designPointIdentification(varargin{:});

end

OpenCossan.cossanDisp('Design point of each Performance Function identified',2)

