classdef Interval
    %Interval  This class constructs an Object of type Interval
    %
    %   The Interval object is defined by a lower and a upper bound.
    %   A Interval object can be then attached to an Input object.
    %
    % See also:
    % https://cossan.co.uk/wiki/index.php/@Interval
    %
    % $Author:~Marco~de~Angelis$
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
    
    properties % Public access
        Sdescription       % Description of the interval
        lowerBound         % lower bound or left end-point
        upperBound         % upper bound or right end-point
        radius             % radius of the interval
        centre             % central (mid) value of the interval
        Vdata              % construct the interval from a data set
    end
    
    properties (Dependent)
    end
    
    methods
        display(Xobj)                 % This method shows the summary of the Xobj
        
        %% Constructor
        
        function Xobj   = Interval(varargin)
            % INTERVAL This method define an object of type Interval
            %
            % Please refer to the Reference Manual for more information
            % See also:
            % https://cossan.co.uk/wiki/index.php/@Interval
            
            if nargin==0
                % Create an empty object
                return
            end
            
            % Process Inputs
            OpenCossan.validateCossanInputs(varargin{:});
            
            for k=1:2:length(varargin)
                switch lower(varargin{k})
                    case {'sdescription'}
                        Xobj.Sdescription=varargin{k+1};
                    case {'lowerbound'}
                        Xobj.lowerBound=varargin{k+1};
                    case {'upperbound'}
                        Xobj.upperBound=varargin{k+1};
                    case {'centre','center'}
                        Xobj.centre=varargin{k+1};
                    case {'radius'}
                        Xobj.radius=varargin{k+1};
                    case {'vdata','dataset'}
                        Xobj.Vdata=varargin{k+1};
                    otherwise
                        error('openCOSSAN:Interval',...
                            'PropertyName %s is not valid ', varargin{k});
                end
            end
            
            if ~isempty(Xobj.Vdata)
                Xobj.lowerBound=min(Xobj.Vdata);
                Xobj.upperBound=max(Xobj.Vdata);
                Xobj.centre=(Xobj.upperBound+Xobj.lowerBound)/2;
                Xobj.radius=(Xobj.upperBound-Xobj.lowerBound)/2;
            elseif isempty(Xobj.centre) && isempty(Xobj.radius)
                assert(~isempty(Xobj.upperBound) || ~isempty(Xobj.lowerBound),...
                    'openCOSSAN:Interval',...
                    'At least two properties must be passed to define an interval');
                Xobj.centre=(Xobj.upperBound+Xobj.lowerBound)/2;
                Xobj.radius=(Xobj.upperBound+Xobj.lowerBound)/2;
            elseif isempty(Xobj.upperBound) && isempty(Xobj.radius)
                assert(~isempty(Xobj.centre) || ~isempty(Xobj.lowerBound),...
                    'openCOSSAN:Interval',...
                    'At least two properties must be passed to define an interval');
                Xobj.upperBound=3*Xobj.centre-2*Xobj.lowerBound;
                Xobj.radius=Xobj.centre-Xobj.lowerBound;
            elseif isempty(Xobj.upperBound) && isempty(Xobj.centre)
                assert(~isempty(Xobj.lowerBound) || ~isempty(Xobj.radius),...
                    'openCOSSAN:Interval',...
                    'At least two properties must be passed to define an interval');
                Xobj.upperBound=Xobj.lowerBound+2*Xobj.radius;
                Xobj.centre=Xobj.lowerBound+Xobj.radius;
            elseif isempty(Xobj.lowerBound) && isempty(Xobj.centre)
                assert(~isempty(Xobj.upperBound) || ~isempty(Xobj.radius),...
                    'openCOSSAN:Interval',...
                    'At least two properties must be passed to define an interval');
                Xobj.lowerBound=Xobj.upperBound-2*Xobj.radius;
                Xobj.centre=Xobj.upperBound+Xobj.radius;
            elseif isempty(Xobj.lowerBound) && isempty(Xobj.radius)
                assert(~isempty(Xobj.upperBound) || ~isempty(Xobj.centre),...
                    'openCOSSAN:Interval',...
                    'At least two properties must be passed to define an interval');
                Xobj.lowerBound=2*Xobj.centre-Xobj.upperBound;
                Xobj.radius=Xobj.upperBound+Xobj.centre;
            elseif isempty(Xobj.upperBound) && isempty(Xobj.lowerBound)
                assert(~isempty(Xobj.centre) || ~isempty(Xobj.radius),...
                    'openCOSSAN:Interval',...
                    'At least two properties must be passed to define an interval');
                Xobj.lowerBound=Xobj.centre-Xobj.radius;
                Xobj.upperBound=Xobj.centre+Xobj.radius;
            end
            
            
            
            assert(Xobj.upperBound>Xobj.lowerBound,...
                'openCOSSAN:Interval',...
                'The upper bound must be greater than the lower bound!')
            assert(Xobj.radius>0,...
                'openCOSSAN:Interval',...
                'The radius of the interval must be a positive number!')
            assert(Xobj.centre>Xobj.lowerBound || Xobj.centre<Xobj.upperBound,...
                'openCOSSAN:Interval',...
                'The centre of the interval must be in between lower and upper bounds')
            
        end     %of constructor
        
    end     %of methods
    
end     %of class definition
