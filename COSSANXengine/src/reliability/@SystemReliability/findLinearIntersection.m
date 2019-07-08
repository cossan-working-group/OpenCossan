function [varargout] = findLinearIntersection(Xsys,varargin)
% FINDLINEARINTERSECTION
%   This function identify the intersection between LINEAR limit state
%   functions that form the minimal cut-set. Hence, this method must be used to
%   identify the DesignPoint of a parallel system. 
%
%   The intersection between arbitrary cut-set can be also estimated
%   passing as an optional argument the cut-set
%
% Input arguments:
%   - Ccutset:  Cell array that define the cut-sets. Each number define the
%   basic event of the cut-set defined in the FaultTree.
%   - Vbeta:      Vector of the reliability indexes of the basic event. The
%                 length of the vector Vbeta must be equal to the length of
%                 Vcutset
%   - Malpha:     array of importat direction of the basic events.
%
%  Ouput arguments
%  - varargout{1}: a CutSet object
%  - varargout{2}: the identified design point
%  - varargout{1}: Matrices that contains the coordinates of the
%                  intersection points
%
% See Also:
% http://cossan.cfd.liv.ac.uk/wiki/index.php/findLinearIntersection@SystemReliability 
%
% Copyright~1993-2011, COSSAN Working Group,University of Innsbruck, Austria
% Author: Edoardo-Patelli

%% Initialize variables
% Retrieve important direction (Malpha) and the design point (MdesignPoint)
% from the SystemReliability object
tolerance=1e-2;
Ndimension=Xsys.Xmodel.Xinput.NrandomVariables;
Ncomponents=length(Xsys.XdesignPoints);
if ~isempty(Xsys.XdesignPoints)
    % The variable should be always oredered by columns
    Malpha=zeros(Ncomponents,Ndimension);
    VbetaMembers=zeros(1,Ncomponents);
    % populate Malpha and MdesignPoint
    for idp=1:Ncomponents
        Malpha(idp,:)=Xsys.XdesignPoints{idp}.VDirectionDesignPointStdNormal;
        VbetaMembers(idp)=Xsys.XdesignPoints{idp}.ReliabilityIndex;
    end
else
    Malpha=[];
    VbetaMembers=[];
end


for k=1:2:length(varargin)
    switch lower(varargin{k})
        case ('ccutset')
            % User define cut set
            Cmcs=varargin{k+1};
        case ('malpha')
            Malpha=varargin{k+1};
        case ('vbeta')
            VbetaMembers=varargin{k+1};
        case 'tolerance'
            tolerance=varargin{k+1};
        otherwise
            error('openCOSSAN:reliability:SystemReliabiliy:findLinearIntersection',...
                [varargin{k} ' is not a valid FieldName'])
    end
end

if ~exist('Cmcs','var')
    Cmcs=getMinimalCutSets(Xsys);
end

% check input
if isempty(Malpha) || isempty(VbetaMembers)
    error('openCOSSAN:reliability:SystemReliabiliy:findLinearIntersection',...
        'Reliability indices and the important direction for the basic event must be defined')
end

Mintersection=zeros(length(Cmcs),Ndimension);

%% Loop over the number of minimal cut-sets
for ics=1:length(Cmcs)
    % Number of limit state functions
    Nevents=length(Cmcs{ics});
    VcutsetIndex=Cmcs{ics};
    % collection unit vector of the cut-set
    u_dir=zeros(Nevents,Ndimension);
    rel_index=zeros(Nevents,1);
    for iev=1:Nevents
        u_dir(iev,:)=Malpha(VcutsetIndex(iev),:);
        rel_index(iev)=VbetaMembers(VcutsetIndex(iev));
    end
    % collection of beta values
    
    % Identify the reliability index and the direction of each performance
    % function of the minimal cut set
    
    % rel_index=Pbetamembers(ipoint,:)';
    
    % Number of dimensions
    %% Apply svd for systematic search
    i_activ = zeros(Nevents,1);
    n_activ = 1;
    [~,j] = max(rel_index);
    i_activ(1) = j;
    A = zeros(Nevents,Ndimension);
    b = zeros(Nevents,1);
    [x,yd] = dp_loop(u_dir,rel_index,A,b,-rel_index,n_activ,i_activ);
    
    if(min(yd)<-tolerance)
        i_act = find(yd<-tolerance);
        n_activ = numel(i_act);
        i_activ(1:n_activ) = i_act;
        x = dp_loop(u_dir,rel_index,A,b,yd,n_activ,i_activ);
        %error('stop')
    end
    Mintersection(ics,:)=x;
    Xdp(ics)=DesignPoint('Vdesignpointstdnormal',x','Xinput',Xsys.Xmodel.Xinput); %#ok<AGROW>
    
    if isempty(Xsys.XFaultTree)
        Xcutset(ics)=CutSet('VcutsetIndex',VcutsetIndex,...
            'XDesignPoint',Xdp(ics));%#ok<AGROW>
    else
        Xcutset(ics)=CutSet('XFaultTree',Xsys.XFaultTree,'VcutsetIndex',VcutsetIndex,...
            'XDesignPoint',Xdp); %#ok<AGROW>
    end
end

%% Export Results
% Create a cut set
varargout{1}=Xcutset;
varargout{2}=Xdp;
varargout{3}=Mintersection;


end

function [x,yd] = dp_loop(u_dir,rel_index,A,b,yd,n_activ,i_activ)
%

while(min(yd)<0 && n_activ<=size(u_dir,2))
    A(1:n_activ,:) = u_dir(i_activ(1:n_activ),:);
    b(1:n_activ) = rel_index(i_activ(1:n_activ));
    
    [u,s,v] = svd(A(1:n_activ,:),'econ');
    sv = diag(s);
    dim = find(sv>0, 1, 'last' );
    svi = sv(1:dim).^(-1);
    inv_s = diag(svi);
    x = v(:,1:dim)*inv_s*u(:,1:dim)'*b(1:n_activ);
    yd = u_dir*x-rel_index;
    
    [y,j] = min(yd);
    if(y<0)
        n_activ = n_activ+1;
        i_activ(n_activ) = j;
    end
end
end   % end of function dp_loop
