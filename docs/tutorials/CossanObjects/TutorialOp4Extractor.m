%% Tutorial for Op4Extractor.
%
% tutorial on the use of op4 extractor
% example on how to transfer the data from op4 format files
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@Op4Extractor
%

%  Copyright 1993-2011, COSSAN Working Group
%  University of Innsbruck, Austria
clear
close all
clc;
%% Create op4Extractor object
SpathName=fullfile(opencossan.OpenCossan.getRoot,'examples','Tutorials','CossanObjects','Connector','NASTRAN');
% define the name of the file & path of the file & the variable name to be stored
Xextractor = opencossan.workers.ascii.Op4Extractor('Sfile','BEAM1_K_0.OP4','Sworkingdirectory',SpathName,...
        'Srelativepath','./','Soutputname','stiffness');
display(Xextractor)
% Test extract method of the Op4Extractor object
Tout  = extract(Xextractor);

% Validate output

Vreference= -4.5247e+02;
assert(abs(Tout.stiffness(42,45)-Vreference)<1e-4,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')



Xextractor = Op4Extractor('Sfile','BEAM1_U_0.OP4','Sworkingdirectory',SpathName, ...
    'Srelativepath','./','Soutputname','displacements');
Tout  = extract(Xextractor);

% Validate output

Vreference= 1.1272e+01;
assert(abs(Tout.displacements(5)-Vreference)<1e-4,...
    'CossanX:Tutorials:TutorialEvaluator','Reference Solution does not match.')

