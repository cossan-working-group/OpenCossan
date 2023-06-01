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
        Mcorrelation       % Correlation matrix (physical space)
        Mcovariance        % Covariance matrix  (physical space) 
        McorrelationUspace % Correlation matrix in the standard space
        McovarianceUspace  % Covariance matrix in the standard space
        Lconvex=false      % Force the use of methods for ellipsoidal correlation even if uncorrelated (TOBEREMOVED) 
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
            opencossan.OpenCossan.validateCossanInputs(varargin{:});
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xbset.Sdescription=varargin{k+1};
                     case {'lconvex'}
                        Xbset.Lconvex=varargin{k+1};    
                    case {'cintervalnames','csmembers','cmembers'}
                        Xbset.Cmembers=varargin{k+1};
                        % transpose Cmembers if inputed as a column vector
                        if size(Xbset.Cmembers,2)==1
                            Xbset.Cmembers=Xbset.Cmembers';
                        end
                    case {'xiv','vxiv'}
                        Xbset.CXint=num2cell(varargin{k+1});
                    case {'cxint','cxintervals','cxmembers'}
                        Xbset.CXint=varargin{k+1};
                    case {'lindependence'}
                        Xbset.Lindependence=varargin{k+1};
                    case {'scorrelationtype','scorrelationshape'}
                        ScorrelationShape=varargin{k+1};
                    case 'mcorrelation'
                        Xbset.Mcorrelation=varargin{k+1};
                        % check if the correlation matrix is square
                        if size(Xbset.Mcorrelation,1) ~= size(Xbset.Mcorrelation,2)
                            error('openCOSSAN:common:inputs:BoundedSet',...
                                'The correlation matrix must be square');
                        end
                        % check correlation matrix
                        for i=1:length(Xbset.Mcorrelation)
                            if Xbset.Mcorrelation(i,i) ~=1
                                error('openCOSSAN:common:inputs:BoundedSet',...
                                    'The diagonal terms of the correlation matrix must be equal to one');
                            end
                            for j=i+1:length(Xbset.Mcorrelation)
                                if Xbset.Mcorrelation(i,j)==0;
                                    Xbset.Mcorrelation(i,j)= Xbset.Mcorrelation(j,i);
                                elseif  Xbset.Mcorrelation(j,i)==0;
                                    Xbset.Mcorrelation(j,i)= Xbset.Mcorrelation(i,j);
                                end
                                if Xbset.Mcorrelation(i,j) ~= Xbset.Mcorrelation(j,i)
                                    error('openCOSSAN:common:inputs:BoundedSet',...
                                        'The correlation matrix must be symetrical');
                                end
                                if abs(Xbset.Mcorrelation(i,j))>1
                                    error('openCOSSAN:common:inputs:BoundedSet',...
                                        'The terms of the correlation matrix must be in the range [0 1]');
                                end
                            end
                        end
                        if min(eig(Xbset.Mcorrelation))<0
                            error('openCOSSAN:common:inputs:BoundedSet',...
                                'The correlation matrix must be positive');
                        end
                        
                    case 'mcovariance'
                        Xbset.Mcovariance=varargin{k+1};
                        %check if the covariance matrix
                        if size(Xbset.Mcovariance,1) ~= size(Xbset.Mcovariance,2)
                            error('openCOSSAN:common:inputs:BoundedSet',...
                                'The covariance matrix must be square');
                        end
                        for i=1:length(Xbset.Mcovariance)
                            if Xbset.Mcovariance(i,i) <= 0
                                error('openCOSSAN:common:inputs:BoundedSet',...
                                    'The diagonal terms of the covariance matrix must be greater than zero');
                            end
                            if Xbset.Mcovariance(i,i)~=(Xbset.CXint{i}.radius)^2
                                error('openCOSSAN:common:inputs:BoundedSet',...
                                    'The correlation matrix is not valid');
                            end
                            for j=i+1:length(Xbset.Mcovariance)
                                if Xbset.Mcovariance(i,j)==0;
                                    Xbset.Mcovariance(i,j)= Xbset.Mcovariance(j,i);
                                elseif  Xbset.Mcovariance(j,i)==0;
                                    Xbset.Mcovariance(j,i)= Xbset.Mcovariance(i,j);
                                end
                                if Xbset.Mcovariance(i,j) ~= Xbset.Mcovariance(j,i)
                                    error('openCOSSAN:common:inputs:BoundedSet',...
                                        'The covariance matrix must be symetrical');
                                end
                                if Xbset.Mcovariance(i,j)^2 > Xbset.Mcovariance(i,i)*Xbset.Mcovariance(j,j)
                                    error('openCOSSAN:common:inputs:BoundedSet',...
                                        'The correlation matrix is not valid');
                                end
                            end
                        end
                        if min(eig(Xbset.Mcovariance))<0
                            error('openCOSSAN:common:inputs:BoundedSet',...
                                'The covariance matrix must be positive');
                        end
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
            
            if ~exist('ScorrelationShape','var') && isempty(Xbset.Mcorrelation) && isempty(Xbset.Mcovariance)
                ScorrelationShape='none';
                Xbset.Lindependence=true;
            elseif ~exist('ScorrelationShape','var') && (~isempty(Xbset.Mcorrelation) || ~isempty(Xbset.Mcovariance))
                ScorrelationShape='ellipse';
                Xbset.Lindependence=false; %DEFAULT
            end        
            
            Xbset.Niv=length(Xbset.CXint);
            
            %% Update object fields
            if ~isempty(Xbset.Cmembers)
                if length(Xbset.Cmembers)==1 && strcmpi(Xbset.Cmembers{1},'*all*')
                    OpenCossan.cossanDisp('All the interval variables present in the workspace will be added to the BoundedSet')
                    [Xbset.Cmembers, Xbset.CXint]= addall;
                    Lcheck=true;
                elseif isempty(Xbset.CXint)
                    [Lcheck, Xbset.CXint] = addbv(Xbset.Cmembers);
                else
                    Lcheck=true;
                end
                
                 if Lcheck                
                     if (isequal(Xbset.Mcorrelation,eye(size(Xbset.Mcorrelation,1))) && ...
                             isequal(Xbset.Mcovariance,diag(diag(Xbset.Mcovariance)))) && ~Xbset.Lconvex %to be removed
                         Xbset.Lindependence=true;
                         ScorrelationShape='none';
                     else
                         
                        if ~isempty(Xbset.Mcorrelation) % Mcorrelation given as an input 
                            if size(Xbset.Mcorrelation,1) ~= Xbset.Niv
                                error('openCOSSAN:common:inputs:BoundedSet',...
                                    'The size of the covariance matrix must be equal to the number of bounded variables')
                            end
                            if ~isempty(Xbset.Mcovariance)
                                warning('openCOSSAN:common:inputs:BoundedSet',...
                                    'The covariance matrix has been recalculated from the correlation matrix')
                            end
                            if ~issparse(Xbset.Mcorrelation)
                                Xbset.Mcorrelation=sparse(Xbset.Mcorrelation);
                            end
                            %% Compute the covariance matrix
                            Vradia=get(Xbset,'Vradia');
                            Vvar=Vradia.^2;                            
                            Xbset.Mcovariance = sqrt(Vvar(:)) * sqrt(Vvar(:))' .* full(Xbset.Mcorrelation);
                        elseif ~isempty(Xbset.Mcovariance) && isempty(Xbset.Mcorrelation) %the covariance matrix is given as an input
                            if size(Xbset.Mcovariance,1) ~= Xbset.Niv
                                error('openCOSSAN:common:inputs:BoundedSet',...
                                    'The size of the covariance matrix must be equal to the number of bounded variables')
                            end
                            if ~issparse(Xbset.Mcovariance)
                                Xbset.Mcovariance=sparse(Xbset.Mcovariance);
                            end
                            % check if the diagonal terms are equal to the variance of the bounded variables
                            Vradia=get(Xbset,'Vradia');
                            Vvar=Vradia.^2; 
                            Lmod=false;
                            for iCov = 1:length(Xbset.Mcovariance)
                                if Xbset.Mcovariance(iCov,iCov) ~= Vvar(iCov)
                                    PrevValue = Xbset.Mcovariance(iCov,iCov);
                                    Xbset.Mcovariance(iCov,:) = Xbset.Mcovariance(iCov,:) *sqrt(Vvar(iCov))/sqrt(PrevValue);
                                    Xbset.Mcovariance(:,iCov) = Xbset.Mcovariance(:,iCov) *sqrt(Vvar(iCov))/sqrt(PrevValue);
                                    Xbset.Mcovariance(iCov,iCov)  = 1;
                                    Lmod=true;

                                end
                            end
                            %% Compute the correlation matrix
                            Xbset.Mcorrelation = full(Xbset.Mcovariance)./sqrt(Vvar(:)) * sqrt(Vvar(:))' ;  
                            if Lmod
                                Xbset.Mcovariance = 0.5*(full(Xbset.Mcovariance) + full(Xbset.Mcovariance)');
                            end
                            
                            if min(eig(Xbset.Mcovariance))<0
                                error('openCOSSAN:Inputs:ConvexSet',...
                                    'The covariance matrix must be positive');
                            end
                                Xbset.Mcorrelation=sparse(Xbset.Mcorrelation);   
                        elseif Xbset.Lconvex && isempty(Xbset.Mcovariance) && isempty(Xbset.Mcorrelation)
                            Xbset.Mcorrelation=eye(Xbset.Niv);
                            Vradia=get(Xbset,'Vradia');
                            Vvar=Vradia.^2;                            
                            Xbset.Mcovariance = sqrt(Vvar(:)) * sqrt(Vvar(:))' .* full(Xbset.Mcorrelation);                            
                        end
                       
                     end
                 end
                 
            end
            
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
%             if ~Xbset.Lindependence
%                 VsetSize=zeros(1,Xbset.Niv);
%                 for n=1:Xbset.Niv
%                     VsetSize(n)=length(Xbset.CXint{n}.Vdata);
%                 end
%                 assert(sum(diff(VsetSize))==0,...
%                     'openCOSSAN:BoundedSet',...
%                     'In order to define correlation between interval variables the data sets must be the same size')
%             end
               
        end     %of constructor
        
        [varargout]     = get(Xbset,varargin)               % get method
        display(Xbset)                                      % This method shows the summary of the Xobj
        Xsample         = sample(Xbset,varargin)            % Random sample within the bounded set
        Mh              = map2hypercube(Xbset,varargin)     % Map points in the set to the unitary hypercube
        Mp              = map2physical(Xbset,varargin)      % Map points from the hypercube to the physical space
        MD              = map2hypersphere(Xbset,varargin)   % Map points from uspace to hypersphere
        Xbset           = remove(Xbset, varargin)           % Removes an Interval object from a BoundedSet object

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
    end     %of public methods
    
    %% Private methods
    methods (Access=private)    
        MConvex         = defineMconvex(Xbset,varargin)     % Compute the characteristic matrix of the Convex Set
        MU              = map2uspace(Xbset,MX)              % Maps points from the physical space to the u space (normalized uncorrelated intervals)
    end % of private methods
    
end     %of class definition
