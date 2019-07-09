function Xcutset  = computeBounds(Xcutset,varargin)
% COMPUTEBOUNDS  This method computes the upper and lower bounds of the
% probability of failure of the CutSet based on the Ditlevsen approximation
% [DIT1973]. By definition, s cutset represents a parallel system (i.e. the
% failure occurs if all the components fail).
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
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/computeBounds@CutSet
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

Vpf=Xcutset.VfailureProbabilityEvents;
Mpf2=Xcutset.Mpf2;

%% Process inputs
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case {'vpf'}
            Vpf=varargin{k+1};
        case {'mpf2'}
            % If it is provided the second order bounds are computed
            Mpf2=varargin{k+1};
        otherwise
            error('openCOSSAN:output:CutSet:computeBounds',...
                 'Property name %s is not valid ',varargin{k});
    end
end

%% Check inputs
assert(logical(exist('Vpf','var')),...
    'openCOSSAN:CutSet:computeBounds',...
    'The failure probability of each base event must be provided using the Property Name Vpf')

assert(length(Vpf)==length(Xcutset.VcutsetIndex), ...
    'openCOSSAN:CutSet:computeBounds',...
    strcat('The length of the Vpf (%i) must be equal to the number of events', ...
        ' defined in the cut-set (%i)'),length(Vpf),length(Xcutset.VcutsetIndex));

if isempty(Mpf2)
    %% Compute first order bounds of a Parallel system
    % Lower bound (
    Xcutset.lowerBound=0;
    % Upper bound
    Xcutset.upperBound=min(Vpf);
else
    
    assert(size(Mpf2,1)==length(Xcutset.VcutsetIndex) && size(Mpf2,2)==length(Xcutset.VcutsetIndex),...
        'openCOSSAN:CutSet:computeBounds',...
         strcat('Mpf2 must be a square matrix equal to the number of events', ...
            ' defined in the cut-set (%i)'),length(Xcutset.VcutsetIndex));

    %% Compute second order bounds
    % Lower bound
    Vpdunion=Vpf(1);
    for n=2:length(Xcutset.VcutsetIndex)
        Vpdunion=Vpdunion+max((Vpf(n)-sum(Mpf2(1:n-1,n))),0);
    end
    
    Xcutset.lowerBound=Vpdunion;
    
    % Upper bound
    Vpdunion=0;
    for n=2:length(Xcutset.VcutsetIndex)
        Vpdunion=Vpdunion+max(Mpf2(1:n-1,n));
    end
    Xcutset.upperBound=sum(Vpf)-Vpdunion;
end

%% Export data
varargout{1}=Xcutset.lowerBound;
varargout{2}=Xcutset.upperBound;

