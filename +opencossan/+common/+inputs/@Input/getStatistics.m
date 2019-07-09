function varargout = getStatistics(Xobj,varargin)
%getMoments  Retrieve the first two moments of the Random Variables present
%in the Input object.
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/getMoments@Input
%
% $Author:~Marco~de~Angelis$

%%  Argument Check
opencossan.OpenCossan.validateCossanInputs(varargin{:});

Cnames = Xobj.RandomVariableSetNames;
Crvset = Cnames;

%TODO: use new input parser
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
        case {'csstatistics','csstatistic'}
            CSstat=varargin{k+1};
        otherwise
            error('openCOSSAN:Input:getStatistics:wrongArgument',...
                'The field (%s) is not valid for this function!',varargin{k})
    end
end


%% Check if the variable Sname is present in the Input object

VindexRVS=ismember(Crvset,Cnames); %
VpositRVS=find(VindexRVS);         % positions where the rvsets are located
Nrv=length(Cnames)-length(VpositRVS);
%% Compute total number or RandomVariables
for n=1:length(VpositRVS)
    Nrv=Nrv+Xobj.Xrvset.(Cnames{n}).Nrv;
end

% Preallocate memory
Moutput=zeros(length(CSstat),Nrv);
Istart=1;
for k=1:length(Cnames)
    %% check if the variable is a RandomVariableSet
    if VindexRVS(k)
        NrvCurrentSet=Xobj.Xrvset.(Cnames{k}).Nrv;
        for h=1:length(CSstat)
            switch lower(CSstat{h})
                case 'median'
                    VoutMedian=Xobj.Xrvset.(Cnames{k}).map2physical(zeros(1,NrvCurrentSet));
                    Iend=Istart+length(VoutMedian)-1;
                    Moutput(h,Istart:Iend) = VoutMedian;
                case 'skewness'
                    %TODO
                case 'kurtosis'
                    %TODO
            end
        end
    else
        Iend=Istart;
        %% check if the variable is a RandomVariable
        for n=1:length(Crvset)
            position=find(ismember(Xobj.Xrvset.(Crvset{n}).Cmembers,Cnames{k}), 1);
            NrvCurrentSet=Xobj.Xrvset.(Crvset{n}).Nrv;
            if ~isempty(position)
                for h=1:length(CSstat)
                    switch lower(CSstat{h})
                        case 'median'
                            Vmedian=(Xobj.Xrvset.(Crvset{n}).map2physical(zeros(1,NrvCurrentSet)));
                            Moutput(h,Istart) = Vmedian(index);
                            Istart=Istart+1;
                        case 'skewness'
                            %TODO
                        case 'kurtosis'
                            %TODO
                    end
                end
            end
        end
        
    end
    Istart=Iend+1;
end

% Assign the output
for h=1:length(CSstat)
    varargout{h}=Moutput(h,:);
end

end