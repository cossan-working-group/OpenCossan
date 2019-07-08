function [Xcutset varargout] = computeBounds(Xsys,varargin)
% BOUNDS  Estimate the upper and lower bounds of the  probability
% of failure based on the Ditlevsen approximation [DIT1973].
%
%
% Reference
% [DIT1973]
% Ove Ditlevsen. Structural reliability and the invariance problem. part 1:
% The invariance problem in deterministic or bayesian structural safety
% concepts. part 2: A second moment statistical basis for partial safety
% factor codes. Technical Report 22, Solid Mechanics Division,
% University of Waterloo, Waterloo, Ontario, Canada,, 1973.
%
% See Also: 
%
% Valid field names:
%  Mpf2     : matrix of the pfs of union events. If this matrix is NOT passed the
%             method estimate the second order bounds adopting the PFs passed as optional argument
%  Vpf      : array of the failure probability of each events
%  Xcutset  : CutSet object(s)
%  Ccutset  : cell array to define the cut-set
%
%  OUPUT argument
%  Xcutset     : Cut-set object
%  varargout{1}: vector of the lower bounds
%  varargout{2}: vector of the upper bounds
%
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/computeBounds@SystemReliability
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli


%% Check inputs
LfirstOrder=false;
Ncomponents=length(Xsys.Cnames);
% Minimal cut-sets
Cmcs = {1:length(Xsys.Cnames)};


for k=1:2:length(varargin)
    switch lower(varargin{k})
        case ('ccutset')
            % User define cut set
            Cmcs=varargin{k+1};
        case ('xcutset')
            % User define cut set
            Xcutset=varargin{k+1};
            
            for ics=1:length(Xcutset)
                Cmcs(ics)=Xcutset(ics).VcutsetIndex;
            end
        case ('mpf2')
            Mpf2=varargin{k+1};
        case ('vpf')
            Vpf=varargin{k+1};
        case 'lfirstorder'
            LfirstOrder=varargin{k+1};
        otherwise
            error('openCOSSAN:reliability:SystemReliabiliy:bounds',...
                [varargin{k} ' is not a valid FieldName'])
    end
end

if ~exist('Xcutset','var')
    for ics=1:length(Cmcs)
        Xcutset(ics)=CutSet('VcutsetIndex',Cmcs{ics},'XFaultTree',Xsys.XFaultTree);
    end
end

%% Check the minimal cut set

Vlowerbound=zeros(length(Cmcs),1);
Vupperbound=zeros(length(Cmcs),1);


% Collect the failure probabilities of the basic events
if ~exist('Vpf','var')
    Vpf=zeros(Ncomponents,1);
    if isempty(Xsys.XfailureProbability)
        % Compute the failure probability for each basic event (FORM)
        for n=1:Ncomponents
            beta=Xsys.XdesignPoints{n}.ReliabilityIndex;
            Vpf(n)=normpdf(beta);
        end
    else
        % Use the failure probability for each basic event
        for n=1:Ncomponents
            Vpf(n)=Xsys.XfailureProbability(n).pfhat;
        end
    end
end

if ~LfirstOrder
    if ~exist('Mpf2','var')
        Mpf2=zeros(Ncomponents);
        % Compute the failure probability associate to the intersection of
        % two (linear) limit state function
        for nouter=1:Ncomponents
            for ninner=nouter+1:Ncomponents
                [~, Mpf2(nouter,ninner)]  = Xsys.pfLinearIntersection('Ccutset',{[nouter ninner]});
            end
        end
    end
end

for ics=1:length(Cmcs)
    Vindex=Cmcs{ics};

    Vpfcutset=Vpf(Vindex);
    if LfirstOrder       
        [Xcutset(ics) Vlowerbound(ics) Vupperbound(ics)] = ...
            Xcutset(ics).computeBounds('Vpf',Vpfcutset,'LfirstOrder',LfirstOrder);
    else
        Mpf2cutset=zeros(length(Vpfcutset));
        
        for nout=1:length(Vpfcutset)
            for nin=nout+1:length(Vpfcutset)
                Mpf2cutset(nout,nin)= Mpf2(Vindex(nout),Vindex(nin));
            end
        end
        
        [Xcutset(ics) Vlowerbound(ics) Vupperbound(ics)] = ...
            Xcutset(ics).computeBounds('Vpf',Vpfcutset,'Mpf2',Mpf2cutset);
    end
    
end


%% Export data
varargout{1}=Vlowerbound;
varargout{2}=Vupperbound;
