classdef Modes
    %MODES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Sdescription              % Description of the object
        MPhi                      % modes
        Vlambda                   % eigenvalues
    end
    
    methods
        
        %% constructor
        function Xmodes=Modes(varargin)
            
            %% Process the inputs
            
            if nargin==0
                return;
            end
            
            opencossan.OpenCossan.validateCossanInputs(varargin{:})
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xmodes.Sdescription=varargin{k+1};
                    case {'mphi'}
                        Xmodes.MPhi = varargin{k+1};
                    case {'vlambda'}
                        Xmodes.Vlambda = varargin{k+1};   
                    otherwise
                        error('openCOSSAN:outputs:Xo_modes',...
                            ['Input argument (' varargin{k} ') not allowed'])
                end
            end 
            
            if isempty(Xmodes.MPhi)
                error('openCOSSAN:outputs:Xo_modes',...
                            'No eigenvectors defined')                
            end
            if isempty(Xmodes.Vlambda)
                error('openCOSSAN:outputs:Xo_modes',...
                            'No eigenvalues defined')                
            end
            if any(Xmodes.Vlambda<0)
                error('openCOSSAN:outputs:Xo_modes',...
                            'The eigenvalues must all be positive')
            end
            if length(Xmodes.Vlambda) ~= size(Xmodes.MPhi,2)
                error('openCOSSAN:outputs:Xo_modes','number of eingenvalues and number of eigenvectors are not the same');
            end


        end % end constructor
        
        Xmodes=display(Xmodes);
        Tout=frf(Xmodes,varargin);
    end
    
end

