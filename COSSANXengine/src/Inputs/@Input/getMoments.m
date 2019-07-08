function varargout = getMoments(Xobj,varargin)
%getMoments  Retrieve the first two moments of the Random Variables present
%in the Input object. 
% If only 1 output is requested the function returns the mean values of the
% Random Variables
%
% USAGE: [Vmean,Vstd]=getMoments(Xobj,'CSnames',{'X1' 'X2'})
%
% See Also: https://cossan.co.uk/wiki/index.php/getMoments@Input
%

%%  Argument Check
OpenCossan.validateCossanInputs(varargin{:});

Cnames     = Xobj.CnamesRandomVariableSet;
Crvset     = Cnames;

LrvNotSet=true;
for k=1:2:nargin-1,
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
    Nrv=Nrv+Xobj.Xrvset.(Cnames{n}).Nrv;
end

% Preallocate memory
Moutput=zeros(Nrv,nargout);
Istart=1;
for k=1:length(Cnames)
    %% check if the variable is a RandomVariableSet
    if Vpos(k)
        Voutm=Xobj.Xrvset.(Cnames{k}).get('mean');
        Iend=Istart+length(Voutm)-1;
        Moutput(Istart:Iend,1) = Voutm;
        if nargout>1
            Vouts = Xobj.Xrvset.(Cnames{k}).get('std');
            Moutput(Istart:Iend,2) = Vouts;
        end
    else
        Iend=Istart;
        %% check if the variable is a RandomVariable
        for n=1:length(Crvset)
            index=find(ismember(Xobj.Xrvset.(Crvset{n}).Cmembers,Cnames{k}));
            if ~isempty(index)
                Vmean=(Xobj.Xrvset.(Crvset{n}).get('mean'));
                Moutput(Istart,1) = Vmean(index);
                if nargout>1
                    Vstd=(Xobj.Xrvset.(Crvset{n}).get('std'));
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