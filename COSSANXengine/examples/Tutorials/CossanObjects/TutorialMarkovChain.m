%% Tutorial MarkovChain
%
% A Markov chain, named after Andrey Markov, is a stochastic process with the Markov property. 
% Having the Markov property means that future states depend only on the 
% present state, and are independent of past states.
%
% At each step the system may change its state from the current state to 
% another state (or remain in the same state) according to a 
% probability distribution. 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@MarkovChain
%
% $Copyright~1993-2011,~COSSAN~Working~Group,~University~of~Innsbruck,~Austria$
% $Author:~Edoardo~Patelli$ 

% Reset the random number generator in order to obtain always the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(56236)

%% Start
% The MarkovChain requires two RandomVariableSet that play the role of the
% proposal distribution and the target distribution
%
%
% The first ('xrvsetbase') contains the real distributions of the samples.
% The second ('Xrvsoff') define the distributions

XrvN=RandomVariable('Sdistribution','normal','mean',0,'std',1);
Xrvsbase = RandomVariableSet('Xrv',XrvN,'Nrviid',3);

XrvU=RandomVariable('Sdistribution','uniform','lowerbound',-0.5,'upperbound',0.5);
Xrvsoff = RandomVariableSet('Xrv',XrvU,'Nrviid',3);

% Create an Input object (optional)
Xin=Input('Xrvset',Xrvsbase);

% Create a Samples object to define the initial starting point of the
% Markov chains and the number of chains.

Xin=sample(Xin,'Nsamples',10);
Xs=Xin.Xsamples;

%% Construct the markov chain object
% The markovchain object can be initilized passing the 2 RandomVariableSets
% or passing an Input object (containing only 1 RandomVariableSet) and a
% RandomVariableSet for the proposal distribution

Xmkv1=MarkovChain('XtargetDistribution',Xrvsbase, ...
                  'Xoffsprings',Xrvsoff, ...
                  'Xsamples',Xs,'Npoints',5);

% Show object
display(Xmkv1)

%% Construct a chain
% use the method buildChain to constract a Markov chain
Xmkv1=Xmkv1.buildChain(5); 
% Show object
display(Xmkv1)

% or using the Input object. The TargetDistribution and the Initial point
% are extracted automatically from the Input object. 

Xmkv2=MarkovChain('Xinput',Xin,'Xoffsprings',Xrvsoff,'Npoints',8);          

% Show the Object            
display(Xmkv2)


%% Optional parameter
% burnin (k)    generates a Markov chain with values between the starting
%               point and the kth point omitted in the generated sequence.
%               Values beyond the kth point are kept. 
%               k is a nonnegative integer with default value of 0.
%
% thin (m)      generates a Markov chain with m-1 out of m values omitted 
%               in the generated sequence. 
%               m is a positive integer with default value of 1.

% Generate samples using optional parameters burnin and thin
Xmkv2.burnin=1;
Xmkv2.thin=2;
% 
% %% Retrieve the chains
MX=getChain(Xmkv2,'Vchain',[1])
% 
% % Retrive 2 chains 
MX=getChain(Xmkv2,'Vchain',[1 2])
% 
% % Retrive 2 chains 
MX=getChain(Xmkv2,'Vchain',[1 10])
% 
% Retrive 3 chains 
MX=getChain(Xmkv2,'Vchain',[1 2 10])
% 
% % Retrive samples only ever 3 Markov Chain states
Xmkv2.thin=3;
MX=getChain(Xmkv2,'Vchain',[1 2 10])

%% Modify the chains
% Add new states to the Markov Chains

% Add 2 samples (states)
Xmkv2=Xmkv2.add('Npoints',2);

display(Xmkv2)

% Remove the latest state
Xmkv2=Xmkv2.remove;
% 
display(Xmkv2)

%% Drop the last state for the first and second chain only
% The length of the chains is restored automatically replacing the dropped
% states with the previous ones
Xmkv2=Xmkv2.remove('Vchain',[1 2]);
Xmkv2.thin=1;

MX=getChain(Xmkv2,'Vchain',[1 2 3])

%% Validate Results
Vreference=[-1.824927459254609e-01    -3.499196590359148e-01     1.290565055272622e+00;
    -1.456746556698092e-01    -3.499196590359148e-01     2.169652571497212e+00;
    -7.959343541250629e-01     1.734787879460887e-01     5.183057616652722e-01;
    -1.491161141145700e+00     1.734787879460887e-01    -6.156558011172009e-01;
     3.395965520469954e-01     1.734787879460887e-01    -6.156558011172009e-01;
     1.950008768899607e+00     7.811059480956469e-01    -4.559525913311414e-01;
     2.360647275500865e+00     1.137386499517076e+00    -6.474377111746816e-01;
     2.360647275500865e+00     3.802170924133108e-01    -8.306080491883350e-01;
     2.360647275500865e+00     3.802170924133108e-01    -8.306080491883350e-01;
    -7.595250572281091e-01     2.099702382086188e+00    -2.105542488166792e-01;
    -1.050259152870634e+00     2.099702382086188e+00     4.407213777585910e-01;
    -1.503041637611334e+00     1.651663304973359e+00     4.407213777585910e-01;
    -7.640986998554642e-01     1.761270372892817e+00    -1.136190430698683e+00;
    -1.556337035893296e+00     1.761270372892817e+00    -8.591144039108953e-01;
    -1.693351069966612e+00     2.304344888688571e+00    -8.591144039108952e-01;
    -9.554782720737628e-01     9.776627714398418e-01    -1.189866306818801e+00;
     4.814748009335627e-01     3.787113244920665e-01    -1.189866306818801e+00;
     4.814748009335627e-01     3.787113244920665e-01    -1.189866306818801e+00;
     1.058057714921985e-01    -5.756912322579699e-01    -4.273335383313855e-01;
     2.911488016457205e-01     1.211585972717668e+00    -4.273335383313855e-01;
     2.911488016457205e-01     1.396869352993849e+00    -4.273335383313855e-01;
     1.000163036504084e+00     1.396869352993849e+00     1.178398411807117e-01;
     1.000163036504084e+00     2.218665633826557e+00    -2.652503820776197e-03;
     1.851577396167740e+00     2.218665633826557e+00     7.991171910692257e-01;
     4.345761732087304e-01     8.342556045708378e-01     1.020429798019601e+00;
     4.345761732087304e-01    -4.014382920300932e-01     2.243999587839387e+00;
    -1.168821347135370e+00    -1.081085046923253e+00     1.408520952678413e+00];

% Check solutions
assert(max(max(Vreference-MX))<1e-15,'openCOSSAN:Tutorial','wrong results')

disp('Tutorial terminated successfully')
