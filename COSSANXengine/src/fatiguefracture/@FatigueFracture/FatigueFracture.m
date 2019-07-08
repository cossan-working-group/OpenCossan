classdef FatigueFracture
    %FATIGUEFRACTURE constructor of the FatigueFracture class
    %
    %   TODO: mandatory arguments, optinnal arguments
    
    
    properties
        Xsolver       % Contains an evaluator
        Xfracture             %fracture tougness of the material
        Ccrack          %cell array containing the cracks
        XcrackGrowth    %crack growth equation (cossan object)
        solver = 'ode113'
        Coutputnames = {'FatigueLife'}
        Cinputnames
        CXsolver
    end
    
    methods
        function Xobj=FatigueFracture(varargin)

            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'fracture','xfracture'}
                        Xobj.Xfracture=varargin{k+1};
                    case {'ccrack','ccrackname','ccracknames'}
                        Xobj.Ccrack=varargin{k+1};
                    case {'solver','xsolver','evaluator','xevaluator','xmetamodel'}
                        Xobj.Xsolver=varargin{k+1};
                    case {'cxevaluator','cxsolver','cxmetamodel'}
                        Xobj.CXsolver=varargin{k+1};
                    case {'cinputnames','cinputname'}
                        Xobj.Cinputnames=varargin{k+1};
                     case {'coutputnames','coutputname'}
                         if length(varargin{k+1})>1
                             error('openCOSSAN:FatigueFracture:FatigueFracture',...
                                 'The FatigueFracture objects must have only one output');
                         end
                         Xobj.Coutputnames=varargin{k+1};
                    case {'xcrackgrowth'}
                            Xobj.XcrackGrowth=varargin{k+1};
                    case {'sdifferentialequationsolver','sodesolver'}
                        switch lower(varargin{k+1})
                            case {'adam','adam-bashforth-moulton','abm'}
                                Xobj.solver = 'ode113';
                            case {'runge-kutta','rk'}
                                Xobj.solver = 'ode45';
                            otherwise
                                error('openCOSSAN:FatigueFracture:FatigueFracture',...
                                    'Value of field Solver not allowed');
                        end
                        
                    otherwise
                        warning('openCOSSAN:FatigueFracture:FatigueFracture',...
                            ['Field name ' varargin{k} ' not allowed']);
                end
            end
                        
            if isempty(Xobj.Xsolver) && isempty(Xobj.CXsolver)
                error('openCOSSAN:FatigueFracture',...
                    'The FatigueFracture object must contain an Evaluator');
            end
            if isempty(Xobj.Xfracture)
                error('openCOSSAN:FatigueFracture',...
                    'The FatigueFracture object must contain an Fracture object');
            end
            if isempty(Xobj.XcrackGrowth)
                error('openCOSSAN:FatigueFracture',...
                    'The FatigueFracture object must contain an CrackGrowth object');
            end   
            if isempty(Xobj.Ccrack)
                error('openCOSSAN:FatigueFracture',...
                    'The field Ccrack must be specified');
            end      
            
            % check for the compatibility between the inputs and the
            % elements required by the scripts
            if ~isempty(Xobj.Xsolver)
                     CsolverOutName = Xobj.Xsolver.Coutputnames;
            else
                
                CsolverOutName = {};
                for i=1:length(Xobj.CXsolver)
                    if isa(Xobj.CXsolver{i},'MetaModel')
                    CsolverOutName = [CsolverOutName Xobj.CXsolver{i}.Sresponse]; %#ok<AGROW>
                    else
                        CsolverOutName = [CsolverOutName Xobj.CXsolver{i}.Coutputnames]; %#ok<AGROW>
                    end
                end
            end
            for i=1:length(Xobj.XcrackGrowth.Cinputnames)
                
                if ~sum(ismember([Xobj.Cinputnames CsolverOutName],Xobj.XcrackGrowth.Cinputnames{i}))
                    error('openCOSSAN:FatigueFracture',...
                        ['The CrackGrowth object requires a field named ''' Xobj.XcrackGrowth.Cinputnames{i} ''' in the inputs or in the outputs of the Evaluator object']);
                end
            end
            for i=1:length(Xobj.Xfracture.Cinputnames)
                if ~sum(ismember([Xobj.Cinputnames CsolverOutName Xobj.XcrackGrowth.Coutputnames],Xobj.Xfracture.Cinputnames{i}))
                    error('openCOSSAN:FatigueFracture',...
                        ['The Fracture object requires a field named ''' Xobj.Xfracture.Cinputnames{i} ''' in the inputs or in the outputs of the Evaluator object']);
                end
            end

        end % end constructor

        display(Xobj);
        varargout = apply(Xobj,Xin)
        
    end
    
end

