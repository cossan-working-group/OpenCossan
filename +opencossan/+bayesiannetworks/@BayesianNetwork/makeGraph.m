function makeGraph(BN)
% MAKEGRAPH method of the class ENHANCEDBAYESIANNETWORK provide the
% graphical representation of the network
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
v=ver;
assert(any(strcmp('Bioinformatics Toolbox', {v.Name})),...
                'openCOSSAN:bayesiannetworks:BayesianNetwork',...
                'To visualize the eBN graph the Bioinformatics Toolbox has to be installed ')
 
%% build the node objects
if length(BN.NodesNames)==1 
    graphObj = biograph(1,BN.NodesNames,'EdgeType','curved');%,'FontSize',90);
    set(graphObj.nodes,'Shape','rectangle','Color',[0.5, 0.69, 0.5],'LineColor',[0.5, 0.69, 0.5],'FontSize',20);
elseif length(BN.NodesNames)>1
    graphObj = biograph(BN.DAG,cellstr(BN.NodesNames),'EdgeType','curved');%,'ArrowSize',90);
    set(graphObj,'LayoutScale',1);
    set(graphObj,'NodeAutoSize','on');
    set(graphObj.nodes,'Shape','rectangle','Color',[0.5, 0.69, 0.5],'LineColor',[0.5, 0.69, 0.5]);
    BN.setNode4Graph(graphObj)
end
dolayout(graphObj);
view(graphObj);
end

