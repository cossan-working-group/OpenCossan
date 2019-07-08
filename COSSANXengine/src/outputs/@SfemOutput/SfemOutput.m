classdef SfemOutput 
    %SFEMOUTPUT Summary of this class goes here
    %   Detailed explanation goes here
      %% 1.   Properties of the object
    properties% Public access
        Sdescription   = 'SFEM Output object' % description of the object
        XSfemObject                           % SFEM object which is used for the analysis
        Sresponse                             % Type of the response, i.e. 'specific','max','all'
        MresponseDOFs                         % DOFs for which the response statistics are required
        MmodelDOFs                            % Matrix storing the NODE&DOF info of the model (column 1: NodeIDs, columns 2: DOFs)
        Xpc                                   % P-C object (only available for P-C)
        Vmean                                 % Vector containing the mean values of ALL responses
        Vstd                                  % Vector containing the std values of ALL responses
        Vcov                                  % Vector containing the CoV values of ALL responses
        Vresponsemean                         % Vector containing the mean values of responses of QUANTITIES OF INTEREST
        Vresponsestd                          % Vector containing the std values of responses of QUANTITIES OF INTEREST
        Vresponsecov                          % Vector containing the cov values of responses of QUANTITIES OF INTEREST
        Vresponses                            % Vector containing the samples of responses of QUANTITIES OF INTEREST
        Mresponses                            % Matrix containing the samples of responses (only available for Neumann)
        maxresponseDOF                        % The corresponding entry no for max abs value in the displacement vector
        Nmode                                 % No of the eigenfreuqency
    end

    %% 2.    Methods of the class
    methods
        Xo = get(Xobj,varargin)         %This method allows retrieving properties of the Xobj object
        Xo = getResponse(Xobj,varargin)
        display(Xobj)                   %This method shows the summary of the Xobj
        
        
        
        function Xobj  = SfemOutput(varargin)
            %% Constructor of SFEMOUTPUT
            %
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@SfemOutput
            %
            % Copyright 1983-2011 COSSAN Working Group, University of Innsbruck, Austria
            % Author: Edoardo Patelli
            %
            
            %%  Argument Check
            OpenCossan.validateCossanInputs(varargin{:})
            
            if nargin==0
                return
            end
            
            %% Processing Inputs
            % Process all the optional arguments and assign them the corresponding
            % default value if not passed as argument
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case{'sdescription'}
                        Xobj.Sdescription = varargin{k+1};
                    case{'xsfemobject'}
                        Xobj.XSfemObject = varargin{k+1};
                    case{'sresponse'}
                        Xobj.Sresponse = varargin{k+1};
                    case{'mresponsedofs'}
                        Xobj.MresponseDOFs = varargin{k+1};
                    case{'mmodeldofs'}
                        % to pass the input check the input was cast to a
                        % double. Casting it back to an integer
                        Xobj.MmodelDOFs = int32(varargin{k+1});
                    case{'xpc'}
                        Xobj.Xpc = varargin{k+1};
                    case{'vmean'}
                        Xobj.Vmean = varargin{k+1};
                    case{'vstd'}
                        Xobj.Vstd = varargin{k+1};
                    case{'vcov'}
                        Xobj.Vcov = varargin{k+1};
                    case{'vresponsemean'}
                        Xobj.Vresponsemean  = varargin{k+1};
                    case{'vresponsestd'}
                        Xobj.Vresponsestd = varargin{k+1};
                    case{'vresponsecov'}
                        Xobj.Vresponsecov = varargin{k+1};
                    case{'vresponses'}
                        Xobj.Vresponses = varargin{k+1};
                    case{'mresponses'}
                        Xobj.Mresponses = varargin{k+1};
                    case{'maxresponsedof'}
                        Xobj.maxresponseDOF = varargin{k+1};
                    case{'nmode'}
                        Xobj.Nmode = varargin{k+1};
                    otherwise
                        error('openCOSSAN:SfemOutput:SfemOutput', ...
                            'Property Name %s not valid',varargin{k});
                end
            end
                           
        end     %of constructor
        
    end     %of methods
    
end     %of classdef

