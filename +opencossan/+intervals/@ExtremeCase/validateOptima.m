function varargout=validateOptima(Xobj,varargin)
% VALIDATEOPTIMA This method is a common interface for different reliability based
%optimization approaches. 
%
% See also: http://cossan.cfd.liv.ac.uk/wiki/index.php/validateOptima@ExtremeCase

for k=1:2:length(varargin),
    switch lower(varargin{k}),
        case 'mvalues'
            Mvalues = varargin{k+1};
        otherwise
            error('openCOSSAN:ExtremeCase:validateOptima',...
                'PropertyName %s not allowed', varargin{k})
    end
end

N=size(Mvalues,1);
for h=1:N
% Extract Input from Extreme Case object
Xinput=Xobj.XinputProbabilistic;
% Extract Evaluator from ProbabilisticModel object
Xevaluator=Xobj.XprobabilisticModel.Xmodel.Xevaluator;
% Extract PerformanceFunction and performance function name
XperformanceFunction=Xobj.XprobabilisticModel.XperformanceFunction;
SperfName=XperformanceFunction.Soutputname;
% Update Input object
warning('OFF','OpenCossan:Parameter:set:obsolete')
Nvariables2map=size(Xobj.CdesignMapping,1);
for n=1:Nvariables2map
    Xinput=Xinput.set('SobjectName',Xobj.CdesignMapping{n,2},...
        'SpropertyName',Xobj.CdesignMapping{n,3},'value',Mvalues(h,n));
end
% Reconstruct Model
Xmodel=Model('Xinput',Xinput,'Xevaluator',Xevaluator);
% Reconstruct ProbabilisticModel
Xpm=ProbabilisticModel('XperformanceFunction',XperformanceFunction,'Xmodel',Xmodel);
% Write the updated input into the probabilistic model
Xpm.Xmodel.Xinput=Xinput;
% reliability analysis for the maximum
[Xpf(h),~]=Xobj.XadaptiveLineSampling.computeFailureProbability(Xpm);
% 
XlineData(h)=LineData('Sdescription','My first Line Data object',...
    'Xals',Xobj.XadaptiveLineSampling,'LdeleteResults',true,...
    'Sperformancefunctionname',SperfName,...
    'Xinput',Xinput);
end
varargout={Xpf,XlineData};