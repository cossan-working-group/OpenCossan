classdef MTXExtractor < Extractor
    
    methods
        function Xobj  = MTXExtractor(varargin)
            
            %% 1. Processing Inputs
            
            % Process all the optional arguments and assign them the corresponding
            % default value if not passed as argument

            %% Set options
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'sfile'}
                        Xobj.Sfile=varargin{k+1};
                    case {'srelativepath'}
                        Xobj.Srelativepath=varargin{k+1};
                    case {'sworkingdirectory'}
                        Xobj.Sworkingdirectory = varargin{k + 1};
                    case {'soutputname'}
                        Xobj.Soutputname=varargin{k+1};
                    otherwise
                        error('openCOSSAN:MTXExtractor','Field name not allowed');
                end
            end
            if isempty(Xobj.Soutputname)
                error('openCOSSAN:MTXExtractor','Soutputname not defined');
            end
            if isempty(Xobj.Sfile)
                error('openCOSSAN:MTXExtractor','No file name specified');
            end
            
        end %end constructor
        
        [Tout LsuccessfullExtract Vnodes Vdofs]= extract(Xe,varargin)
        
    end
end