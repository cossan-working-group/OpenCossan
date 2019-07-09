function varargout = getMoments(Xobj,varargin)
%getMoments  Retrieve the first two moments of the Random Variables present
%in the Input object. 
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getMoments@Input
%

%%  Argument Check
opencossan.OpenCossan.validateCossanInputs(varargin{:});

Cnames     = Xobj.RandomVariableSetNames;
Crvset     = Cnames;

% TODO: use new input parser
LrvNotSet=true;
for k=1:2:nargin-1
    switch lower(varargin{k})
        case {'sname', 'sobjectname'}
            %check input
            assert(LrvNotSet,'openCOSSAN:Input:getValues:MultipleDeclarationVariableName',...
            'One and only one of the fields ''Cnames'' and ''Sname'' can be used')
            LrvNotSet=false;
            Cnames = varargin(k+1);
        case {'csnames'}
            %check input
            assert(LrvNotSet,'openCOSSAN:Input:getValues:MultipleDeclarationVariableName',...
            'One and only one of the fields ''Cnames'' and ''Sname'' can be used')
            LrvNotSet=false;
            Cnames = varargin{k+1};
        otherwise
            error('openCOSSAN:Input:getMoments:wrongArgument',...
                'The field (%s) is not valid for this function!',varargin{k})
    end
end



%% Check if the variable Sname is present in the Input object

% Cfun       = Xobj.CnamesFunction;
% Csp        = Xobj.CnamesStochasticProcess;


% Store the values of the random variables locally for speed improvment
% if Xobj.Nsamples>0
%     MsamplesPhysicalSpace=Xobj.Xsamples.MsamplesPhysicalSpace;
% end

Vpos=ismember(Crvset,Cnames);
Vindex=find(Vpos);
Nrv=length(Cnames)-length(Vindex);
%% Compute total number or RandomVariables
for n=1:length(Vindex)
    Nrv=Nrv+Xobj.RandomVariableSets.(Cnames{n}).Nrv;
end

% Preallocate memory
Moutput=zeros(Nrv,nargout);
Istart=1;
for k=1:length(Crvset)
    %% check if the variable is a RandomVariableSet
    if Vpos(k)
        Voutm=Xobj.RandomVariableSets.(Cnames{k}).getMean;
        Iend=Istart+length(Voutm)-1;
        Moutput(Istart:Iend,1) = Voutm;
        if nargout>1
            Vouts = Xobj.RandomVariableSets.(Cnames{k}).getStd;
            Moutput(Istart:Iend,2) = Vouts;
        end
    else
        Iend=Istart;
        %% check if the variable is a RandomVariable
        for n=1:length(Cnames)
            index=find(ismember(Xobj.RandomVariableSets.(Crvset{k}).Cmembers,Cnames{n}));
            if ~isempty(index)
                Vmean=(Xobj.RandomVariableSets.(Crvset{k}).getMean);
                Moutput(Istart,1) = Vmean(index);
                if nargout>1
                    Vstd=(Xobj.RandomVariableSets.(Crvset{k}).getStd);
                    Moutput(Istart,2) = Vstd(index);
                end
            end
        end
        
    end
    Istart=Iend+1;
end

varargout{1}=Moutput(:,1)';
if nargout>1
    varargout{2}=Moutput(:,2)';
end
end