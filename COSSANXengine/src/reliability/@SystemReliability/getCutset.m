function Xcutset=getCutset(Xsys,varargin)
%GETCUTSET This method returs a CutSet object from the SystemReliability object
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/getCutset@SystemReliability
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

% Defailt values
Sdescription='Cutset extracted from the SystemReliability object';

%% Process inputs
OpenCossan.validateCossanInputs(varargin{:});

for k=1:2:length(varargin)
    switch lower(varargin{k})
        case ('vcutsetindex')
            % User define cut set
            VcutsetIndex=varargin{k+1};
        case ('sdescription')
            % User define cut set
            Sdescription=varargin{k+1};
        case ('xfailureprobability')
            XFailureProbability=varargin{k+1};
        otherwise
            error('openCOSSAN:SystemReliabiliy:getCutset',...
                ' %s is not a valid Property Name',varargin{k})
    end
end

assert(logical(exist('VcutsetIndex','var')),...
    'openCOSSAN:SystemReliabiliy:getCutset', 'A cut set must be defined')

% Construct the required cutset
Carguments={'Sdescription',Sdescription};
Carguments{end+1}='VcutsetIndex';
Carguments{end+1}=VcutsetIndex;

if ~isempty(Xsys.XFaultTree)
    Carguments{end+1}='XFaultTree';
    Carguments{end+1}=Xsys.XFaultTree;
end

if exist('XFailureProbability','var')
    Carguments{end+1}='XFailureProbability';
    Carguments{end+1}=XFailureProbability;
else
    if ~isempty(Xsys.XdesignPoints)
        MDesignPointStdNormalEvents=zeros(length(VcutsetIndex),length(Xsys.XdesignPoints{1}.VDesignPointStdNormal));
        for n=1:length(VcutsetIndex)
            MDesignPointStdNormalEvents(n,:)=Xsys.XdesignPoints{VcutsetIndex(n)}.VDesignPointStdNormal;
        end
        
        Carguments{end+1}='MDesignPointStdNormalEvents';
        Carguments{end+1}=MDesignPointStdNormalEvents;
    end
    
    if ~isempty(Xsys.XfailureProbability)
        Ncompontents=min(length(Xsys.XfailureProbability),length(VcutsetIndex));
        Vpf=zeros(Ncompontents,1);
        for n=1:Ncompontents
            Vpf(n)=Xsys.XfailureProbability(VcutsetIndex(n)).pfhat;
        end
        
        Carguments{end+1}='Vfailureprobabilityevents';
        Carguments{end+1}=Vpf;
    elseif ~isempty(Xsys.XdesignPoints)
        Vpf=zeros(length(VcutsetIndex),1);
        for n=1:length(VcutsetIndex)
            Vpf(n)=Xsys.XdesignPoints{VcutsetIndex(n)}.form;
        end
        Carguments{end+1}='Vfailureprobabilityevents';
        Carguments{end+1}=Vpf;
    end    
    
end

Xcutset=CutSet(Carguments{:});

