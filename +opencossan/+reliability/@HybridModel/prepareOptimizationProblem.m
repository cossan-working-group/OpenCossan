function Xop=prepareOptimizationProblem(Xobj,varargin)

% This is a private function of the Hybrid Model used to tranform a
% hybrid problem into an Optimization problem.
% It requires only 1 input, the matrix of initial points provided in the
% exact order as the order of the random variables.
import opencossan.optimization.*
%% Process inputs
OpenCossan.validateCossanInputs(varargin{:})
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'mu0','randomvariablevalues'}
            Mu0     = varargin{k+1};            
        case {'mv0','boundedvariablevalues'}
            Mv0     = varargin{k+1};
        otherwise
            error('openCOSSAN:ProbabilisticModel:HLRF',...
                'PropertyName %s is not valid',varargin{k})
    end
end

%% Extract information from Input
XinputDV=Xobj.Xinput;
XinputDV.Xrvset=struct; % Remove RandomVariableSets
XinputDV.Xbset=struct;  % Remove ConvexSets

CmembersRV=strcat(Xobj.Xinput.CnamesRandomVariable,'_DV');
CmembersBV=strcat(Xobj.Xinput.CnamesIntervalVariable,'_DV');

XdvRV=cell(1,length(CmembersRV));
XdvBV=cell(1,length(CmembersBV));

%% Both bounded and random variables are treated as design variables simultaneously
% Replace RandomVariable with DesingVariable

for n=1:length(CmembersRV)
    XdvRV{n}=DesignVariable('value',Mu0(1,n),'Sdescription',['Design Variable associated to ' CmembersRV{n}],'lowerBound',norminv(eps),'upperBound',norminv(1-eps) );
end

% Replace BoundedVariable with (bounded) DesingVariable (in spherical coords)
if length(Mv0)>1
    Mv=opencossan.common.utilities.cart2sphere(Mv0);
    XdvBV{1}=DesignVariable('value',Mv(1,1),'lowerBound',0,'upperBound',1,...
        'Sdescription',['Design Variable associated to ' CmembersBV{1} ]);
    XdvBV{1,length(CmembersBV)}=DesignVariable('value',Mv(1,length(CmembersBV)),'lowerBound',0,'upperBound',2*pi,...
        'Sdescription',['Design Variable associated to ' CmembersBV{length(CmembersBV)} ]);
else
    XdvBV{1}=DesignVariable('value',Mv0(1,1),'lowerBound',-1,'upperBound',1,...
        'Sdescription',['Design Variable associated to ' CmembersBV{1} ]);
end
    
if length(CmembersBV)>2
    for n=2:length(CmembersBV)-1
        XdvBV{n}=DesignVariable('value',Mv(1,n),'lowerBound',0,'upperBound',pi,...
            'Sdescription',['Design Variable associated to ' CmembersBV{n} ]);
    end
end

XinputDV=opencossan.common.inputs.Input('CSmembers',[CmembersRV CmembersBV],'CXmembers',[XdvRV XdvBV]);

%% Create objective function (only on DVs from RVs)
Xobjfun = ObjectiveFunction('Sdescription','ObjectiveFunction for design point identification (Automatically created by COSSAN)', ...
    'Sformat','matrix',......
    'Sscript','Moutput=sqrt(sum(Minput.^2,2));',...
    'Cinputnames',CmembersRV,...
    'Coutputnames',{'fobj'});


%% Define inequality constraints

% Xcon2   = Constraint('Sdescription','Constrain to ensure the validity of samples in delta space)', ...
%     'Sscript','Moutput=((Minput*Minput'')-1);',...
%     'Cinputnames',CmembersBV,...
%     'Coutputnames',{'DeltaSpaceConstraint'}, ...
%     'Linequality',true,'Liostructure',false,'Liomatrix',true);

Xcon1   = Constraint('Sdescription','Constrain object for design point identification (Automatically created by COSSAN)', ...
    'Sscript','Moutput=Minput;',...
    'Cinputnames',{Xobj.PerformanceFunctionVariable},...
    'Coutputnames',{[Xobj.PerformanceFunctionVariable 'Constrain']}, ...
    'Linequality',true,'Sformat','matrix');


%% Define a solution sequence object
Sstring='Xinput=XhybridModel.Xinput;';

if length(Mv0)>1
    Sstring=strcat(Sstring, 'Xinput.Xsamples=opencossan.common.Samples(''Xinput'',Xinput,', ...
        '''Msamplesstandardnormalspace'',[varargin{[',...
        num2str(find(ismember(XinputDV.Cnames,CmembersRV))),']}],',...
        '''MsamplesHyperSphere'',opencossan.common.utilities.sphere2cart([varargin{[',...
        num2str(find(ismember(XinputDV.Cnames,CmembersBV))),']}]));');
else
    Sstring=strcat(Sstring, 'Xinput.Xsamples=opencossan.common.Samples(''Xinput'',Xinput,', ...
        '''Msamplesstandardnormalspace'',[varargin{[',...
        num2str(find(ismember(XinputDV.Cnames,CmembersRV))),']}],',...
        '''MsampleHyperSphere'',([varargin{[',...
        num2str(find(ismember(XinputDV.Cnames,CmembersBV))),']}]));');
end

% Run Analysis
Sstring=[Sstring 'Xoutput=XhybridModel.Xevaluator.apply(Xinput.getTable);'];
Sstring=[Sstring 'COSSANoutput{1}=Xoutput.addData(''Mvalues'',[varargin{[',...
    num2str(find(ismember(XinputDV.CnamesDesignVariable,XinputDV.Cnames))),']}],',...
    '''Cnames'',XobjSolutionSequence.Cinputnames);'];

Xss=opencossan.workers.SolutionSequence('Sscript',Sstring,'CinputNames', XinputDV.CnamesDesignVariable, ...
    'CoutputNames',{Xobj.PerformanceFunctionVariable},...
    'CobjectsNames',{'Xoutput'},...
    'CprovidedObjectTypes',{'opencossan.common.outputs.SimulationData'},...
    'CXobjects',{Xobj},...
    'Cobject2output',{'.TableValues.( Xobj.Coutputnames{iout})'},...
    'CobjectsTypes',{'opencossan.reliability.HybridModel'},...
    'CobjectsNames',{'XhybridModel'} );

% Solve probabilistic Model and returns Sperformancefunction
Xop = OptimizationProblem('Sdescription','find Design Point (Automatically created by COSSAN)', ...
    'Xmodel',Xss,'Xinput',XinputDV,'XobjectiveFunction',Xobjfun,'CXconstraint',{Xcon1});
end