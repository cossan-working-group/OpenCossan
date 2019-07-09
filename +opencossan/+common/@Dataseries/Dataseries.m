classdef Dataseries
    %DATASERIES This class contains the realisations of a StochasticProcess
    %
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
    
    properties (SetAccess=public)
        Sdescription = ''
        Mcoord = []
        CSindexName = {''}
        CSindexUnit = {''}
    end
    
    properties (SetAccess=public, Hidden=true)
        Mdata = []
    end
    
    properties (Dependent=true)
        Vdata
        Ndimensions
        VdataLength
        Nsamples
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
            
            
            %% Process arguments passed to the constructor
            for k=1:2:nargin,
                switch lower(varargin{k}),
                    case {'sdescription'}
                        % Description of object Dataseries
                        Xobj.Sdescription = varargin{k+1};
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
                    case {'mcoord','vcoord'},
                        Xobj.Mcoord = varargin{k+1};
                    case {'mdata'},
                        Xobj.Mdata = varargin{k+1};
                    case {'vdata'},
                        Xobj.Mdata(1,:) = varargin{k+1};
                    case {'mmatrix'},
                        matrix = varargin{k+1};
                        %  Data in Matrix form, converted to a vector and
                        %  Mcoord will be automatically created
                        [Vi,Vj]=ind2sub(size(matrix),1:numel(matrix));
                        Xobj.Mcoord = [Vi;Vj];
                        Xobj.Mdata(1,:) = reshape(matrix,1,[]);
                        Xobj.CSindexName = {'i','j'};
                        Xobj.CSindexUnit = {'',''};
                    otherwise
                        % Case of an unknown parameter
                        error('openCOSSAN:Dataseries:unknownInputArgument', ...
                            ' The PropertyName %s is not a valid input argument',varargin{k})
                end
            end
            
            % check that the size of Mcoord and Mdata are compatible
            if ~isempty(Xobj.Mdata)
                if isempty(Xobj.Mcoord)
                    % set Mcoord to the default value (1 2 3... for each
                    % dimension) if empty.
                    Xobj.Mcoord = 1:length(Xobj.Mdata(1,:));
                end
                
                if size(Xobj.Mcoord,2) ~= size(Xobj.Mdata,2)
                    error('openCOSSAN:Dataseries:Dataseries',['The no. of columns of Mcoord and of Mdata are not compatible.\n'...
                        ' no. of columns of Mcoord: ' num2str(size(Xobj.Mcoord,2))...
                        '\n no. of columns of Mdata : ' num2str(size(Xobj.Mdata,2))])
                end
                % check that the index names are compatible with the dimension
                % of Mcoord
                if ~isempty(Xobj.CSindexName) 
                                             assert(length(Xobj.CSindexName)==size(Xobj.Mcoord,1),...
                        'openCOSSAN:Dataseries:Dataseries',...
                        ['The no. of elements in CSindexName and no. of rows of Mcoord are not compatible.\n'...
                        ' no. of elements of SindexName: ' num2str(length(Xobj.CSindexName))...
                        '\n no. of rows of Mcoord: ' num2str(size(Xobj.Mcoord,1))])
                end
                if ~isempty(Xobj.CSindexUnit) 
                    assert(length(Xobj.CSindexUnit)==size(Xobj.Mcoord,1),...
                        'openCOSSAN:Dataseries:Dataseries',...
                        ['The no. of elements in CSindexUnit and no. of rows of Mcoord are not compatible.\n'...
                        ' no. of elements of SindexName: ' num2str(length(Xobj.CSindexUnit))...
                        '\n no. of rows of Mcoord: ' num2str(size(Xobj.Mcoord,1))])
                else
                    Xobj.CSindexUnit{1,icol} = repmat((','),1,size(Xobj.CMcoord{1,icol},1)-1);
                end
            end
            
            
            % check that all the Mcoord is compatible with all the Mdata
            sizeMcoord=size(Xobj.Mcoord,2);
            sizesVdata=size(Xobj.Mdata,2);
            
            assert(sizesVdata == sizeMcoord,'openCOSSAN:Dataseries',...
                ['Dimension of data (' num2str(sizesVdata) ') is not equal to the dimension of the coordinates (' num2str(sizeMcoord) ')'])
            
        end
        
        %% Method isempty
        function Lempty=isempty(Xobj)
            Lempty = 0;
            if isempty(Xobj(1).Mdata)
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
        
        function Xobj = vertcat(Xobj,varargin)
            % VERTCAT Horizontal concatenation for Dataseries arrays.
            %   Xds = vertcat(Xds1, Xds2, ...) horizontally concatenates the Dataseries arrays
            %   Xds1, Xds2, ... . Only Dataseries arrays that have identical Mcoord,
            %   SindexName and SindexUnit
            %
            % See also: https://cossan.co.uk/wiki/index.php/vertcat@Dataseries
            %Xobj = cat(1,varargin{:});
            Nds=size(Xobj,1);
            for n=1:length(varargin)
                Xobj(Nds+n,1)=varargin{n};
            end

        end
        
        function Xobj = horzcat(Xobj,varargin)
            % HORZCAT Horizontal concatenation for Dataseries arrays.
            %   Xds = horzcat(Xds1, Xds2, ...) horizontally concatenates the Dataseries arrays
            %   Xds1, Xds2, ... .
            %
            % See also: https://cossan.co.uk/wiki/index.php/horzcat@Dataseries
            %Xobj = cat(2,Xobj,varargin{:});
            Nds=size(Xobj,2);
            for n=1:length(varargin)
                Xobj(1,Nds+n)=varargin{n};
            end
        end
        
        %% Other methods definitions
        varargout = plot(Xobj,varargin); % Plot Dataseries

        varargout = subsref(Xobj,Tsubstruct)
        
        Xobj = addData(Xobj,varargin) % add data to a single dataseries object
        Xobj = chopData(Xobj, Vindex) % remove data from a single dataseries object
        
        Xobj = addSamples(Xobj,varargin) % add samples to a vector of dataseries objects
        Xobj = chopSamples(Xobj, Vindex) % remove data from a vector of dataseries objects
        Xobj = getSamples(Xobj, Vindex) % get data from a vector of dataseries objects
        
        %% Method getDataLength
        function Nsamples=get.Nsamples(Xobj)
            if isempty(Xobj.Mdata)
                Nsamples=0;
            else
                Nsamples=size(Xobj(1).Mdata,1);
            end
        end
        
        %% Method isNan
        function Lnans = isnan(Xobj)
            Lnans = false(size(Xobj));
            for icol = 1:size(Xobj,2)
                for irow = 1:size(Xobj,1)
                    Lnans(irow, icol) = all(isnan(Xobj(icol).Mdata(irow,:)));
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
                Ndimensions(icol)=size(Xobj(1,icol).Mcoord,1);
            end
        end
        
        function VdataLength = get.VdataLength(Xobj)
            VdataLength = numel(Xobj.Mcoord);
        end
    end
    
    methods(Access=private)
        % These methods are useful to retrieve the samples from a vector of
        % Dataseries
        % Check on 18/03/2014 by EP
        %
        varargout = subsrefParens(Xobj,Tsubstruct);
        varargout = subsrefDot(Xobj,Tsubstruct);
    end
    
end
