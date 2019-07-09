
%% A. Response surface creation
% create a response surface approximation of the non linear constraint that
% will be used in the optimization problem.

% Load the data obtained from the computation of the non-linear constraint 
% on a grid of design points (run create_calibration_points.m).
% The variables are:
%  - x1_grid: value of radius (normalized)
%  - x2_grid: value of thickness (normalized)
%  - mean_blgrid: mean of the buckling load
%  - std_blgrid: std of the buckling load
load results.mat

% Define the classical buckling load and the limit load
Fcl = 1.044e11/sqrt(3*(1-0.3^2))*2*pi*(x2_grid*1.1597e-4).^2; 
Flimit = 5000; % limit load

% compute the value of the non linear constraint for the points of the grid
zz = Flimit./Fcl - mean_blgrid + 8*std_blgrid;

%% 1. Create an input object with the relevant parameters
Xin = Xinput('Sdescription','input parameters of RS for Matteo');
Xradius  = parameters('Sdescription','Normalized radius','value',1);
Xin = add(Xin,Xradius);
Xthick  = parameters('Sdescription','Normalized thickness','value',1);
Xin = add(Xin,Xthick);

%% 2. Create response surface object
Xrs = Xrespsurface('Sdescription',...
    'response surface of six-sigma constraint',...
    'Stype','quadratic','Sresponse','zz','Xinput',Xin);

%% 3. Enter grid of points
Xrs = doe(Xrs,'Stype','userdefined','Xradius',x1_grid(:),'Xthick',x2_grid(:));

%% 4. Enter Value of RS
for i=1:numel(zz),
    TDOEout(i).zz  = zz(i);
end
Xrs = set(Xrs,'TDOEout',TDOEout);

%% 5. Calibrate response surface
Xrs = calibration(Xrs);

%% B. Optimizer definition and execution
%% 1. Constrain functiona
% define the non-linear constrain function
Xnlcons_fun = Xfunction('Sdescription','non-linear constraint function',...
    'Sexpression','apply(<&Xrs&>,struct(''Xradius'',<&Xradius&>,''Xthick'',<&Xthick&>))');
% define the side constraints on the design variables
Xside1_radius   = Xfunction('Sdescription','side constraint 1 of Xradius', ...
    'Sexpression','-<&Xradius&>+1');
Xside2_radius  = Xfunction('Sdescription','side constraint 2 of Xradius', ...
    'Sexpression','<&Xradius&>-5');
Xside1_thick  = Xfunction('Sdescription','side constraint 1 of Xthick', ...
    'Sexpression','-<&Xthick&>+1');
Xside2_thick  = Xfunction('Sdescription','side constraint 2 of Xthick', ...
    'Sexpression','<&Xthick&>-5');

weight=0:0.1:1;
for ii=1:length(weight)
    %% 2. define the objective function
    Xobj_fun = Xfunction('Sdescription','objective function','Sexpression',...
        [num2str(weight(ii)) '*<&Xradius&>*<&Xthick&> + '...
         num2str(1-weight(ii)) '*<&Xradius&>^2']);
    
    %% 3. Define initial solution guess
    Xinisol     = parameters('Sdescription','initial solution','value',[1 1]);
    
    %% 4.   Create object Xoptprob
    Xop = Xoptimizationproblem;     % create empty optimization problem
    Xop = add(Xop,'Sdescription','Optimization problem','Xinput',Xin,...
        'Cdesvar',{'Xradius','Xthick'});
    Xop = add(Xop,'Xfunction_objectivefunction',Xobj_fun,'Xfunction_inequalityconstraint',Xnlcons_fun,...
        'Xfunction_inequalityconstraint',Xside1_radius,'Xfunction_inequalityconstraint',Xside2_radius,...
        'Xfunction_inequalityconstraint',Xside1_thick,'Xfunction_inequalityconstraint',Xside2_thick,...
        'Xparameter_initialsolution',Xinisol);
    
    %% 5.   Create object Xcobyla
    Xcob = Xcobyla();
    
    %% 6.   Solve optimization problem
    Tout(ii) = apply(Xcob,Xop);
    display(['Weight = ' num2str(weight(ii)) ', Optimum = ['  num2str(Tout(ii).Vx_opt) ']' ]);
end