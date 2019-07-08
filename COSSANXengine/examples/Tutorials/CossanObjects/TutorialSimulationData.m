%% TUTORIALSIMULATIONDATA
%
% In this tutorial it is shown how to construct and use a SimulationData
% object.
% SimulationData is one of the most important object in OpenCossan and
% contains all the results of a simuations.
%
%
% See Also: http://cossan.co.uk/wiki/index.php/@SimulationData
%
% $Copyright~2006-2017,~COSSAN~Working~Group,$
% $Author: Edoardo-Patelli~and~Barbara-Goller$ 

% Reset the random number generator in order to always obtain the same results.
% DO NOT CHANGE THE VALUES OF THE SEED
OpenCossan.resetRandomNumberGenerator(51125)

%% Create a SimulationData as a results of a simulation 
% Define an input object containing random variables and parameters
Xrv1    = RandomVariable('Sdistribution','uniform','par1',1,'par2',2);  
Xrv2    = RandomVariable('Sdistribution','normal','mean',0,'std',1); 
Xrvs1    = RandomVariableSet('Cmembers',{'Xrv1','Xrv2'});    

Xrv3    = RandomVariable('Sdistribution','uniform','par1',3,'par2',5);  
Xrv4    = RandomVariable('Sdistribution','normal','mean',2,'std',0.5);   
Xrvs2    = RandomVariableSet('Cmembers',{'Xrv3','Xrv4'});    

Xpar1   = Parameter('Sdescription','Parameter 1','value',1.5);
Xpar2   = Parameter('Sdescription','Parameter 2','value',2.5);
Xpar3   = Parameter('Sdescription','Parameter 1','value',3.5);
Xpar4   = Parameter('Sdescription','Parameter 2','value',4.5);

% Create 2 Input Objects 
Xin1     = Input('CSmembers',{'Xrvs1','Xpar1','Xpar2'},'CXmembers',{Xrvs1 Xpar1 Xpar2});             
Xin2     = Input('CSmembers',{'Xrvs2','Xpar3','Xpar4'},'CXmembers',{Xrvs2 Xpar3 Xpar4});
% Generate some samples
Xin1     = sample(Xin1,'Nsamples',5);
Xin2     = sample(Xin2,'Nsamples',5);

%% Define models (using Mio)
% Define model 1

Xm1  = Mio('Sscript',['for i=1:length(Tinput), Toutput(i).add1=Tinput(i).Xrv1+Tinput(i).Xpar1;' ...
                                             'Toutput(i).sub1=Tinput(i).Xrv2-Tinput(i).Xpar2;' ... 
                                             'Toutput(i).linfunc1=Tinput(i).Xrv1*Tinput(i).Xpar1; end'], ...
          'Liostructure',true,... 
          'Cinputnames',{'Xrv1','Xrv2','Xpar1','Xpar2'},...
          'Coutputnames',{'add1','sub1','linfunc1'},...
		  'Lfunction',false); 
Xev1 = Evaluator('Xmio',Xm1);
Xmdl1 = Model('Xevaluator',Xev1,'Xinput',Xin1);      
      

% Define model 2
Xm2  = Mio('Sscript',['for i=1:length(Tinput), Toutput(i).add2=Tinput(i).Xrv3+Tinput(i).Xpar3;' ...
                                              'Toutput(i).sub2=Tinput(i).Xrv4-Tinput(i).Xpar4;' ... 
                                              'Toutput(i).linfunc2=Tinput(i).Xrv3*Tinput(i).Xpar3; end'], ...
          'Cinputnames',{'Xrv3','Xrv4','Xpar3','Xpar4'},...
          'Coutputnames',{'add2','sub2','linfunc2'},...
          'Liostructure',true,... 
		  'Lfunction',false); 
Xev2 = Evaluator('Xmio',Xm2);
Xmdl2 = Model('Xevaluator',Xev2,'Xinput',Xin2);          

%% Apply model and hence generate an output -> SimulationData

% Generate output with five samples of Xin1
Xout1 = apply(Xmdl1,Xin1);

% Generate output with other five samples of Xin1
Xin1   = sample(Xin1,'Nsamples',5);
Xout2  =  apply(Xmdl1,Xin1);


%% Methods available for SimulationData

% Sum up the results of two output objects (with same fields & no. of
% simulations)
Xout3 = plus(Xout1,Xout2);

% Subtract Xout2 from Xout1 (must have the same fields and no. of sims)
Xout4 = minus(Xout1,Xout2);

% Add new field with values to SimulationData object Xout3
Xout3 = addVariable(Xout3,'Cnames',{'sequence'},'Mvalues',[1:5]');

% Get values of field "add1"
Vsamples_add1 = Xout1.getValues('Sname','add1');
Vsamples_add2 = Xout2.getValues('Sname','add1');
Vsamples_add3 = Xout3.getValues('Sname','add1');
Vsamples_add4 = Xout4.getValues('Sname','add1');

% Get names of output and input variables and numerb of samples
Xout3.Cnames   % number of variables
Xout3.Nsamples % number of simulations

% Create new SimulationData object and merge with Xout1 (the number
% of sims must be the same, but the two objects can have different fields
Xout5  = apply(Xmdl2,Xin2);
Xout6 = merge(Xout1,Xout5);

%% Create SimulationData by direclty passing the values 

% Create SimulationData by passing a matrix
Xout7 = SimulationData('Sdescription','new output', ...
        'Cnames',{'a','b','c'},'Mvalues',randn(5,3));
    
% Create SimulationData by passing a structure
T(1).a = randn;
T(1).b = randn;
T(1).c = randn;
T(2).a = randn;
T(2).b = randn;
T(2).c = randn;
Xout8 = SimulationData('Sdescription','new output','Tvalues',T);
    

%% Save and load SimulationData
% Save files
Xout5.save('SfileName',[OpenCossan.getCossanWorkingPath '/SimulationData5']);
Xout7.save('SfileName',[OpenCossan.getCossanWorkingPath '/SimulationData7']);
Xout8.save('SfileName',[OpenCossan.getCossanWorkingPath '/SimulationData8']);

% Load files
Xout5=SimulationData.load('SfileName',[OpenCossan.getCossanWorkingPath '/SimulationData5']);
Xout7=SimulationData.load('SfileName',[OpenCossan.getCossanWorkingPath '/SimulationData7']);
Xout8=SimulationData.load('SfileName',[OpenCossan.getCossanWorkingPath '/SimulationData8']);
display(Xout8)


%% Validate results

% Values of Xout1
Mdata1 = [1.7574    1.3633    1.5000    2.5000    3.2574   -1.1367    2.6360
          1.0673    1.8226    1.5000    2.5000    2.5673   -0.6774    1.6010
          1.4665   -0.9409    1.5000    2.5000    2.9665   -3.4409    2.1997
          1.0321    2.2229    1.5000    2.5000    2.5321   -0.2771    1.5482
          1.1190    0.6093    1.5000    2.5000    2.6190   -1.8907    1.6786];
assert(all(all(abs(Xout1.getValues('Cnames',Xout1.Cnames)-Mdata1)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout1 does not match.');

% Values of Xout2   
Mdata2 = [1.3249   -0.5443    1.5000    2.5000    2.8249   -3.0443    1.9873
          1.0842    0.1492    1.5000    2.5000    2.5842   -2.3508    1.6263
          1.0363   -1.5908    1.5000    2.5000    2.5363   -4.0908    1.5545
          1.8597    0.5174    1.5000    2.5000    3.3597   -1.9826    2.7896
          1.1718    1.9195    1.5000    2.5000    2.6718   -0.5805    1.7577];
assert(all(all(abs(Xout2.getValues('Cnames',Xout2.Cnames)-Mdata2)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout2 does not match.');      
 
% Values of Xout3      
Mdata3 = [3.0822    0.8190    3.0000    5.0000    6.0822   -4.1810    4.6234    1.0000
          2.1515    1.9718    3.0000    5.0000    5.1515   -3.0282    3.2272    2.0000
          2.5028   -2.5316    3.0000    5.0000    5.5028   -7.5316    3.7541    3.0000
          2.8918    2.7403    3.0000    5.0000    5.8918   -2.2597    4.3377    4.0000
          2.2909    2.5289    3.0000    5.0000    5.2909   -2.4711    3.4363    5.0000];
assert(all(all(abs(Xout3.getValues('Cnames',Xout3.Cnames)-Mdata3)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout3 does not match.');  
   
% Values of Xout4     
Mdata4 = [0.4325    1.9076         0         0    0.4325    1.9076    0.6487
          1.0673    1.8226    1.5000    2.5000    2.5673   -0.6774    1.6010
          1.4665   -0.9409    1.5000    2.5000    2.9665   -3.4409    2.1997
          1.0321    2.2229    1.5000    2.5000    2.5321   -0.2771    1.5482
          1.1190    0.6093    1.5000    2.5000    2.6190   -1.8907    1.6786];
assert(all(all(abs(Xout4.getValues('Cnames',Xout4.Cnames)-Mdata4)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout4 does not match.'); 

% Values of Xout5      
Mdata5 = [3.9342    2.5424    3.5000    4.5000    7.4342   -1.9576   13.7696
          4.9600    2.1784    3.5000    4.5000    8.4600   -2.3216   17.3599
          3.4128    2.2902    3.5000    4.5000    6.9128   -2.2098   11.9447
          3.8183    1.6696    3.5000    4.5000    7.3183   -2.8304   13.3641
          3.7228    1.4184    3.5000    4.5000    7.2228   -3.0816   13.0296];   
assert(all(all(abs(Xout5.getValues('Cnames',Xout5.Cnames)-Mdata5)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout5 does not match.');  

% Values of Xout6     
Mdata6 =[1.7574    1.3633    1.5000    2.5000    3.2574   -1.1367    2.6360    3.9342   2.5424    3.5000    4.5000    7.4342   -1.9576   13.7696
         1.0673    1.8226    1.5000    2.5000    2.5673   -0.6774    1.6010    4.9600   2.1784    3.5000    4.5000    8.4600   -2.3216   17.3599
         1.4665   -0.9409    1.5000    2.5000    2.9665   -3.4409    2.1997    3.4128   2.2902    3.5000    4.5000    6.9128   -2.2098   11.9447
         1.0321    2.2229    1.5000    2.5000    2.5321   -0.2771    1.5482    3.8183   1.6696    3.5000    4.5000    7.3183   -2.8304   13.3641
         1.1190    0.6093    1.5000    2.5000    2.6190   -1.8907    1.6786    3.7228   1.4184    3.5000    4.5000    7.2228   -3.0816   13.0296];
assert(all(all(abs(Xout6.getValues('Cnames',Xout6.Cnames)-Mdata6)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout6 does not match.');  

% Values of Xout7   
Mdata7 = [-0.4746    1.1455   -1.2186
           0.1461   -1.2698    0.2469
          -0.6349   -0.4849    1.6717
          -0.8929    0.1372   -0.5108
          -0.2598   -0.5100    0.4744];
assert(all(all(abs(Xout7.getValues('Cnames',Xout7.Cnames)-Mdata7)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout7 does not match.');  
   
% Values of Xout8       
Mdata8 = [-0.3233    0.2433    0.5796
          -1.3204    0.6165    0.4520];
assert(all(all(abs(Xout8.getValues('Cnames',Xout8.Cnames)-Mdata8)<1.e-4)),...
       'CossanX:Tutorials:TutorialSimulationData', ...
       'Reference Solution Xout8 does not match.');  
   
%% Get PDF and CDF of variables from the SimulationData
% Get the Pdf of all variable without defining the bins and edges.
% The number of bins are determined automatically by the first variable
[Vedges,Vpdf]=Xout1.getPDF;

% Compute coordinatesand plot the results
Vwidth=diff(Vedges);
Vcoord=Vedges(1)+cumsum(Vwidth);
bar(Vcoord,Vpdf,Vwidth(1))

% Specify number of bins;
[Vedges,Vpdf]=Xout1.getPDF('Sname','add1','Nbins',10);
% Compute the pdf for all the variable. It is necessary to pass a vector
% that defines the edges of the bins (Vedges).
% The length of Vedges is 1+length(Vpdf)
[Vedges,Vpdf]=Xout1.getPDF('Vedges',Vedges);

[Vedges,Vcdf]=Xout1.getCDF('Sname','add1');
% Plot the data
Vwidth=diff(Vedges);
Vcoord=Vedges(1)+cumsum(Vwidth);
plot(Vcoord,Vcdf)

%% Create SimulationData with a Dataseries
% Let assume we want to add a Dataseries to an existing SimulationData
% object
% The simulationData contains already 2 samples. Hence the new variable
% should also contain 2 samples. 
Td(1).d=Dataseries;
Td(2).d=Dataseries;

Xout9=Xout8.addVariable('Tvalues',Td)
Xout9.CnamesDataseries

T2(2).e=5;
Xout9=Xout9.addVariable('Tvalues',T2)     

% The field LisDataseries allows to distiguis if a variable is stored as a
% Dataseries object. 
Xout9.LisDataseries

% Now let remove some variables. You can specify which variable to keep and
% which ones to remove
Xout10=Xout9.split('Cnames',{'a','b'})
Xout10=Xout9.split('CremoveNames',{'c','d'})

Xout10.LisDataseries
Xout10.CnamesDataseries
Xout10.Cnames