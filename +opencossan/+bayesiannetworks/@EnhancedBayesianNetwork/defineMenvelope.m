function Cenvelope = defineMenvelope(EBN,varargin)
%DEFINEMENVELOPE method of the class EnhancedBayesianNetwork allows to
% identify the Markov envelope of the node of interest. The Markov envelope
% of a node is defined as the set of all the nodes of the Markov blanket
% of node i (Parents, Children and Spouses of i) and of the Markov
% blankets of each continuous node belonging to the Markov blanket of i.
% To identify this set allows to reduce the number of structural reliability
% analysis needed to reduce a eBN to a traditional BN
%
%
% Author: Silvia Tolo
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

%% Collect node name from input (varargin= node name||obj)
if isa(varargin{1},'Node')
    
    name=varargin{1}.Name;
    
elseif ischar(varargin{1})
    
    name=varargin{1};
    
else
    
    error('openCOSSAN:EnhancedBaeysianNetwork:defineMenvelope',...
        'Node object needed')
    
end

%% Start collecting nodes to add to the envelope
% if strcmp(Xebn.Cnodes{strcmp(Xebn.Cnames,name)}.Stype,'discrete') % check if the node introduced is discrete
%     
%     ind=strcmp(Xebn.Cnames,name); % Index node in the net
%     
%     % cell array of names of node to add to the envelope
%     toAdd=intersect([Xebn.Cnodes{ind}.CSparents,Xebn.Cnodes{ind}.CSchildren],Xebn.Ccontinuous);
%     
%     assert (~isempty(toAdd),...
%         'openCOSSAN:EnhancedBaeysianNetwork:defineMenvelope',...
%         'Node introduced is not directly connected to any non-discrete node')
%     
% else
    
    toAdd={name}; % Let's start with the input node
    
% end

%% Initialize variables
Nmax=length(EBN.ProbabilisticNodes); % Max number of markov blankets to add to the envelope
Menvelope=cell(1,Nmax);              % Inizialize cell array of names of nodes in the envelope
added=cell(1,Nmax);                  % Initialize cell array of nodes added to the envelope
nodiscrete=cell(1,Nmax);             % Initialize cell array of not-discrete nodes identified
i=1;                                  % Index for the while loop

while ~isempty(toAdd)
    Menvelope{1,i}=EBN.markovBlanket(toAdd); % Add Markov Blanket of nodes to add at the envelope
    added{1,i}=toAdd;                        % Record the nodes added
    
    % Identify not-discrete nodes in the envelope
    nodiscrete{1,i}=intersect([Menvelope{1,:}],EBN.ProbabilisticNodes);
    
    % Update cell of node names to add (not-discrete in the envelope not already added)
    toAdd=setdiff([nodiscrete{1,:}],[added{1,:}]);
    
    i=i+1;
end

% Reorder node names of the envelope
Cenvelope=intersect(EBN.NodesNames,[Menvelope{1,:}],'stable');

% Check if the number of discrete nodes in the ME overcome the maximum number suggested
Ndiscrete=length(intersect(Cenvelope,EBN.DiscreteNodes));

if Ndiscrete>=15  
    warning('openCOSSAN:EnhancedBayesianNetwork:defineMenvelope',...
        'The Markov Envelope should not contain more than 15-20 discrete variables. Please reconsider the structure of the net ');
end

end