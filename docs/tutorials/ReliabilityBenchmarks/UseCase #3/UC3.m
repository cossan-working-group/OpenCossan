% USE CASE # 3 - non linear system
disp('');
disp('--------------------------------------------------------------------------------------------------');
disp('USE CASE #3: NON LINEAR SYSTEM');

%% Test with COSSAN-X
RV1=RandomVariable('Sdistribution','normal', 'mean',0,'std',1); 
RV2=RV1;
Xrvs=RandomVariableSet('Cmembers',{'RV1','RV2'}); 

%% Define Xinput
inp1 = Input('XRandomVariableSet',Xrvs);

Xm1=Mio(        'Sdescription', 'Performance function', ...
                'Spath','performacefunctions', ...
                'Sfile','perfun1nl', ...
                'Cinputnames',{'RV1','RV2'}, ...
                'Coutputnames',{'out'}, ...
                'Lfunction',true, ...
                'Liostructure',true);
			
Xm3=Mio(        'Sdescription', 'Performance function', ...
                'Spath','performacefunctions', ....
                'Sfile','perfun3nl', ...
                'Cinputnames',{'RV1','RV2'}, ...
                'Coutputnames',{'out'}, ...
                'Lfunction',true, ...
                'Liostructure',true);	
		
% This performance function is defined only for the validation of the results

Xm13=Mio(       'Sdescription', 'Performance function', ...
                'Spath','performacefunctions', ...
                'Sfile','perfun13nl', ...
                'Cinputnames',{'RV1','RV2'}, ...
                'Coutputnames',{'out'}, ...
                'Lfunction',true, ...
                'Liostructure',true);	
			
Xm1or3=Mio(     'Sdescription', 'Performance function', ...
                'Spath','performacefunctions', ...
                'Sfile','perfun1or3nl', ...
                'Cinputnames',{'RV1','RV2'}, ...
                'Coutputnames',{'out'}, ...
                'Lfunction',true, ...
                'Liostructure',true);			
			
%% Show the limit state function!!! 
x1=[-6:0.1:6];
y1=(2-x1)./(0.01+0.05*x1.^2);
y3=(2.5+0.05*x1.^2)/2;
y13=max(y1,y3);
y1or3=min(y1,y3);

createfigureU3(x1,[y1; y3; y13; y1or3])

%% Construct the evaluators
Xev= Evaluator;

%% Create Model
Xmdl=Model('Xinput',inp1,'Xevaluator',Xev);

%% Define the evaluators as Xperfun
Xpf1    = PerformanceFunction('Xmio',Xm1,'Soutputname','Vg1');
Xpf3    = PerformanceFunction('Xmio',Xm3,'Soutputname','Vg3');
Xpf13   = PerformanceFunction('Xmio',Xm13,'Soutputname','Vg13');
Xpf1or3 = PerformanceFunction('Xmio',Xm1or3,'Soutputname','Vg1or3');

%% Create the probmodel
Xpm1    = ProbabilisticModel('XModel',Xmdl,'XPerformanceFunction',Xpf1,'Sdescription','Probabilistic model1');
Xpm3    = ProbabilisticModel('XModel',Xmdl,'XPerformanceFunction',Xpf3,'Sdescription','Probabilistic model3');
Xpm13   = ProbabilisticModel('XModel',Xmdl,'XPerformanceFunction',Xpf13,'Sdescription','Probabilistic model13');
Xpm1or3 = ProbabilisticModel('XModel',Xmdl,'XPerformanceFunction',Xpf1or3,'Sdescription','Probabilistic model1or3');

%% Create a SystemReliability object
% Create the fault tree
CnodeTypes={'Output','AND','Input','Input'};
CnodeNames={'TopEvent','AND gate','Xpf1','Xpf3'};
VnodeConnections=[0 1 2 2];

Xft=FaultTree('CnodeTypes',CnodeTypes,'CnodeNames',CnodeNames,...
               'VnodeConnections',VnodeConnections, ...
               'Sdescription','FaultTree object UC3');

% Summary of the FaultTree
display(Xft)
Xft.plotTree

Xsys=SystemReliability('Cmembers',{'Xpf1';'Xpf3'},...
     'XperformanceFunctions',[Xpf1 Xpf3], ...
     'Xmodel',Xmdl,'XFaultTree',Xft);
 


%% Find the design point of each component
Xsys=Xsys.designPointIdentification;
% Show the DesignPoint
display(Xsys.XdesignPoints)

%% Plot results

% Retrieve the important direction of each component
Calpha=get(Xsys,'Valpha_u');

hc1=compass(Calpha{1}(1) ,Calpha{1}(2));
hc2=compass(Calpha{2}(1), Calpha{2}(2));

set(hc1,'Color','b','DisplayName','\alpha g1','LineWidth',2);
set(hc2,'Color','g','DisplayName','\alpha g3','LineWidth',2);

% Retrieve the design point of each component
for n=1:length(Xsys.XdesignPoints)
    Cdp{n}=Xsys.XdesignPoints{n}.VDesignPointStdNormal;
end

scatter(Cdp{1}(1),Cdp{1}(2),'s');
scatter(Cdp{2}(1),Cdp{2}(2),'o');

for i=1:length(Calpha)
	disp(['component #' num2str(i) ': ' ])
	disp(['Direction        : ' sprintf('%c %e',Calpha{i}) ])
	disp(['Design Point     : '  num2str(Cdp{i}) ])
	disp(['Reliability Index: ' sprintf('%e',norm(Cdp{i})) ])
end

% Find dp using linear hypothesis
[Xcutset Vdp] = Xsys.findIntersection;

display(Xcutset)

%% Plot results
createfigureU3(x1,[y1; y3; y13; y1or3])
scatter(Vdp(1),Vdp(2),'v','SizeData',50,'LineWidth',2);


%% FORM approach
% Compute the pf of the intersections
[~, pf_form]  = Xsys.pfLinearIntersection('Ccutset',{[1 2]});
% compute bounds
[~, lowerBound1 UpperBound1] = Xsys.computeBounds('Ccutset',{[1 2]},'Lfirstorder',true);
[~, lowerBound2 UpperBound2] = Xsys.computeBounds('Ccutset',{[1 2]});

disp ('Estimated pf (FORM) of the joint events ')
disp(['Event # 1-2: ' sprintf('%e',pf_form)]);
disp ('First order bounds  ')
disp(['Lowerlimit : ' sprintf('%e',lowerBound1) ]);
disp(['Upperlimit : ' sprintf('%e', UpperBound1) ]);
disp ('Second order bounds (aka Ditlevsev bounds) ')
disp(['Lowerlimit : ' sprintf('%e',lowerBound2) ]);
disp(['Upperlimit : ' sprintf('%e', UpperBound2) ]);

%%  MONTE CARLO SIMULATION
Xmc=MonteCarlo('Nsamples',1e2);
Xsys=Xsys.pfComponents('Xsimulation',Xmc);

[~, lowerBound1 UpperBound1] = Xsys.computeBounds('Ccutset',{[1 2]},'Lfirstorder',true);
[~, lowerBound2 UpperBound2] = Xsys.computeBounds('Ccutset',{[1 2]});

pf_mc=sparse(2,2);
pf_mc(1,2)=Xsys.pf('Xsimulations',Xmc,'Ccutset',{[1 2]});
[Xsys L2_mc U2_mc] = DitlevsenBounds(Xsys,'Mpf2',pf_mc,'Vpf',VpfMC);

disp ('============== M C S =============:')
disp (['Estimated pf (MCS) of the basic events with ' num2str(Nsamples) ' samples:'])
for i=1:length(VpfFORM)
	disp(['Event # ' num2str(i) ': ' sprintf('%e',VpfFORM(i))]);
end
disp (['Estimated pf (MCS) of the joint events 1-2 ' num2str(Nsamples) ' samples:'])
for i=1:length(VpfMC)
	for j=i+1:length(VpfMC)
		disp(['Event # ' num2str(i) '-' num2str(j) ' : ' sprintf('%e',pf_mc(i,j))]);
	end
end

U1_mc= max(VpfMC);
L1_mc= sum(VpfMC);

disp (['First order bounds  '])
disp(['Lowerlimit : ' sprintf('%e',L1_mc) ]);
disp(['Upperlimit : ' sprintf('%e', U1_mc) ]);
disp (['Second order bounds (aka Ditlevsev bounds) '])
disp(['Lowerlimit : ' sprintf('%e',L2_mc) ]);
disp(['Upperlimit : ' sprintf('%e', U2_mc) ]);

%%  IMPORTANCE SAMPLING

Mmcs=bin2dec('11');
Nsamples=1e3;
VpfIS=pf(Xsys,'Smethod','IS','Nsamples',Nsamples,'Lbasicevent',true);
pf_is=sparse(2,2);
pf_is(1,2)=pf(Xsys,'Smethod','IS','Mcs',Mmcs,'Nsamples',Nsamples);
[Xsys L2_is U2_is] = DitlevsenBounds(Xsys,'Mpf2',pf_is,'Vpf',VpfIS);

disp ('============== I S =============:')
disp (['Estimated pf (IS) of the basic events with ' num2str(Nsamples) ' samples:'])
for i=1:length(VpfIS)
	disp(['Event # ' num2str(i) ': ' sprintf('%e',VpfIS(i))]);
end
disp (['Estimated pf (IS) of the joint events 1-2 ' num2str(Nsamples) ' samples:'])
for i=1:length(VpfIS)
	for j=i+1:length(VpfIS)
		disp(['Event # ' num2str(i) '-' num2str(j) ' : ' sprintf('%e',pf_is(i,j))]);
	end
end

U1_is= max(VpfIS);
L1_is= sum(VpfIS);

disp (['First order bounds  '])
disp(['Lowerlimit : ' sprintf('%e',L1_is) ]);
disp(['Upperlimit : ' sprintf('%e', U1_is) ]);
disp (['Second order bounds (aka Ditlevsev bounds) '])
disp(['Lowerlimit : ' sprintf('%e',L2_is) ]);
disp(['Upperlimit : ' sprintf('%e', U2_is) ]);

%% Validationn of the results of min(g1,g3) (CHAIN SYSTEM)
% FORM
[Xo1or3FORM ]=pf(Xpm1or3,'Smethod','FORM');
Tpf1or3FORM=get(Xo1or3FORM,'Tpf');

disp ('============== Verification FORM =============:')
disp(['Estimated Pf (1 OR 3): : ' sprintf('%e',Tpf1or3FORM.pfhat) ' - CoV: ' sprintf('%e',Tpf1or3FORM.CoV)]);

% Montecarlo
[Xo1or3MC ]=pf(Xpm1or3,'Smethod','MCS','Nsamples',10000);
Tpf1or3MC=get(Xo1or3MC,'Tpf');

disp ('============== Verification MCS =============:')
disp(['Estimated Pf (1 OR 3): : ' sprintf('%e',Tpf1or3MC.pfhat) ' - CoV: ' sprintf('%e',Tpf1or3MC.CoV)]);

% Importancesampling
Xpm1or3=set(Xpm1or3,'Vdp_u',get(Xsys,'Mdp_u'));
[Xo1or3IS ]=pf(Xpm1or3,'Smethod','IS','Nsamples',1e3,'Nbatches',1);
Tpf1or3IS=get(Xo1or3IS,'Tpf');

disp ('============== Verification IS =============:')
disp(['Estimated Pf13: : ' sprintf('%e',Tpf1or3IS.pfhat) ' - CoV: ' sprintf('%e',Tpf1or3IS.CoV)]);

%Min=cell2mat(struct2cell(get(Xo,'Tinput')));
%scatter(Min(1,:),Min(2,:))
%disp(['Estimated Pf: : ' sprintf('%e',Tpf.pfhat) ' - CoV: ' sprintf('%e',Tpf.CoV)]);

%%  PLOT THE RESULTS
%group the results (event,method)
% E.g. event pf1,FORM pf1,MC pf2,IS

Y=[VpfFORM VpfMC VpfIS; pf_form(1,2) pf_mc(1,2) pf_is(1,2)];
Y2=[U1_form U1_mc U1_is; L1_form L1_mc L1_is; U2_form U2_mc U2_is; Tpf1or3FORM.pfhat Tpf1or3MC.pfhat Tpf1or3IS.pfhat ];

createbarfigureU3(Y,{'g1';'g3';'g1 AND g3'},'UC3')
createbarfigureU3(Y2,{'1st Upper';'1st Lower';'2nd Upper/Lower';'whole system'},'Use CASE #3: Chain System')


