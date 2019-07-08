%% Tutorial DatabaseDriver
%
% In this tutorial it is shown how to construct a DatabaseDriver and use it
% as Simulation Database. The conncetion to a SQLite database, that is a
% database contained in a single local file, is introduced in this
% tutorial.
% 
% Other databases supported by OpenCossan are MySQL and PostgreSQL, but it
% is required to have them installed and available on the network to
% connect to them.
%
%
% See Also: https://cossan.co.uk/wiki/index.php/@DatabaseDriver
%
% 
% Author: Matteo Broggi 

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%% Construct DatabaseDriver
% A connection to a database is initiated. The DatabaseDriver object is
% automatically added to the OpenCossan global settings and used in the
% simulation as a simulation database

Sdbpath = OpenCossan.getCossanWorkingPath;

% remove the old db file
delete(fullfile(Sdbpath,'cossanx.db'));

if ispc
    % Because of the way jdbc work, the database url must use "/" as path
    % separators. Thus, it is necessary to change all the "\" in the
    % Windows paths.
    Sdbpath = strrep(Sdbpath,'\','/');
end

Xdb = DatabaseDriver('Sdescription','SQLite database of simulations',...
    'SjdbcDriver','org.sqlite.JDBC',...  specify the name of the JDBC driver class
    'SdatabaseURL',['jdbc:sqlite:' Sdbpath],... JDBC URL of the database
    'SdatabaseName','cossanx.db',... name of the database (for SQLite, this is a filename)
    'SuserName','','Spassword',''... username and password (for SQLite this are ignored and are left empty)
    );

%% Basic methods of DatabaseDriver
% In this section, the basic methods of DatabaseDriver are shown. Please
% note that this methods are automatically called during the excution of
% analysis of of third-party solvers. They are listed here to show how to
% implement your own connection to the database of simulations.

%% Method createtable
% The method createTable is used to create tables used to store entries in
% the simulation database. These tables can either be of type "Analysis", 
% "Simulation" or "Solver". 
% The "Analysis" tables are used to store the results of an analysis, 
%  
% The "Simulation" tables store the input/output values of a Simulation
% method e.g., MonteCarlo, Latin Hypercube, etc., by saving the 
% SimulationData object returned at the end of the simulation (i.e., when
% the termination criterium is reached).
% The "Solver" tables store the input-output data used in each execution of
% the third party solver, as well as the folder containing the input and
% output files used in the execution.

% Create a table for the Analysis database
Xdb.createTable('StableName','testAnalysisDB',... name of the table
    'StableType','Analysis'... type of database
    );

% Create a table for the Solver database
Xdb.createTable('StableName','testSimulationDB',... name of the table
    'StableType','Simulation'... type of database
    );

% Create a table for the Solver database
Xdb.createTable('StableName','testSolverDB',... name of the table
    'StableType','Solver'... type of database
    );

%% Method tableExists
% This method check that the specified table have been correctly created.
% It returns true if the table exists.
Xdb.tableExists('testAnalysisDB')
Xdb.tableExists('testSimulationDB')
Xdb.tableExists('testSolverDB')

%% Method insertRecord
%% insert into Solver DB
% auxiliary data and files
XsimData = SimulationData('Cnames',{'a','b','c'},'Mvalues',[1,2,3]);
StestFolder = fullfile(OpenCossan.getCossanWorkingPath,'testDir');
mkdir(StestFolder);
fid = fopen(fullfile(StestFolder,'testfile.txt'),'w');
fprintf(fid,'Hello, World!'); fclose(fid);

% insert entry into DB
Xdb.insertRecord('Sdescription','test solver entry',...
    'StableType','Solver',...
    'StableName','testSolverDB',...
    'XsimulationData',XsimData,...
    'SsimulationFolder',StestFolder,...
    'Nsimulation',1,....
    'LsuccessfullExtract',true,...
    'LsuccessfullExecution',true);

%% insert into Simulation DB    
% auxiliary data
XsimData = SimulationData('Cnames',{'a','b','c'},'Mvalues',[1,2,3; 4,5,6; 7,8,9]);

% insert entry into DB
Xdb.insertRecord('Sdescription','test simulation entry',...
    'StableType','Simulation',...
    'StableName','testSimulationDB',...
    'XsimulationData',XsimData,...
    'NbatchNumber',1,....
    'CcossanObjects',{RandomVariable,Mio},...
    'CcossanObjectsNames',{'emptyRV','emptyMIO'});

%% insert into Analysis DB    
XanalyisOut = FailureProbability('pf',0.01,'variancepf',0.000001,...
    'Nsamples',10,'Smethod','UserDefined');

save(fullfile(OpenCossan.getCossanWorkingPath,'testmat.mat'),'XanalyisOut')

Xdb.insertRecord('Sdescription','test simulation entry',...
    'StableType','Analysis',...
    'StableName','testAnalysisDB',...
    'SanalysisMATFile',fullfile(OpenCossan.getCossanWorkingPath,'testmat.mat'));

% End of the Tutorial
