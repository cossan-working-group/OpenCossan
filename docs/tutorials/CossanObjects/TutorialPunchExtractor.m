%% Tutorial for the PunchExtractor class
%
% PunchExtractor tutorial
% Please refer to the specific tutorials for the other objects available in
% [COSSANEngine/examples/Tutorials]
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@PunchExtractor
%
%
%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
clear
close all;
clc;
%% Using PunchExtractor
%
% PunchExtractor is a class specifically programmed in order to read
% DOF info from NASTRAN (in NASTRAN the dof info can be output in this format)
% NOTE: punch files have the .pch extension 

Sdirectory = fullfile(opencossan.OpenCossan.getRoot,'examples','Unit_test','Connectors','PunchExtractor');

Xpch = opencossan.workers.ascii.PunchExtractor('Sdescription', 'PunchExtractor Tutorial',...
                      'Sfile','BEAM1_DOFS.PCH','Sworkingdirectory',Sdirectory,....
                      'Soutputname','dofs');

Tout = extract(Xpch);

% observe that the DOF info is stored in a matrix with two columns:
% first column   = Node ID
% second columns = DOF no
display(Tout);
display(Tout.dofs(1:12,:));

% validate the results
Vreference=[2 1;2 2;2 3;2 5;2 6];
assert(max(abs(double(Tout.dofs(2,:))-double(Vreference(2,:))))<1e-6,...
   'CossanX:Tutorials:TutorialPunchExtractor','Reference Solution does not match.')

assert(max(abs(double(Tout.dofs(4,:))-double(Vreference(4,:))))<1e-6,...
   'CossanX:Tutorials:TutorialPunchExtractor','Reference Solution does not match.')
