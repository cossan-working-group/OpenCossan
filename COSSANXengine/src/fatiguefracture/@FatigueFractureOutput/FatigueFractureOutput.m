classdef FatigueFractureOutput
    %SIMULATIONOUTPUT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        Sdescription    % Description of the object
    end

    properties (Dependent = true, SetAccess = private)
        Nsamples        % Number of samples
    end
    
    properties (SetAccess=protected)
        Vindex
        Mdata       % Matrix containing the values of the variables
        Vlength     % Array containing the length of the indexes
        XdataSeries
        Cnames
    end
%     
%     properties (Access=private)
%             Tvalues=struct; % Structure containing the values of the variables
%     end
    methods
        %% constructor
        function XfatFracOut=FatigueFractureOutput(varargin)
            
%             validateCossanInputs(varargin{:});
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        XfatFracOut.Sdescription=varargin{k+1};

                    case {'cvariablenames','cnames'}
                        XfatFracOut.Cnames=varargin{k+1};
                        if size(XfatFracOut.Cnames,1)>1
                            XfatFracOut.Cnames=XfatFracOut.Cnames';
                        end
                    case {'xdataseries','dataseries'}
                        XfatFracOut.XdataSeries = varargin{k+1};  
                    otherwise
                        error('openCOSSAN:SimulationOutput', ...
                            ['PropertyName (' varargin{k} ' ) is not allowed']);
                end
            end
            
           
            
            
        end % end constructor
        
        XfatFracOut=addSimulation(XfatFracOut,varargin);  % Add variable to SimulationOutput
        
        XfatFracOut=display(XfatFracOut);           % Show report on matlab console
        

        
        VOut=compute(varargin);             % performe operation on SimulationOutput
        
        [Mvalues varargout]=getValues(XfatFracOut,varargin);  % Retrieve values of a specific variable
        
        XfatFracOut=computeStruct(XfatFracOut);
        
        
    end % End method
    
end
