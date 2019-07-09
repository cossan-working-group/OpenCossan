%% TUTORIALFaultTree
% the FaultTree object define the logic of the SystemReliability model
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@FaultTree
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author: Edoardo-Patelli$ 

clear
close all
clc;
%% Create FaultTree
% To create a FaultTree object it is necessary to define 3 different
% components: nodeTypes nodeNames and nodeConnection. These
% components are defined by means of Cell arrays and a vector of connection
%
CnodeTypes={'Output','AND','Input','OR','Input','AND','Input','AND','Input','Input'};
CnodeNames={'TopEvent','AND gate 1','C','OR gate 1','A','AND gate 2','B','AND gate 3','B','D'};
VnodeConnections=[0 1 2 2 4 4 6 6 8 8];


Xft=opencossan.reliability.FaultTree('CnodeTypes',CnodeTypes,'CnodeNames',CnodeNames,...
               'VnodeConnections',VnodeConnections,'Sdescription','FaultTree object');
           
% Show FaultTree in the console
display(Xft)

% Graphical representation of the FaultTree
Xft.plotTree('Stitle','test plot')

% Find cut-sets
Xft=Xft.findCutSets;
display(Xft)

% Find minimal cut-sets
Xft=Xft.findMinimalCutSets;
display(Xft)

% The method findMinimalCutSets can be also used to reduce arbitrary
% cut-sets 

Mcutsets=Xft.McutSets;
% add 2 cutsets
Mcutsets(:,3)=Mcutsets(:,1);
Mcutsets(:,4)=Mcutsets(:,2);
Mcutsets(1,4)=1;

[~, CminimalCutSet]=Xft.findMinimalCutSets('mcutsets',Mcutsets);
% Show cut-sets
disp(CminimalCutSet)

% Remove nodes
% Be carefull when you use this function. You can destroy completely the
% structure of the FaultTree

Xft=Xft.removeNodes('VnodeIndex',[8 9 10]);

Xft.plotTree('Stitle','test plot')

% Add nodes
Xft=Xft.addNodes('CnodeTypes',CnodeTypes([8 9 10]),...
                 'CnodeNames',CnodeNames([8 9 10]),...
                 'VnodeConnections',VnodeConnections([8 9 10]));
             
% Now the FaultTree should be exactly as the origianal but without the
% cutsets.
display(Xft)

Xft=Xft.findMinimalCutSets;

display(Xft)
