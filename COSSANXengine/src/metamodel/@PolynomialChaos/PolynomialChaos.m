classdef PolynomialChaos < MetaModel
    
   properties % Public access
      Smethod                       % Method to calculate the PC coefficients 
      Sbasis = 'Hermite'            % Polynomials used to construct the basis
      Norder = 2                    % Order of the Expansion 
      Npccoefficients               % No of the PC coefficients
      Ccputimes                     % Store the CPU times 
      Xsfem                         % Field to store the SFEM object
      Mpreconditioner               % Preconditioner matrix obtained with Incomplete Cholesky Factorization
      Vfpc                          % Right hand side of the system of eqns for the P-C system
      Vupc                          % Initial guess for the P-C coefficients (used only within Galerkin P-C)
      Mpccoefficients               % Matrix containing the P-C coefficients (m x n, m: Ndofs, n: Npccoefficients)
   end  
    
    methods % Methods inheritated from the superclass 
       display(Xobj);
       
       CFEresult = runFEsolver(Xpc,Mxi)
       
       %constructor 
       function Xobj= PolynomialChaos(varargin)
           %POLYNOMIALCHAOS
           %
           % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@PolynomialChaos
           %
           % ==================================================================
           % COSSAN-X - The next generation of the computational stochastic analysis
           % University of Innsbruck, Copyright 1993-2011
           % ==================================================================
            % validate Input arguments
            OpenCossan.validateCossanInputs(varargin{:})
            for k=1:2:length(varargin)
                switch lower(varargin{k})    
                    case {'xsfem'}
                        Xobj.Xsfem=varargin{k+1};
                    case {'norder'}
                        Xobj.Norder=varargin{k+1};
                    case {'sbasis'}
                        Xobj.Sbasis=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Metamodel:PolynomialChaos', ...
                            'Field name %s not allowed',varargin{k}); 
                end
            end
            if ~isempty(Xobj.Xsfem)
                % method to calculate coeffs are extracted from XsfemPC object
                Xobj.Smethod = Xobj.Xsfem.Smethod;
            end
        end % constructor
    end 
    
    methods (Static)
         [varargout] = calculateIntegral(varargin)
    end
end

