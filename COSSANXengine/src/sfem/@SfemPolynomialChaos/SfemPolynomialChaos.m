%SFEMPOLYNOMIALCHAOS  Subclass of Sfem for P-C Method
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$

classdef SfemPolynomialChaos < Sfem
    
   properties % Public access
      Lautoconvergence=true;           % Algorithm to determine the convergence tolerance automatically
      Vdroptolerancerange=[1e-1,1e-6]; % Range of Drop Tolerance
      Lautofactorization=true;         % Algorithm to determine the Drop tolerance automatically
      droptolerance=1e-4;              % Drop Tolerance value for the Incomplete Cholesky Factorization
      convergencetolerance=1e-2;       % Convergence Tolerance value for the Iterative PCG Solver
      Nmaxiterations=500;              % Max No of iterations for the PCG solver
      convergenceparameter=5;          % Convergence parameter for the response statistics
      preconditionertime=[];           % CPU time spent to prepare the preconditioner
      solvertime=[];                   % CPU time spent to solve the system for P-C coeffs
      Sgridtype='Clenshaw-Curtis';     % The grid type to be applied - valid only for Collocation P-C  
      Sbasis='Hermite';                % Polynomials to construct the basis
      Vrange=[-1,1];                   % The range where the integral is to be calculated - valid only for Collocation P-C 
      Ntotalsimulations=0;             % Keeps track of the total no of simulations performed - valid only for Collocation P-C 
      Noutputs=0;                      % No of responses for which the P-C coeffs are to be calculated  - valid only for Collocation P-C 
      Nmaxdepth=8;                     % Max depth to be used with the grid - valid only for Collocation P-C 
      relativetolerance=0.05;          % Relative tolerance to decide until which level the grid should be calculated - valid only for Collocation P-C 
   end  
    
    methods % Methods inheritated from the superclass 
       display(Xobj);
       
       CFEresult = runFEsolver(Xobj,Mxi,Xpc)
       %constructor 
       function Xobj= SfemPolynomialChaos(varargin)
           % SFEMPOLYNOMIALCHAOS Constructor for the SfemPolynomialChaos object
           %
           % See also:  http://cossan.cfd.liv.ac.uk/wiki/index.php/@SfemPolynomialChaos
           %
           % $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
           
            % validate Input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            for k=1:2:length(varargin)
                switch lower(varargin{k})    
                    case {'xmodel'}
                        Xobj.Xmodel=varargin{k+1}; 
                    case {'cxmodel'}
                        Xobj.Xmodel=varargin{k+1}{1}; 
                    case {'sanalysis'}
                        Xobj.Sanalysis=varargin{k+1}; 
                    case {'sbasis'}
                        Xobj.Sbasis=varargin{k+1}; 
                    case {'simplementation'}
                        Xobj.Simplementation=varargin{k+1}; 
                    case {'cstepdefinition'}
                        Xobj.CstepDefinition=varargin{k+1};
                    case {'mconstraineddofs'}
                        Xobj.MconstrainedDOFs=varargin{k+1};
                    case {'smethod'}
                        Xobj.Smethod=varargin{k+1};  
                    case {'cyoungsmodulusrvs'}
                        Xobj.CyoungsModulusRVs=varargin{k+1};  
                    case {'cdensityrvs'}
                        Xobj.CdensityRVs=varargin{k+1}; 
                    case {'cthicknessrvs'}
                        Xobj.CthicknessRVs=varargin{k+1}; 
                    case {'cforcervs'}
                        Xobj.CforceRVs=varargin{k+1};
                    case {'ccrosssectionrvs'}
                        Xobj.CcrossSectionRVs=varargin{k+1};
                    case {'lcleanfiles'}
                        Xobj.Lcleanfiles=varargin{k+1};   
                    case {'mmasterdofs'}
                        Xobj.MmasterDOFs=varargin{k+1}; 
                    case {'norder'}
                        Xobj.Norder=varargin{k+1}; 
                    case {'nmaxiterations'}
                        Xobj.Nmaxiterations=varargin{k+1}; 
                    case {'ninputapproximationorder'}
                        Xobj.NinputApproximationOrder=varargin{k+1};
                    case {'vdroptolerancerange'}
                        Xobj.Vdroptolerancerange=varargin{k+1};
                    case {'droptolerance'}
                        Xobj.droptolerance=varargin{k+1};
                    case {'convergencetolerance'}
                        Xobj.convergencetolerance=varargin{k+1};
                    case {'convergenceparameter'}
                        Xobj.convergenceparameter=varargin{k+1};
                    case {'nmaxdepth'}
                        Xobj.Nmaxdepth=varargin{k+1};
                    case {'vrange'}
                        Xobj.Vrange=varargin{k+1};
                    case {'sgridtype'}
                        Xobj.Sgridtype=varargin{k+1};
                    case {'relativetolerance'}
                        Xobj.relativetolerance=varargin{k+1};
                    case {'lautoconvergence'}
                        Xobj.Lautoconvergence=varargin{k+1};
                    case {'lautofactorization'}
                        Xobj.Lautofactorization=varargin{k+1};  
                    case {'lfesolverexecuted'}
                        Xobj.Lfesolverexecuted=varargin{k+1};  
                    case {'ltransfercompleted'}
                        Xobj.Ltransfercompleted=varargin{k+1};  
                    case {'lstoreinput'}
                        Xobj.Lstoreinput=varargin{k+1};  
                    otherwise
                        error('openCOSSAN:SfemPolynomialChaos', ...
                            'Field name %s not allowed',varargin{k});
                end
            end
            % Check input
            Xobj=checkInput(Xobj);
       end % constructor
    end
end
