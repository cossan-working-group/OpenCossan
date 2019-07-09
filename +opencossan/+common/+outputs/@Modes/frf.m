function Tfrf = frf(Xmodes,varargin)
%computes frequency response functions
%
%   MANDATORY ARGUMENTS:
%
%   - Xmodes:       modes object
%
%   MANDATORY ARGUMENTS
%
%   - Stype:        'acc' for accelerations
%                   'vel' for velocities
%                   'disp' for displacements
%   - Vforce:       force vector (in modal space)
%   - Vzeta:        modal damping ratios
%   - Vexcitationfrequency:   vector with frequency values of excitation
%
%
%   OPTIONAL ARGUMENTS
%
%   - Vdofs:        Vector with DOFs at which FRFs will be evaluated
%                   (refers to the row number of the matrix Mphi)
%                   (default: structural response of all DOFs will be evaluated)
%
%   EXAMPLE:
%
%   Tfrf = frf('Xmodes',Xmodes,'Vforce',F,'Vfreqrange',Vfreq,'Vdofs',Vd)
%   produces a structure Tfrf with excitation range and FRF, where the FRF
%   of DOF xy is stored in the field VFRF_xy
%
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2008 IfM
% =====================================================
% BG,  13-aug-2008 
% =====================================================


%% INPUT ARGUMENT EVALUATION

Nargin = nargin/2;
for i = 1:Nargin
    Sarg = varargin{1+(i-1)*2};
    argval = varargin{2+(i-1)*2};
    eval([Sarg '= argval;']);
end;

if length(Xmodes.Vlambda) ~= length(Vzeta)
    error('openCOSSAN:modes:frf:WrongInput','number of eingenvalues and number of modal damping ratios are not the same');
end

if ~exist('Vdofs','var')
    Vdofs = 1:size(Xmodes.MPhi,1);
end
if ~exist('Sfrftype','var')
    error('openCOSSAN:modes:frf:WrongInput','type of FRFs to be computed not specified');
end
if ~exist('Vforce','var')
    error('openCOSSAN:modes:frf:WrongInput','Force vector not specified');
end
if ~exist('Vexcitationfrequency','var')
    error('openCOSSAN:modes:frf:WrongInput','Frequency of excitation not specified');
end
if ~exist('Vzeta','var')
    error('openCOSSAN:modes:frf:WrongInput','modal damping ratios not specified');
end


%% INITIALIZATION

Vomega = Vexcitationfrequency*2*pi;   % frequency range

Tfrf = struct;              % output structure  

if strcmp(Sfrftype,'acc')  % check if QOI is acceleration
    Npower = 2;
end
if strcmp(Sfrftype,'vel')  % check if QOI is velocity
    Npower = 1;
end
if strcmp(Sfrftype,'disp') % check if QOI is displacement
    Npower = 0;
end

Cfieldname = cell(1,length(Vdofs));     % initialize fieldnames
for i=1:length(Vdofs)   % fieldnames for output vectore are FRF_i
    Cfieldname{i} = ['FRF_' num2str(Vdofs(i))];  
end

%% COMPUTE FRFs


opencossan.OpenCossan.cossanDisp('FRF computation in progress...');

for iDOF = 1:length(Vdofs)
    Tfrf.(Cfieldname{iDOF}) = zeros(1,length(Vexcitationfrequency));  %initialization for response vector of each DOF
    for i=1:length(Vomega)
        Tfrf.(Cfieldname{iDOF})(i) = sum(((Vomega(i).^Npower)*Xmodes.MPhi(Vdofs(iDOF),:).*Vforce)'./ ...
            (-Vomega(i)^2+Xmodes.Vlambda+2*sqrt(-1)*Vzeta.*sqrt(Xmodes.Vlambda)*Vomega(i)));      
    end
    if Npower == 2  % for accelerations the results has to be multiplied with -1
        Tfrf.(Cfieldname{iDOF}) = -Tfrf.(Cfieldname{iDOF});
    end
end
Tfrf.Vexcitationfrequency = Vexcitationfrequency;
Tfrf.Stype = Sfrftype;
return;
