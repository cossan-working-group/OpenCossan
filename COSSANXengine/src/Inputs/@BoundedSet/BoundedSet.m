classdef BoundedSet
    % BOUNDEDSET  This class defines an Object of type BoundedSet
    %
    % The BoundedSet constructs an object for a set of Interval accounting
    % for correlation among intervals. If no correlation is defined the
    % BoundedSet makes the Cartesian product of all intervals.
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@BoundedSet
    %
    % Author:~Marco~de~Angelis
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
    
    properties (SetAccess=protected)
        Sdescription       % Description of the BoundedSet object
        CXint              % Cell Array of Interval objects
        Cmembers           % Names of the Interval objects
        Lindependence      % condition for independent interval variables
        ScorrelationFlag   % Type of correlation (default=elliptic)
        Niv                % Number of interval variables defined in the set
    end
    
    properties (Dependent=true)
        VlowerBounds       % Lower bounds of the bounded variables
        VupperBounds       % Upper bounds of the bounded variables
        Vradia             % Radius of the intervals
        VinteriorValues    % Coordinates of a point in the bounded set
    end
    %        Niv                % Number of interval variables defined in the set
    
    methods
        % Constructor
        function Xbset   = BoundedSet(varargin)
            % BOUNDEDSET This method constructs the BoundedSet object
            %
            % Please refer to the Reference Manual for more information
            % See also:
            % https://cossan.co.uk/wiki/index.php/@BoundedSet
            
            if nargin==0
                % Create an empty object
                return
            end
            
            % Process Inputs
            OpenCossan.validateCossanInputs(varargin{:});
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xbset.Sdescription=varargin{k+1};
                    case {'cintervalnames','csmembers'}
                        Xbset.Cmembers=varargin{k+1};
                    case {'xiv','vxiv'}
                        Xbset.CXint=num2cell(varargin{k+1});
                    case {'cxint','cxintervals','cxmembers'}
                        Xbset.CXint=varargin{k+1};
                    case {'lindependence'}
                        Xbset.Lindependence=varargin{k+1};
                    case {'scorrelationtype','scorrelationshape'}
                        ScorrelationShape=varargin{k+1};
                    otherwise
                        error('openCOSSAN:BoundedSet',...
                            'PropertyName %s is not valid ', varargin{k});
                end
            end
            
            %% Check inputs
            assert(isa(Xbset.CXint,'cell'),...
                'openCOSSAN:BoundedSet',...
                'It is mandatory to pass the name of the Interval using the field Cmembers')
            
            if ~isempty(Xbset.CXint) && length(Xbset.CXint)~=length(Xbset.Cmembers)
                error('openCOSSAN:Inputs:BoundedSet',...
                    ['The length of the cell containig names does NOT correspont',... 
                    'to the length of the cell containing Intervals'])
            end
            
            if ~exist('ScorrelationShape','var')
                ScorrelationShape='none';
                Xbset.Lindependence=true;
            end
            
            Xbset.Niv=length(Xbset.CXint);
            
            %% Correlation
            
            switch lower(ScorrelationShape)
                case {'none'}
                    Xbset.ScorrelationFlag='0';
                    Xbset.Lindependence=true;
                case {'box'}
                    Xbset.ScorrelationFlag='1';
                    Xbset.Lindependence=false;
                case {'ellipse'}
                    Xbset.ScorrelationFlag='2';
                    Xbset.Lindependence=false;
                case {'polytope'}
                    Xbset.ScorrelationFlag='3';
                    Xbset.Lindependence=false;
                otherwise
                    Xbset.ScorrelationFlag='0';
                    Xbset.Lindependence=true;
                    warning('openCOSSAN:BoundedSet',...
                        'The property name "%s" for the correlation shape is not valid \n thus no correlation will be considered.',...
                        ScorrelationShape)
            end
            
            % check the data sets have the same size
            if ~Xbset.Lindependence
                VsetSize=zeros(1,Xbset.Niv);
                for n=1:Xbset.Niv
                    VsetSize(n)=length(Xbset.CXint{n}.Vdata);
                end
                assert(sum(diff(VsetSize))==0,...
                    'openCOSSAN:BoundedSet',...
                    'In order to define correlation between interval variables the data sets must be the same size')
            end
            
            
        end     %of constructor
        
        [varargout] = get(Xbset,varargin)    % get method
        display(Xbset)                       % This method shows the summary of the Xobj
        Xsample = sample(Xbset,varargin)     % Random sample within the bounded set
        Mh = map2hypercube(Xbset,varargin)   % Map points in the set to the unitary hypercube
        Mp = map2physical(Xbset,varargin)    % Map points from the hypercube to the physical space
        
                %         function Niv=Niv.get(Xobj)
        %             Niv=length(Xobj.Cmembers);
        %         end
        
        function VlowerBounds=get.VlowerBounds(Xbset)
            VlowerBounds=zeros(1,Xbset.Niv);
            for n=1:Xbset.Niv
                VlowerBounds(n)=Xbset.CXint{n}.lowerBound;
            end
        end
        function VupperBounds=get.VupperBounds(Xbset)
            VupperBounds=zeros(1,Xbset.Niv);
            for n=1:Xbset.Niv
                VupperBounds(n)=Xbset.CXint{n}.upperBound;
            end
        end
        function Vradia=get.Vradia(Xbset)
            Vradia=zeros(1,Xbset.Niv);
            for n=1:Xbset.Niv
                Vradia(n)=Xbset.CXint{n}.radius;
            end
        end
        
        function VinValue=get.VinteriorValues(Xbset)
            if ~strcmp(Xbset.ScorrelationFlag,'3')
               VinValue=zeros(1,Xbset.Niv);
               for n=1:Xbset.Niv
                   VinValue(n)=Xbset.CXint{n}.centre;                   
               end
            elseif strcmp(Xbset.ScorrelationFlag,'3')
                % add check if the centre is inside the polytope
            end
            
        end
        
    end     %of methods
    
end     %of class definition
