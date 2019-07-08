%*********************************************************************
%
%   Example on how to use Fatigue and Fracture objects
%
%
%   This tutorial shows the usage of the methods in the class
%   FatigueFracture. 
%
%   The propagation of an edge crack in a semi-infinite plate is
%   investigated
%
%**************************************************************************
OpenCossan.setVerbosityLevel(1)
%% Definition of inputs

Xin  = Input();

% Initial length of the cracks
a=Parameter('value',1e-3);
Xin = Xin.add('Xmember',a,'Sname','a');

% Coefficient C in Paris equation
C=Parameter('value',2.5e-23);
Xin = Xin.add('Xmember',C,'Sname','C');

% Fracture toughness
Kic=Parameter('value',3e7);
Xin = Xin.add('Xmember',Kic,'Sname','Kic');

% Coefficient m in Paris equation
m=Parameter('value',2);
Xin = Xin.add('Xmember',m,'Sname','m');

% Maximum applied stress
smax=Parameter('value',100e6);
Xin = Xin.add('Xmember',smax,'Sname','smax');

% Minimum applied stress is zero and not defined here

%% Data related to FatigueFracture object
% definition of an Evaluator. This is the ''main'' input of the 
% FatigueFracture object. It estimates the maximum value of stress
% intensity factor and its variation over one cycle
Sscript1 = [...
'Cdummy=num2cell(zeros(length(Tinput),1));'...
'Toutput=struct(''sif'',Cdummy);'...
'for i=1:length(Tinput),'...
'smax = Tinput(i).smax;'...
'a = Tinput(i).a;'...
'Toutput(i).sif   = 1.12 * smax * sqrt(pi*a);'...
'end'...
];

Xm  = Mio('Liostructure',true,'Liomatrix',false,...
    'Cinputnames',{'a'},... % Define the inputs
    'Sscript',Sscript1,... % external file
    'Coutputnames',{'sif'}); % Define the outputs
Xe      = Evaluator('Xmio',Xm);     % Define the evaluator

% Definition of the CrackGrowth object. It takes as an inpout the outputs
% of the evaluator which determines the stress intensity factor, The
% outputs of this objects are the variations of the crack length over one
% cycle

Sscript2 = [...
'Cdummy=num2cell(zeros(length(Tinput),1));'...
'Toutput=struct(''dadn'',Cdummy);'...
'for i=1:length(Tinput),   Toutput(i).dadn = Tinput.C*(Tinput(i).sif)^ Tinput(i).m;end'...
];

Xcg = CrackGrowth('Liostructure',true,'Liomatrix',false,...
    'Cinputnames',{'sif','m','C'},... % Define the inputs
    'Sscript',Sscript2,... % external file
    'Coutputnames',{'dadn'});

% Definition of the Fracture object. It takes as an inpout the outputs
% of the evaluator which determines the stress intensity factor, The
% outputs of this is <0 if fracture does not occur, and >0 if fracture has
% occured
Xf = Fracture('Liomatrix',false,...
    'Cinputnames',{'sif','Kic'},... % Define the inputs
    'Spath',[OpenCossan.getCossanRoot '/examples/Tutorials/FatigueFracture/'],...
    'Sscript','for j=1:length(Tinput), Toutput(j).fract= Tinput(j).sif-Tinput(j).Kic; end', ...
    'Coutputnames',{'fract'},...
    'Liostructure',true,...
    'Lfunction',false);

% Defining the FatigueFracture object
Xff = FatigueFracture('Xevaluator',Xe,'Ccrack',{'a'},...
    'Xcrackgrowth',Xcg ,'Xfracture',Xf,'Cinputnames',Xin.Cnames); % Fracture

% execution of the problem
[Xo,Xffo] =Xff.apply( Xin.getStructure);

%% reference solution

Ref = 1/(1.12^2*2.5e-23*pi*(100e6)^2)*log(1/(pi*1e-3)*(3e7/(1.12*100e6))^2);

OpenCossan.cossanDisp(['Error in the approximation: ' num2str(100*(Xo.Tvalues.FatigueLife - Ref)/Ref) '%'])
