%% Tutorial AntennaTower
%
% The structure of interest is a suspension arm similar to those used in the
% automotive industry.
% The structure is embedded at the two ends with coaxial cylindrical shape.
% A load of 70kN is applied at the third end of the component. 
% The design variables monitor the radius and the location of the centre of 
% the hollow sections in the web of the structure. These hollow section modify
% the total weight of the structure, but also the stress in the cross section.
%
% The hollow section have a cylindrical shape, their axis is oriented 
% according to the z-direction. Each cylinder is characterized by two 
% parameters: the location of intersection of its axis with the central curve
% of the web, and its radius. In total, three hollow sections are introduced
% into the part, and hence the optimization problem is of dimension six.
% 
% The value of the design variables are used in the input file of a preprocessing
% software in order to generate the geometry of the part. Parametric optimization
% is performed in this example, i.e. the geometry of the structure is modified
% at each iteration of the procedure.
%
% The optimization problem consists of minimizing the weight of the component,
% while ensuring that the maximum Von Mises stress does not exceed 850MPa.
% Additional constraints are used to guarantee that the hollow sections do
% not cut the flanges of the structure, and that the distance between two
% neighbouring hollow sections is greater than 10mm.
%
% In order to improve the accuracy of the solution, the mesh is refined in
% the vicinity of the hollow sections, where the Von Mises stress is maximal.
%
% The units used in this example are millimeter, Newton, Ton.
%
%
%
% Literature review and initial implementation by MAV. Implementation and
% parametrization of a 3D finite element model by PB.
%
% See Also http://cossan.co.uk/wiki/index.php/Suspension_Arm

%  Copyright 1993-2012, COSSAN Working Group
%  University of Innsbruck, Austria

%% TODO:
% % Retrieve the directory where this tutorial is stored
StutorialPath = fileparts(which('SuspensionArm.m'));  


%% Path to the installation of the precompiled version of code aster (SalomeMeca)
% IMPORTANT: this needs to be adapted to the installation of SalomeMeca
SsalomeMecaHome = '/opt/SALOME-MECA-2012.1-LGPL/';


%% Inputs
% Definition of the design variables
% Each of the hollow sections is defined by its coordinate on the centre
% line of the web and by its radius
Abscissa1 = DesignVariable('value',50,'lowerbound',20,'upperbound',410);
NormalizedRadius1 = DesignVariable('value',100,'lowerbound',5,'upperbound',300);
Abscissa2 = DesignVariable('value',50,'lowerbound',20,'upperbound',410);
NormalizedRadius2 = DesignVariable('value',100,'lowerbound',5,'upperbound',300);
Abscissa3 = DesignVariable('value',50,'lowerbound',20,'upperbound',410);
NormalizedRadius3 = DesignVariable('value',100,'lowerbound',5,'upperbound',300);

%  Parameter defining the maximum admissible stress
MaximumAdmissibleStress = Parameter('value',850);

% Add all the input quantities to an Input object
Xin = Input('CSmembers',{'Abscissa1','NormalizedRadius1','Abscissa2','NormalizedRadius2','Abscissa3','NormalizedRadius3','MaximumAdmissibleStress'},...
    'CXmembers',{Abscissa1,NormalizedRadius1,Abscissa2,NormalizedRadius2,Abscissa3,NormalizedRadius3,MaximumAdmissibleStress});


%% creation of a Matlab function (Mio)
% this function computes (i) the actual coordinates of the center of each
% hole (used for the connection with the 3rd party software); (ii) the 
% distance between each hole and the nearest flange (used in the definition
% of the constraints); (iii) the distance between eaxh pair of holes (used in
% the definition of the constraints)

Xmio  = Mio('Sdescription', 'pre-processing script', ...
    'Spath',StutorialPath, ...                % path to the m-file
    'Sfile','preprocessing.m', ...  % name of the file
    'Liostructure',true,... % This flag specify the type of I/O
    'Liomatrix',false, ...  
    'Coutputnames',{'ActualRadius1','XcoorCentre1','YcoorCentre1','ActualRadius2','XcoorCentre2','YcoorCentre2','ActualRadius3','XcoorCentre3','YcoorCentre3',... % 
    'DistanceHoleEdge1','DistanceHoleEdge2','DistanceHoleEdge3','DistanceHoleHole12','DistanceHoleHole13','DistanceHoleHole23',},... % name of the outputs
    'Cinputnames',Xin.Cnames,...  % name of the inputs
    'Lfunction',true); % This flag specify if the .m file is a function.

%% connection with the third party software
% in this example, the input quantities are injected in the python script
% used with the preprocessing software

% definition of the injector to the parametric input file
Xinj = Injector('Stype','scan', ....
    'Sscanfilepath', StutorialPath,...
    'Sscanfilename', 'generate_mesh.cossan',...
    'Sfile','generate_mesh.py');

% definition of the response related to the maximum stress in the structure
XrespVmises = Response('Sname', 'maximumVonMises', ... % name of the response
    'Sfieldformat', '%f', ... % format of repetive pattern
    'Clookoutfor',{' LA VALEUR MAXIMALE DE VMIS '}, ... % search string
    'Ncolnum',37, ... % column difference relative to Clookoutfor
    'Nrownum',0); % row difference relative to Clookoutfor

% definition of the extractor related to the maximum stress in the structure
XextVmises = Extractor('Srelativepath','./', ...   % relative path to the Sworkingdirectory where result file is located
    'Sfile','suspension_arm.resu', ...             % file where the quantity is writen
    'Xresponse', XrespVmises);                     % name of the response object

% definition of the response related to the mass of the structure
XrespMass = Response('Sname', 'Mass', ...  % relative path to the Sworkingdirectory where result file is located
    'Sfieldformat', '%f', ... % format of repetive pattern
    'Clookoutfor',{' LIEU     ENTITE   MASSE        CDG_X      '}, ... % search string
    'Ncolnum',21, ... % column difference relative to Clookoutfor
    'Nrownum',1); % row difference relative to Clookoutfor

% definition of the extractor related to the mass of the structure
XextMass = Extractor('Srelativepath','./', ...        % relative path to the Sworkingdirectory where result file is located
    'Sfile','suspension_arm.resu', ...
    'Xresponse', XrespMass);



% construction of the connector
Xc = Connector('Sdescription', 'connector to code aster with pre and post execution commands',...
    'Smaininputpath',StutorialPath,...
    'Smaininputfile','suspension_arm_ini.export',...   % input file of the FE code
    'Sworkingdirectory', '/tmp' ,...                   % the working directory is not a key issue as SalomeMeca is working on /tmp/
    'Ssolverbinary',[SsalomeMecaHome 'aster/bin/as_run'], ... 
    'Sexecmd','%Ssolverbinary %Smaininputfile',....
    'Caddfiles',{'command_file.comm','Part_wo_hole.step'},...% files required to perform the simulation
    'Lkeepsimulationfiles',true,...
    'SpreExecutionCommand',[SsalomeMecaHome 'appli/runSalomeScript generate_mesh.py'],... % pre execution command: the geometry and the mesh are created
    'Spostexecutioncommand','rm *.med; rm I0* -fR; rm Part_wo_hole.step',...         % post execution command: uncessary files are deleted
    'CXmembers',{XextVmises XextMass Xinj}); % objects included in the Connector




%% model and evaluator

% Creation of the evaluator containing the preprocessing mio and the
% connector to the 3rd party software
Xev = Evaluator('CXmembers',{Xmio,Xc});

% creation of the  model
Xmdl=Model('Xevaluator',Xev,'Xinput',Xin);


%% Definition of the objective function
XobjectiveFunction   = ObjectiveFunction('Sdescription','objective function', ...
    'Sscript','for n=1:length(Toutput), Toutput(n).fobj=Tinput(n).Mass; end',...
    'Cinputnames',{'Mass'},...
    'Coutputnames',{'fobj'});


%% Create inequality constraint
% The constraints are fulfilled as long as the value of the functions is <=0

% the stress in the structure must be less than the value of the parameter
% maximumVonMises defined previously
XconstraintStress   = Constraint( 'Sscript','for n=1:length(Tinput),Toutput(n).constraintStress=Tinput(n).maximumVonMises-Tinput(n).MaximumAdmissibleStress;end',...
    'Coutputnames',{'constraintStress'},'Cinputnames',{'maximumVonMises','MaximumAdmissibleStress'},'Linequality',true);

% The hollow sections should not intercept the flanges
XconstraintDistanceHoleEdge1   = Constraint(...
    'Sscript','for n=1:length(Tinput),Toutput(n).constraintDistanceHoleEdge1=Tinput(n).NormalizedRadius1/10-Tinput(n).DistanceHoleEdge1;end',...
    'Coutputnames',{'constraintDistanceHoleEdge1'},...
    'Cinputnames',{'DistanceHoleEdge1','NormalizedRadius1'},'Linequality',true);
XconstraintDistanceHoleEdge2   = Constraint( ...
    'Sscript','for n=1:length(Tinput),Toutput(n).constraintDistanceHoleEdge2=Tinput(n).NormalizedRadius2/10-Tinput(n).DistanceHoleEdge2;end',...
    'Coutputnames',{'constraintDistanceHoleEdge2'},...
    'Cinputnames',{'DistanceHoleEdge2','NormalizedRadius2'},'Linequality',true);
XconstraintDistanceHoleEdge3   = Constraint(...
    'Sscript','for n=1:length(Tinput),Toutput(n).constraintDistanceHoleEdge3=Tinput(n).NormalizedRadius3/10-Tinput(n).DistanceHoleEdge3,end',...
    'Coutputnames',{'constraintDistanceHoleEdge3'},...
    'Cinputnames',{'DistanceHoleEdge3','NormalizedRadius3'},'Linequality',true);

% The distance between two adjacent holes should be above a given threshold
XconstraintDistanceHoleHole12   = Constraint(...
    'Sscript','for n=1:length(Tinput),Toutput(n).constraintDistanceHoleHole12=-Tinput(n).DistanceHoleHole12;end',...
    'Coutputnames',{'constraintDistanceHoleHole12'},...
    'Cinputnames',{'DistanceHoleHole12'},'Linequality',true);
XconstraintDistanceHoleHole13   = Constraint( ...
    'Sscript','for n=1:length(Tinput),Toutput(n).constraintDistanceHoleHole13=-Tinput(n).DistanceHoleHole13;end',...
    'Coutputnames',{'constraintDistanceHoleHole13'},...
    'Cinputnames',{'DistanceHoleHole13'},'Linequality',true);
XconstraintDistanceHoleHole23   = Constraint(...
    'Sscript','for n=1:length(Tinput),Toutput(n).constraintDistanceHoleHole23=-Tinput(n).DistanceHoleHole23;end',...
    'Coutputnames',{'constraintDistanceHoleHole23'},...
    'Cinputnames',{'DistanceHoleHole23'},'Linequality',true);

%% define the optimizator problem
Xop     = OptimizationProblem('Xmodel',Xmdl, ...
    'VinitialSolution',[75 100 200 100 325 100], ... % initial value of the design variables
    'XobjectiveFunction',XobjectiveFunction,...
    'CXconstraint',{XconstraintStress,XconstraintDistanceHoleEdge1,XconstraintDistanceHoleEdge2,XconstraintDistanceHoleEdge3,...
   XconstraintDistanceHoleHole12, XconstraintDistanceHoleHole13,XconstraintDistanceHoleHole23});

% selection of the optimization algorithm
Xcob    = Cobyla('initialTrustRegion',75,'Nmaxiterations',245,'finalTrustRegion',1.5,'scalingFactor',.1);

% perform the analysis
Xoptimum=Xop.optimize('Xoptimizer',Xcob);


display(Xoptimum)