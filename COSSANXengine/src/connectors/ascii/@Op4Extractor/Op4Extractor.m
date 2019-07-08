classdef Op4Extractor < Extractor
    
    methods
        function Xobj  = Op4Extractor(varargin)
            
            %% Processing Inputs
            
            % Process all the optional arguments and assign them the corresponding
            % default value if not passed as argument
            
            OpenCossan.validateCossanInputs(varargin{:})
            
            %% Set options
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sfile'}
                        Xobj.Sfile=varargin{k+1};
                    case {'sworkingdirectory'}
                        Xobj.Sworkingdirectory=varargin{k+1};
                    case {'srelativepath'}
                        Xobj.Srelativepath=varargin{k+1};
                    case {'soutputname'}
                        Xobj.Soutputname=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Op4extractor','Field name %s not allowed',varargin{k});
                end
            end
            if isempty(Xobj.Sfile)
                error('openCOSSAN:OP4Extractor','No file name specified');
            end
            if isempty(Xobj.Soutputname)
                error('openCOSSAN:OP4Extractor','Soutputname not defined');
            end
            
        end %end constructor
        [Tout,LsuccessfullExtract] = extract(Xe,varargin)
    end
end
