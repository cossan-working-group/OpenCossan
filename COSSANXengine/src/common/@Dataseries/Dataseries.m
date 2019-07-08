classdef Dataseries
    %DATASERIES This class contains the realisations of a StochasticProcess
    % 
    % Size(Xobj,1) = Number of realisations
    % Size(Xobj,2) = Number of StochasticProcess
    %
    % See Also: https://cossan.co.uk/wiki/index.php/@Dataseries
    %
    % Author: Matteo Broggi and Edoardo Patelli
    % Institute for Risk and Uncertainty, University of Liverpool, UK
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties (SetAccess=public)
        Sdescription = ''
        Xcoord
        Vdata = []
    end
        
    properties (Dependent=true)
        Ndimensions
        VdataLength
        Mcoord
    end
    
    methods
        function Xobj = Dataseries(varargin)
            % See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Dataseries
            %
            % Author: Matteo Broggi and Edoardo Patelli
            % Institute for Risk and Uncertainty, University of Liverpool, UK
            % email address: openengine@cossan.co.uk
            % Website: http://www.cossan.co.uk
            
            % =====================================================================
            % This file is part of openCOSSAN.  The open general purpose matlab
            % toolbox for numerical analysis, risk and uncertainty quantification.
            %
            % openCOSSAN is free software: you can redistribute it and/or modify
            % it under the terms of the GNU General Public License as published by
            % the Free Software Foundation, either version 3 of the License.
            %
            % openCOSSAN is distributed in the hope that it will be useful,
            % but WITHOUT ANY WARRANTY; without even the implied warranty of
            % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
            % GNU General Public License for more details.
            %
            %  You should have received a copy of the GNU General Public License
            %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
            % =====================================================================
            if nargin==0
                % This allows to contruct an empty Dataseries object
                return;
            end
            
            %% Argument Check
            if OpenCossan.getChecks
                OpenCossan.validateCossanInputs(varargin{:})
            end
            
            Mdata  = [];
            Mcoord = [];
            CSindexUnit = {};
            CSindexName = {};
            
            %% Process arguments passed to the constructor
            for k=1:2:nargin
                switch lower(varargin{k})
                    case {'sdescription'}
                        % Description of object Dataseries
                        Xobj.Sdescription = varargin{k+1};
                    case {'sindexunit'}
                        % if Mcoord is monodimensional, just pass a string
                        CSindexUnit = varargin(k+1);
                    case {'sindexname'}
                        % if Mcoord is monodimensional, just pass a string
                        CSindexName = varargin(k+1);
                    case {'csindexunit'}
                        CSindexUnit = varargin{k+1};
                    case {'csindexname'}
                        CSindexName = varargin{k+1};
                    case {'mcoord','vcoord'}
                        Mcoord = varargin{k+1};
                    case 'xcoord'
                        Xobj.Xcoord = varargin{k+1};
                    case {'mdata','vdata' }
                        Mdata = varargin{k+1};
                    case {'mmatrix'}
                        matrix = varargin{k+1};
                        %  Data in Matrix form, converted to a vector and
                        %  Mcoord will be automatically created
                        [Vi,Vj]=ind2sub(size(matrix),1:numel(matrix));
                        Mcoord = [Vi;Vj];
                        Xobj.Vdata(1,:) = reshape(matrix,1,[]);
                        CSindexName = {'i','j'};
                        CSindexUnit = {'',''};
                    otherwise
                        % Case of an unknown parameter
                        error('openCOSSAN:Dataseries:unknownInputArgument', ...
                            ' The PropertyName %s is not a valid input argument',varargin{k})
                end
            end
                    
                        
            % create coordinate           
            if isempty(Xobj.Xcoord)
                % check that the size of Mcoord and Mdata are compatible
                if ~isempty(Mdata)
                    if isempty(Mcoord)
                        % set Mcoord to the default value (1 2 3... for each
                        % dimension) if empty.
                        Mcoord = 1:length(Mdata(1,:));
                    end
                end    
                Xobj.Xcoord = Coordinates('Mcoord',Mcoord,'CSindexUnit',CSindexUnit, 'CSindexName',CSindexName);
            end
            
            % check that all the Mcoord is compatible with all the Mdata
            sizeMcoord=size(Xobj.Xcoord.Mcoord,2);
            sizesVdata=size(Mdata,2);
            
            if OpenCossan.getChecks
            assert(sizesVdata == sizeMcoord,'openCOSSAN:Dataseries',...
                ['Dimension of data (' num2str(sizesVdata) ') is not equal to the dimension of the coordinates (' num2str(sizeMcoord) ')'])
            end
            
            for idata = size(Mdata,1):-1:1
                Xobj(idata,1).Xcoord = Xobj(1).Xcoord;
                Xobj(idata,1).Vdata = Mdata(idata,:);
            end
        end
        
        %% Method isempty
        function Lempty=isempty(Xobj)
            Lempty = 0;
            if isempty(Xobj(1).Vdata)
                Lempty=1;
            end
        end
        
        function Nel = numel(Xobj,varargin)
            if isempty(Xobj)
                Nel = 1;
            else
                Nel = length(Xobj);
            end
        end
        
        %% Methods cat, horzcat, vertcat
        Xobj = cat(Ndim,varargin)
        
        function Xobj = vertcat(varargin)
            % VERTCAT Horizontal concatenation for Dataseries arrays.
            %   Xds = vertcat(Xds1, Xds2, ...) horizontally concatenates the Dataseries arrays
            %   Xds1, Xds2, ... . Only Dataseries arrays that have identical Mcoord,
            %   SindexName and SindexUnit
            %
            % See also: https://cossan.co.uk/wiki/index.php/vertcat@Dataseries
            
            % Check they are all Dataseries
            assert(all(cellfun(@(x) isa(x,'Dataseries'),varargin)),'opencossan:Dataseries:vertcat',...
                'Not all the objects are of class Dataseries');
            
            Xobj=builtin('vertcat', varargin{:});
                       
        end
        
        function Xobj = horzcat(varargin)
            % HORZCAT Horizontal concatenation for Dataseries arrays.
            %   Xds = horzcat(Xds1, Xds2, ...) horizontally concatenates the Dataseries arrays
            %   Xds1, Xds2, ... .
            %
            % See also: https://cossan.co.uk/wiki/index.php/horzcat@Dataseries
                        
            % Check they are all Dataseries
            assert(all(cellfun(@(x) isa(x,'Dataseries'),varargin)),'opencossan:Dataseries:vertcat',...
                'Not all the objects are of class Dataseries');
            % check they have identical number of samples
            assert(numel(unique(cellfun(@(x) size(x,1),varargin)))==1,...
                    'opencossan:Dataseries:vertcat',...
                    'Not all the objects have the same number of samples')
                
            Xobj=builtin('horzcat', varargin{:});
            
        end
        
        %% Other methods definitions
        varargout = plot(Xobj,varargin); % Plot Dataseries
        
        Xobj = addData(Xobj,varargin) % add data to a single dataseries object
        Xobj = chopData(Xobj, Vindex) % remove data from a single dataseries object
        
        Xobj = addSamples(Xobj,varargin) % add samples to a vector of dataseries objects
        Xobj = chopSamples(Xobj, Vindex) % remove data from a vector of dataseries objects
        Xobj = getSamples(Xobj, Vindex) % get data from a vector of dataseries objects
        
        
        %% Method isNan
        function Lnans = isnan(Xobj)
            Lnans = false(size(Xobj));
            for icol = 1:size(Xobj,2)
                for irow = 1:size(Xobj,1)
                    Lnans(irow, icol) = all(isnan(Xobj(icol).Vdata(irow,:)));
                end
            end
        end
        
        %% Dependent fields
        % Note: this dependent fields can be set or get only if a single
        % Dataseries is accessed
        
        % methods get of Ndimensions
        function Ndimensions=get.Ndimensions(Xobj)
            Ndimensions = zeros(1,size(Xobj,2));
            for icol = 1:size(Xobj,2)
                Ndimensions(icol)=size(Xobj(1,icol).Xcoord.Mcoord,1);
            end
        end
        
        function VdataLength = get.VdataLength(Xobj)
            VdataLength = numel(Xobj.Xcoord.Mcoord);
        end
        
        function Mcoord = get.Mcoord(Xobj)
            Mcoord = Xobj.Xcoord.Mcoord;
        end
        
    end
    
    
end
