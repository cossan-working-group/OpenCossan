classdef CrackGrowth < Mio
    %CrackGrowth The class CovarianceFunction defines the crack growth
    %equation (i.e. Paris-Erdogan equation or any similar expression)
    %   This class is a generalization of the Mio class
                
    methods
            function Xobj= CrackGrowth(varargin)
                       
            %% Set parameters defined by the user
            for k=1:2:length(varargin),
                switch lower(varargin{k}),
                    %2.1.   Description of the object
                    case 'sdescription'
                        if ischar(varargin{k+1})
                            Xobj.Sdescription   = varargin{k+1};
                        else
                            error('openCOSSAN:Function:Function',...
                                'The the field associated with Sdescription must contain a string');
                        end
                    case 'spath'
                        Xobj.Spath   = varargin{k+1};
                    case 'sfile'
                        Xobj.Sfile   = varargin{k+1};
                    case 'lfunction'
                        Xobj.Lfunction   = varargin{k+1};
                    case 'liostructure'
                        Xobj.Liostructure   = varargin{k+1};  
                    case 'liomatrix'
                        Xobj.Liomatrix   = varargin{k+1};
                    case 'sadditionalpath'
                        Xobj.Sadditionalpath   = varargin{k+1};  
                    case 'coutputnames'
                        Xobj.Coutputnames   = varargin{k+1};   
                     case 'soutputname'
                        Xobj.Coutputnames   = varargin(k+1);   
                    case 'cinputnames'
                        Xobj.Cinputnames   = varargin{k+1};  
                    case 'cobjectsnames'
                        Xobj.CobjectsNames = varargin{k+1}; 
                    case 'cxobjects'
                        Xobj.Cxobjects = varargin{k+1}; 
                    case 'lverbose'
                        Xobj.Lverbose   = varargin{k+1};          
                    case 'lkeepsimfiles'
                        Xobj.Lkeepsimfiles   = varargin{k+1};            
                    case {'sscript'}
                        if ischar(varargin{k+1}),
                           Xobj.Sscript   = varargin{k+1}; 
                        else
                            error('openCOSSAN:Input:CovarianceFunction',...
                                'The the field associated with Sexpression must contain a string');
                        end
                        %2.4.   Objects to be used at the time of evaluation
                    case 'xmio'
                        % Generalize the Mio object
                        Cfield=fieldnames(varargin{k+1});
                        for n=1:length(Cfield)
                        Xobj.(Cfield{n})=varargin{k+1}.(Cfield{n});
                        end
                    otherwise
                        warning('openCOSSAN:Input:CovarianceFunction',...
                            ['Field name (' varargin{k} ') has been ignored']);
                end
            end
            
            %% Check inputs
            
           Xobj=validateConstructor(Xobj);
                        

            

        end % constructor
        
        dadn = evaluate(Xobj,varargin) % Evaluate the covariance function
    end
            
end

