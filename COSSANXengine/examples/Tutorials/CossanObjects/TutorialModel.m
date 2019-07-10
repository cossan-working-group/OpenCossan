%% Tutorial for the Model object 
% 
%
% The Model object defines the user defined model compoused by an Input
% object and an Evaluator object.
%
% See Also: https://cossan.co.uk/wiki/index.php/@Model
%
% $Copyright~1993-2019,~COSSAN~Working~Group$
% $Author:~Edoardo~Patelli$ 

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(56236)

%% Define Required object
%  user define model based on a Matlab function 
%
% Construct a Mio object
Xm=Mio( 'Sdescription', 'This is our Model', ...
    'Sscript','for j=1:length(Tinput), Toutput(j).out=-Tinput(j).RV1+Tinput(j).RV2; end', ...
    'Liostructure',true,...
    'Coutputnames',{'out'},...
    'Cinputnames',{'RV1','RV2'},...
    'Lfunction',false); % This flag specify if the .m file is a script or a function.
            
%% Construct the Evaluator
% First mode (The object are passed by reference) 
Xeval1 = Evaluator('Xmio',Xm,'Sdescription','fist Evaluator');

% In order to be able to construct our Model an Input object must be
% defined

%% Define an Input
% Define RVs
RV1=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);  %#ok<SNASGU>
RV2=RandomVariable('Sdistribution','normal', 'mean',0,'std',1);  %#ok<SNASGU>
% Define the RVset
Xrvs1=RandomVariableSet('Cmembers',{'RV1', 'RV2'}); 
% Define Xinput
Xin = Input('Sdescription','Input satellite_inp');
Xin  = Xin.add('Xmember',Xrvs1,'Sname','Xrvs1');
Xin = sample(Xin,'Nsamples',10);

%%  Construct the Model
Xmdl=Model('Cmembers',{'Xin','Xeval1'}); %#ok<NASGU>
% or
Xmdl=Model('Xinput',Xin,'Xevaluator',Xeval1,'Sdescription','The Model');

% Show Model details
display(Xmdl)

%% Perform Analysis
% Perform a deterministic Analysis
Xo1=Xmdl.deterministicAnalysis;

% The output contains only 1 values
display(Xo1)

% Perform simulation (using the samples present in the Input 
Xo2=Xmdl.apply(Xin);

% The output contains now 10 values (The samples defined in the input)
display(Xo2)

%% Validate Tutorial
MX=Xo2.getValues('Cnames',Xo2.Cnames);

Vreference=[ ...
    -8.091978556823285e-01    -4.151745464932572e-01     3.940233091890713e-01;
    -7.595250572281091e-01     2.308585423070265e+00     3.068110480298374e+00;
     7.831505638559783e-01    -4.655275078461927e-01    -1.248678071702171e+00;
    -1.204346453797460e-01    -3.208617659750095e-01    -2.004271205952635e-01;
    -9.341788238354498e-01    -9.351590937866989e-01    -9.802699512491131e-04;
    -2.681342527817951e-01     1.919650594995507e-01     4.600993122813458e-01;
     1.615179924353552e+00    -2.260762716518154e-01    -1.841256196005367e+00;
    -2.768288053623363e-01    -3.882282999633929e-01    -1.113994946010566e-01;
    -4.757549186442647e-02     1.541400652627784e+00     1.588976144492210e+00;
    -4.184300939342735e-01     6.438032534175224e-01     1.062233347351796e+00];
    
% Check solution
assert(max(max(Vreference-MX))<1e-14,'openCOSSAN:Tutorial','wrong results')

disp('Tutorial terminated successfully')

