classdef Coordinates < handle
    
    properties
        Mcoord
        CSindexUnit
        CSindexName
    end
    
    methods
        function Xobj = Coordinates(varargin)
            if nargin==0
                % This allows to contruct an empty Dataseries object
                return;
            end
            
            if OpenCossan.getChecks
                OpenCossan.validateCossanInputs(varargin{:})
            end
            
            for k=1:2:length(varargin)
                switch(lower(varargin{k}))
                    case {'sindexunit'}
                        % if Mcoord is monodimensional, just pass a string
                        Xobj.CSindexUnit = varargin(k+1);
                    case {'sindexname'}
                        % if Mcoord is monodimensional, just pass a string
                        Xobj.CSindexName = varargin(k+1);
                    case {'csindexunit'}
                        Xobj.CSindexUnit = varargin{k+1};
                    case {'csindexname'}
                        Xobj.CSindexName = varargin{k+1};
                    case {'mcoord','vcoord'}
                        Xobj.Mcoord = varargin{k+1};
                    otherwise
                        error()
                end
                
                % check that the index names are compatible with the dimension
                % of Mcoord
                if ~isempty(Xobj.CSindexName) && ~isempty(Xobj.Mcoord)
                    if OpenCossan.getChecks
                        assert(length(Xobj.CSindexName)==size(Xobj.Mcoord,1),...
                            'openCOSSAN:Dataseries:Dataseries',...
                            ['The no. of elements in CSindexName and no. of rows of Mcoord are not compatible.\n'...
                            ' no. of elements of SindexName: ' num2str(length(Xobj.CSindexName))...
                            '\n no. of rows of Mcoord: ' num2str(size(Xobj.Mcoord,1))])
                    end
                end
                if ~isempty(Xobj.CSindexUnit) && ~isempty(Xobj.Mcoord)
                    if OpenCossan.getChecks
                        assert(length(Xobj.CSindexUnit)==size(Xobj.Mcoord,1),...
                            'openCOSSAN:Dataseries:Dataseries',...
                            ['The no. of elements in CSindexUnit and no. of rows of Mcoord are not compatible.\n'...
                            ' no. of elements of SindexName: ' num2str(length(Xobj.CSindexUnit))...
                            '\n no. of rows of Mcoord: ' num2str(size(Xobj.Mcoord,1))])
                    end
                end
                
            end
        end
        
        
    end
    
end