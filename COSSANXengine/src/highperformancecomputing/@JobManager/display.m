function display(Xobj)
%DISPLAY  Displays the object JobManager
%
% ==================================================================
% COSSAN-X - The next generation of the computational stochastic analysis
% University of Innsbruck, Copyright 1993-2011 IfM
% ==================================================================

%% Output to Screen
%  Name and description
OpenCossan.cossanDisp('===================================================================',3);
OpenCossan.cossanDisp([' JobManager Object - ' Xobj.Sdescription ],1);
OpenCossan.cossanDisp('===================================================================',3);

% main paramenters
OpenCossan.cossanDisp(['Queue: ' Xobj.Squeue],2);
OpenCossan.cossanDisp(['Hostnanme: ' Xobj.Shostname],2);

OpenCossan.cossanDisp(['Folder Name: ' Xobj.Sfoldername],3);
OpenCossan.cossanDisp(['Max Concurrent simulation: ' num2str(Xobj.Nconcurrent)],3);
