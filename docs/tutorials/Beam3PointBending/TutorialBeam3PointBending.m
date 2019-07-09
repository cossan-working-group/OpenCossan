%% Tutorial Beam 3 Point Bending 
% This tutorial example considers a beam in three points bending.
%
%                        | Load
%                       \|/
%  --------------------------------------------
%  /\                                         /\
% ====                                        oo 
%                                            =====  
% 
% The displacements are blocked in all the direction at one of the extremity of the beam 
% (however, rotation is possible). The other extremity can move freely in 
% the horizontal direction.
% 
% The beam is assumed to have a rectangular cross section. The length L of 
% the beam is 100mm, a force is applied at 25mm from an extremity.
% The quantity of interest is the displacement (in the  vertical direction)
% at the middle of the beam.
%
% This example  will be studied using several third-party software and various
% toolboxes of COSSAN-X.   
% 
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/Beam_3-point_bending_(overview)
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Pierre~Beaurepaire$ 


%% Select the solver
% The model is analysed using either a Matlab script or using a third party finite element software
% (Nastran, Abaqus and Ansys)
% 
%% Matlab solver:
%
% echodemo TutorialBeam3PointBendingMatlab
%
%% ANSYS solver
%
% echodemo TutorialBeam3PointBendingAnsys
%
%% NASTRAN solver:
%
% echodemo TutorialBeam3PointBendingNastran
%
%% ABAQUS solver
%
% echodemo TutorialBeam3PointBendingAbaqus

%% Perform Reliability Analysis
% Finally the tutorial performs reliability analysis of the defined model.  Both
% the uncertainty quantification and the reliability analysis can be executed on
% the grid using High Performace Computing  
%
% echodemo TutorialBeam3PointBendingPerformReliabilityAnalysis
