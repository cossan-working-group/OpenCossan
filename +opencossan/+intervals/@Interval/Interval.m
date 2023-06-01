classdef Interval < opencossan.common.inputs.Parameter
    %INTERVAL This class define the object type Interval.
    %
    %   The Interval object is defined by a lower and a upper bound.
    %   A Interval object can be then attached to an Input object.
    %   For more detailed information, see <a
    %   href="https://cossan.co.uk/wiki/index.php/@Interval">OpenCossan-Wiki</a>.
    %
    %   Interval Properties:
    %       lowerBound - lower bound of interval
    %       upperBound - Upper bound of interval
    %       radis - Radius of the interval
    %       center - Center of the interval
    %
    %   Interval Methods:
    %
    %       getPropertyGroups - Propertygroups for display method
    %
    %   See also: opencossan.common.inputs.Parameter

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
    
    properties % Public access
        lowerBound         % lower bound or left end-point
        upperBound         % upper bound or right end-point
    end
    
    properties (Dependent)
        radius             % radius of the interval
        centre             % central (mid) value of the interval
    end
    
    methods      
        function Xobj   = Interval(varargin)
            % INTERVAL This method construct an object of type Interval
                      
            % Split arguments for this class and superclass
            CpropertyNames={'lowerbound','upperbound','centre','center','radius'};
            Vindex=true(length(varargin),1);
            for k=1:2:length(varargin)
                if ismember(lower(varargin{k}),CpropertyNames)
                    Vindex(k:k+1)=false;
                end
            end
            
            CsuperclassArguments=varargin(Vindex);
            CobjArguments=varargin(~Vindex);
            
            % Reuse the Mio constructor
            Xobj=Xobj@opencossan.common.inputs.Parameter(CsuperclassArguments{:});
            
            if nargin==0
                % Create an empty object
                return
            end
            
            for k=1:2:length(CobjArguments)
                switch lower(CobjArguments{k})
                    case {'lowerbound'}
                        Xobj.lowerBound=CobjArguments{k+1};
                    case {'upperbound'}
                        Xobj.upperBound=CobjArguments{k+1};
                    case {'centre','center'}
                        centre=CobjArguments{k+1};
                    case {'radius'}
                        radius=CobjArguments{k+1};
                    otherwise
                        error('openCOSSAN:Interval:wrongArgument',...
                            'PropertyName %s is not valid ', CobjArguments{k});
                end
            end
            
            
            if and(exist('centre','var'),exist('radius','var'))
                Xobj.lowerBound=centre-radius;
                Xobj.upperBound=centre+radius;
            elseif isempty([Xobj.lowerBound,Xobj.upperBound])
                assert(xor(exist('centre','var'),exist('radius','var')),...
                    'openCOSSAN:Interval:CentreAndRadius',...
                    ['It is necessary to provide the centre AND the radius of the Interval.\n', ...
                    'Otherwise, the interval can be defined using lowerBound and upperBound'])
            end
            
            assert(Xobj.upperBound>Xobj.lowerBound,...
                'openCOSSAN:Interval:wrongBound',...
                'The upper bound (%e) must be greater than the lower bound (%e)!',Xobj.upperBound,Xobj.lowerBound)
            
            % Store the values 
            Xobj.Value=[Xobj.lowerBound Xobj.upperBound];
            
        end    
        
        % Method for dependent properties
        function centre=get.centre(Xobj)
            centre=(Xobj.upperBound+Xobj.lowerBound)/2;
            %                 Xobj.radius=(Xobj.upperBound-Xobj.lowerBound)/2;
        end
        
        function radius=get.radius(Xobj)
            radius=(Xobj.upperBound-Xobj.lowerBound)/2;
        end
        
        % maps points to the uspace (normalized interval)
        function VU = map2uspace(Xin,VX)
            if not(nargin==2)
                error('Incorrect number of arguments');
            end
            VU= (VX(:)-Xin.centre)/Xin.radius;
        end
        
        % maps points from the u-space to the physical space
        function VX = map2physical(Xint,VU)
            if not(nargin==2)
                error('Incorrect number of arguments');
            end
            VX = (VU * Xint.radius) + Xint.centre;
        end
            
    end
    
    methods (Access = protected)
        function groups = getPropertyGroups(obj)
           %GETPROPERTYGROUPS Prop. groups for disply method
           import matlab.mixin.util.PropertyGroup;
           if ~isscalar(obj)
               propList = {'Description', 'LowerBounds', 'UpperBounds', 'Radius', 'Center'};              
           else
               propList = struct();
               propList.LowerBound = obj.lowerBound;
               propList.UpperBound = obj.upperBound;
               propList.Radius = obj.radius;
               propList.Centre = obj.centre;
           end
           groups = PropertyGroup(propList);
        end
    end
end
