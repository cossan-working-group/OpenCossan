classdef Bobyqa < Optimizer
%    BOBYQA (Bounded Optimization by Quadratic Approximation) 
%   seeks the least value of a function of many variables,
%   by applying a trust region method that forms quadratic models
%   by interpolation. There is usually some freedom in the
%   interpolation conditions, which is taken up by minimizing
%   the Frobenius norm of the change to the second derivative
%   of the model, beginning with the zero matrix. The values of
%   the variables are constrained by upper and lower bounds.  
%   Bobyqa is an open source derivative-free optimization algorithm with 
%   constraints by M. J. D. Powell. 
%   This program is free software; you can redistribute it and/or modify it 
%   under the terms of the GNU General Public License as published by the 
%   Free Software Foundation; either version 2 of the License, or 
%   (at your option) any later version. This program is distributed in the 
%   hope that it will be useful, but WITHOUT ANY WARRANTY; without even the 
%   implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%   See the GNU General Public License for more details. 

    %% 1.   Properties of the object
    properties % Public access
        npt         = 0     % Number of interpolation conditions. Its value must be in the interval [N+2,(N+1)(N+2)/2]. Choices that exceed 2*N+1 are not recommended.
        stepSize   = 0.01  % Step size
        rhoEnd      = 1e-6  % Required accuracy for the variables. RHOEND should indicate the accuracy that is required in the final values of the variables
        xtolRel     = 1e-9  % Relative tolerance on the design variables
        minfMax     = 1e-9  % Tolerance on the objective function
        ftolRel     = 1e-8  % Relative tolerance on the objective function
        ftolAbs     = 1e-14 % Absolute tolerance on the objective function
        maxeval     = 1000  % Maximum number of function evaluations
        verbose     = 1     % Verbosity level {0,1,2,3,4,>4}
        
    end
    %% 2.    Methods inherited from the superclass
    methods
        varargout    = apply(Xobj,varargin)  %This method perform the simulation adopting the Xobj
       
        
        function Xobj   = Bobyqa(varargin)
            %% 3.    Constructor
            %BOBYQA    Constructor function for class BOBYQA
            %
            %   BOBYQA      This is the contructor for class BOBYQA; it is intended
            %               for solving an optimization problem using the gradient-free
            %               algorithm BOBYQA. When generating the constructor, it is
            %               possible to select the parameters of the optimization
            %               algorithm. It should be noted that default parameters are
            %               provided for the algorithm; nonetheless,
            %               the user should always check whether or not a particular
            %               set of parameters is appropriate for the problem at hand. A
            %               poor selection on these parameters may prevent finding the
            %               correct solution.
            %
            %   OUTPUT:
            %   - Xobj      : A BOBYQA object
            %
            %   EXAMPLE:
            %
            %   Xobj    = Bobyqa('Sdescription','my optimizer','Nmax',1e3);
            %
            %
            % ==================================================================
            % COSSAN-X - The next generation of the computational stochastic analysis
            % University of Innsbruck, Copyright 1993-2011 IfM
            % ==================================================================
            
            % Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            % Set predefined values
            Xobj.Sdescription   = 'Bobyqa object';
            Xobj.Nmax           = Xobj.maxeval;
            
            % Process input arguments
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case 'sdescription'
                        Xobj.Sdescription=varargin{k+1};
                    case  {'nmax','nmaxmodelevaluations','nmaxiterations'}
                        Xobj.maxeval=varargin{k+1};
                    case  'nevaluationsperbatch'
                        Xobj.NEvaluationsPerBatch=varargin{k+1};
                    case  {'npt','ninterpolationconditions'}
                        Xobj.npt=varargin{k+1};
                    case  {'rhoend','finaltrustregion','finalvaluesaccuracy'}
                        Xobj.rhoEnd=varargin{k+1};
                    case  'stepsize'
                        Xobj.stepSize=varargin{k+1};
                    case  {'xtolrel','tolerance1'}
                        Xobj.xtolRel=varargin{k+1};
                    case  {'minfmax','tolerance2'}
                        Xobj.minfMax=varargin{k+1};
                    case  {'ftolrel','tolerance3'}
                        Xobj.ftolRel=varargin{k+1};
                    case  {'ftolabs','tolerance4'}
                        Xobj.ftolAbs=varargin{k+1};
                    case  {'verbose','verbositylevel'}
                        Xobj.verbose=varargin{k+1};
                    case  'xjobmanager'
                        Xobj.XjobManager=varargin{k+1};
                    otherwise
                        warning('openCOSSAN:Bobyqa',...
                            'PropertyName %s not valid',varargin{k});
                end
            end
            
            %  Check consistency of Optimization object w.r.t. the
            %trust region
            assert(Xobj.ftolRel>=Xobj.ftolAbs,...
                'openCOSSAN:Bobyqa',...
                ['the relative tolerance on the objective function (' num2str(Xobj.ftolRel) ') '...
                'should be smaller than the absolute one (' num2str(Xobj.ftolAbs) ' )']);
            
            
        end
        
    end
    
end
