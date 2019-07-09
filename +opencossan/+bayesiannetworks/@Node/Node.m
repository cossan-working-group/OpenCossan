classdef Node  < matlab.mixin.Heterogeneous
    % Abstract class for creating Node objects  
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
    
    properties 
        Name(1,1)string             % Name of the node
        Parents string              % Cell array of parent nodes
        CPD                         % Conditional probability table
        StateBounds {mustBeNumeric} % Value of the bounds for the outcome states
    end
    
    properties (Dependent = true, SetAccess = protected)
        Size            % Size of the node
        Lroot           % Flag for root nodes
        Lboolean        % Flag for Boolean nodes (true or false outcome)
    end      
       
    methods % for dependent properties
        function Size = get.Size(obj)
            Size = getNodeSize(obj);
        end 
        
        function Lroot = get.Lroot(obj)
            if isempty(obj.Parents)
                Lroot = 1;
            else
                Lroot = 0;
            end      
        end 
        
        function Lboolean = get.Lboolean(obj)
            if obj.Size==2
                Lboolean = 1;
            else
                Lboolean = 0;
            end      
        end 
        
    end 
    
end

