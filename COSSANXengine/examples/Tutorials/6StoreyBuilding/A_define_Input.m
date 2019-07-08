%
% Building under wind loading - Input definition
%
% In this example, the variation of the stresses of a structural model with
% random model parameters are computed by means of MonteCarlo simulation.
%
% The structural model comprises a 6-story building under a lateral wind 
% excitation. The load is modeled with deterministic constant forces acting 
% on a side of the building, with the pressure of the wind, and thus the
% acting force, increasing as the height of the building according to a 
% power increase.
% The material and geometric parameters of the columns, stairs ceiling and 
% floors of the building are modeled with independent random variables.
% 500 MonteCarlo simulations are carried out. 
%
% =========================================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2009 IfM
% =========================================================================

%% Initialization
% remove variables from the workspace and clear the console
clear variables
clc

OpenCossan.setVerbosityLevel(3)
OpenCossan.resetRandomNumberGenerator(1);

%% 2. Input definition
% In this sections, the geometric and material properties of the columns,
% floors and ceiling of the building are defined as independent random
% variables.

%% Associate Random variables to the cross section of the colums 
% Create the section of the square column as a uniform distibuted random
% variable between 0.36 m and 0.44 m. rv_section is an auxiliary
% RandomVaraible object used to create the RandomVariableSet of the
% sections of the columns

rv_section = RandomVariable('Sdistribution','uniform','parameter1',0.36,'parameter2',0.44);

% Xrv_sections is an array of random variables used to create the 
% RandomVariableSet object. All the random variables of the set are
% identically distributed, with the distribution defined in the
% RandomVariable rv_section object.
Xrv_sections = rv_section;

for i=1:6 % number of floor
    for j=1:16 %number of column
        % Cmem_sections is a cell array containing the name of the random
        % variables. The random variables describes the X section of the 
        % columns of each floor. The names are dinamically created as 
        % sectionX_Col<number>_Floor_<number>, for each of the 6 floors and
        % of the 16  columns per floor.
        Cmem_sections{(i-1)*16+j}=['sectionX_Col' int2str(j) '_Floor_' int2str(i)]; %#ok<SAGROW>
        Xrv_sections((i-1)*16+j) = rv_section;
    end
end

for i=1:6 % number of floor
    for j=1:16 %number of column
        % The same procedure is adopted to create the random variables that
        % describe the Y section of the columns.
        Cmem_sections{96+(i-1)*16+j}=['sectionY_Col' int2str(j) '_Floor_' int2str(i)]; %#ok<SAGROW>
        Xrv_sections(96+(i-1)*16+j) = rv_section;
    end
end

% The RandomVariableSet of the sections of the columns is created.
% Cmem_sections contains the names of the random variables, and
% Xrv_sections the array of identically distributed RandomVariable objects.
% A total number of 192 random variables are contained in the set.

Xrvset_Sections = RandomVariableSet('Cmembers',Cmem_sections,'Xrv',Xrv_sections); %#ok<SNASGU>

%% Associate Random variables to the Youngs modulus of the colums 
% Create the Youngs modulus of the columns, the floors, the stairs and the 
% ceiling as a lognormal distibuted random variable with mean 3.5e10 Pa and 
% coefficient of variation of 0.1. 

rv_Youngs = RandomVariable('Sdistribution','lognormal','mean',3.5e10,'cov',0.1);

% Xrv_Youngs is an array of random variables used to create the 
% RandomVariableSet object. All the random variables of the set are
% identically distributed, with the distribution defined in the
% RandomVariable rv_Youngs object.
Xrv_Youngs = rv_Youngs;

for i=1:6
    % The columns of each floor have the same Youngs modulus. The name of
    % the random variable describing the Youngs modulus of the columns is
    % dinamically created as Youngs_Cols_Floor_<number>, for each of the 6
    % floors.
    Cmem_Youngs{i}=['Youngs_Cols_Floor_' int2str(i)]; %#ok<SAGROW>
    Xrv_Youngs(i) = rv_Youngs;
end
for i=1:6
    % The name of the random variable describing the Youngs modulus of the 
    % floors is dinamically created as Youngs_Floor_<number>, for each of 
    % the 6 floors.
    Cmem_Youngs{6+i}=['Youngs_Floor_' int2str(i)]; %#ok<SAGROW>
    Xrv_Youngs(6+i) = rv_Youngs;
end
for i=1:6
    % The name of the random variable describing the Youngs modulus of the 
    % stairs is dinamically created as Youngs_Stairs_<number>, for each of 
    % the 6 floors.
    Cmem_Youngs{12+i}=['Youngs_Stairs_' int2str(i)]; %#ok<SAGROW>
    Xrv_Youngs(12+i) = rv_Youngs;
end
% Finally, the Youngs modulus of the ceiling is added.
Cmem_Youngs{19} = 'Youngs_Stairs_ceil';
Xrv_Youngs(19) = rv_Youngs;

% The RandomVariableSet of all the Youngs moduli is created. Cmem_Youngs 
% contains the names of the random variables, and  Xrv_Youngs is the array 
% of identically distributed RandomVariable objects.
% A total number of 19 random variables are contained in the set.
Xrvset_Youngs = RandomVariableSet('Cmembers',Cmem_Youngs,'Xrv',Xrv_Youngs); %#ok<SNASGU>


%% Associate Random variables to the density of the colums 
% Create the density  of the columns, the floors, the stairs and the ceiling 
% as a lognormal distibuted random variable with mean 2500 Kg/m^3 and 
% coefficient of variation of 0.1. 

rv_Density = RandomVariable('Sdistribution','lognormal','mean',2500,'cov',0.1);
Xrv_Density = rv_Density;

for i=1:6
    % The columns of each floor have the same density. The name of the 
    % random variable describing the Youngs modulus of the columns is
    % dinamically created as Density_Cols_Floor_<number>, for each of the 6
    % floors.
    Cmem_Density{i}=['Density_Cols_Floor_' int2str(i)]; %#ok<SAGROW>
    Xrv_Density(i) = rv_Density;
end
for i=1:6
    % The name of the random variable describing the density of the floors 
    % is dinamically created as Density_Floor_<number>, for each of the 6 
    % floors.
    Cmem_Density{6+i}=['Density_Floor_' int2str(i)]; %#ok<SAGROW>
    Xrv_Density(6+i) = rv_Density;
end
for i=1:6
    % The name of the random variable describing the density of the stairs 
    % is dinamically created as Youngs_Stairs_<number>, for each of the 6 
    % floors.
    Cmem_Density{12+i}=['Density_Stairs_' int2str(i)]; %#ok<SAGROW>
    Xrv_Density(12+i) = rv_Density;
end
% Finally, the density of the ceiling is added.
Cmem_Density{19} = 'Density_Stairs_ceil';
Xrv_Density(19) = rv_Density;

% The RandomVariableSet of all the densities is created. Cmem_Density 
% contains the names of the random variables, and  Xrv_Density is the array 
% of identically distributed RandomVariable objects.
% A total number of 19 random variables are contained in the set.

Xrvset_Density = RandomVariableSet('Cmembers',Cmem_Density,'Xrv',Xrv_Density); %#ok<SNASGU>


%% Associate Random variables to the shear modulus of the colums 
% Create the shear modulus of the columns of each floor as a lognormal
% distibuted random variable with mean 1.4e10 Pa and coefficient of 
% variation of 0.1. 
% The shear modulus is defined because the FE solver used
% (ABAQUS) does not allow the definition of Poisson modulus for beam
% elements, used to model the columns of the building.
% TODO: improve above sentence... it is not so clear 

rv_Shear = RandomVariable('Sdistribution','lognormal','mean',1.4e10,'cov',0.1);
Xrv_Shear = rv_Shear;
for i=1:6
    % The columns of each floor have the same shear modulus. The name of
    % the random variable describing the sher modulus of the columns is
    % dinamically created as Shear_Cols_Floor_<number>, for each of the 6
    % floors.
    Cmem_Shear{i}=['Shear_Cols_Floor_' int2str(i)]; %#ok<SAGROW>
    Xrv_Shear(i) = rv_Shear;
end

% The RandomVariableSet of all the shear moduli is created. Cmem_Shear 
% contains the names of the random variables, and  Xrv_Shear is the array 
% of identically distributed RandomVariable objects.
% A total number of 6 random variables are contained in the set.
Xrvset_Shear = RandomVariableSet('Cmembers',Cmem_Shear,'Xrv',Xrv_Shear); %#ok<SNASGU>


%% Associate Random variables to the Poisson modulus of the floors and
%% stairs
% Create the Poisson modulus of the floors, the stairs and the ceiling as a
% lognormal distibuted random variable with mean 0.25 and coefficient of 
% variation of 0.1. 

rv_Poisson = RandomVariable('Sdistribution','lognormal','mean',0.25,'cov',0.1);

% Xrv_Poisson is an array of random variables used to create the 
% RandomVariableSet object. All the random variables of the set are
% identically distributed, with the distribution defined in the
% RandomVariable rv_Poisson object.
Xrv_Poisson = rv_Poisson;
for i=1:6
    % The name of the random variable describing the Poisson modulus of the 
    % floors is dinamically created as Poisson_Floor_<number>, for each of 
    % the 6 floors.
    Cmem_Poisson{i}=['Poisson_Floor_' int2str(i)]; %#ok<SAGROW>
    Xrv_Poisson(i) = rv_Poisson;
end
for i=1:6
    % The name of the random variable describing the Poisson modulus of the 
    % stairs is dinamically created as Poisson_Stairs_<number>, for each of 
    % the 6 floors.
    Cmem_Poisson{6+i}=['Poisson_Stairs_' int2str(i)]; %#ok<SAGROW>
    Xrv_Poisson(6+i) = rv_Poisson;
end
% Finally, the Poisson modulus of the ceiling is added.
Cmem_Poisson{13} = 'Poisson_Stairs_ceil';
Xrv_Poisson(13) = rv_Poisson;

% The RandomVariableSet of all the Poisson moduli is created. Cmem_Poisson 
% contains the names of the random variables, and  Xrv_Poisson is the array 
% of identically distributed RandomVariable objects.
% A total number of 13 random variables are contained in the set.

Xrvset_Poisson = RandomVariableSet('Cmembers',Cmem_Poisson,'Xrv',Xrv_Poisson); %#ok<SNASGU>

%% Define a Input object that contains all the random quantities
% All the RandomVariableSet objects are added to an Input object. In total,
% 249 random variables have been defined.
Xinp=Input('CSmembers', ...
    {'Xrvset_Sections','Xrvset_Youngs', 'Xrvset_Density', 'Xrvset_Shear','Xrvset_Poisson'},...
    'CXmembers', ...
    {Xrvset_Sections,Xrvset_Youngs, Xrvset_Density, Xrvset_Shear,Xrvset_Poisson});

%% Parameter used to define threshold value of the performance function
Xpar=Parameter('value',1e6);
Xinp=Xinp.add(Xpar);
% Show summary of the Input object

display(Xinp)
% save the Input object in a .mat file, in order to be reused for other 
% simulations.
save('Xinput_Building','Xinp')

