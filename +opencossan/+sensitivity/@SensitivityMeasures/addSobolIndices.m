function Xobj = addSobolIndices(Xobj,varargin)
% ADDSOBOLINDICES This method adds Sobol' indices to the SensitivityMeasures
% object
%
% OPTIONAL ARGUMENTS:
%   - CsobolComponentsIndices       Cell array of the indices of the Sobol'
%                                   measures
%   - VsobolIndices                 Vector of values of Sobol indices
%   - VsobolIndicesCoV              Vector of the CoV of the estimator of the  values of Sobol indices
%
%   OUTPUT ARGUMENTS:
%   - Xobj : SensitivityMeasures object
%
%   EXAMPLE:
%
%   Xobj = Xobj.addSobolIndices('CsobolComponentsIndices',{[2 2]; [4]},'VsobolIndices',[0.5 0.7])
%
% See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/addSobolIndices@SensitivityMeasures
%
% Copyright~1993-2011, COSSAN Working Group, University of Innsbruck, Austria$
% Author: Edoardo Patelli
    
% Initialize variable
VsobolIndicesCoV=[];

%% Validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

%% Add fields
for k=1:2:length(varargin),
    switch lower(varargin{k})
        case {'csobolcomponentsindices','corder'}
            % Define indices
            CsobolComponentsIndices=varargin{k+1};
        case 'vsobolindices'
            VsobolIndices=varargin{k+1};
        case 'vsobolindicescov'
            VsobolIndicesCoV=varargin{k+1};
        otherwise
                warning('openCOSSAN:output:SensitivityMeasures',...
                    ['PropertyName ' varargin{k} ' ignored']);
    end
end

assert(logical(exist('CsobolComponentsIndices','var')), ...
       'openCOSSAN:output:SensitivityMeasures', ...
        'The PropertyName CsobolComponentsIndices is required');  
    
assert(logical(exist('VsobolIndices','var')), ...
       'openCOSSAN:output:SensitivityMeasures', ...
        'The PropertyName VsobolIndices is required');  
    
    
%% Check consistency of input parameters
Ninput=length(Xobj.CinputNames);
for n=1:length(CsobolComponentsIndices)
    assert( length(CsobolComponentsIndices{n})<= Ninput, ...   
        'openCOSSAN:output:SensitivityMeasures', ...
        ['It is not possible to define a Sobol'' indices of order ' ...
        num2str(length(CsobolComponentsIndices{n})) ' with only ' ...
        num2str(Ninput) ' input factors']);
    
    assert( max(CsobolComponentsIndices{n})<= Ninput, ...   
        'openCOSSAN:output:SensitivityMeasures', ...
        ['CsobolComponentsIndices{' num2str(n) '} refers to a component #' ...
        num2str(max(CsobolComponentsIndices{n})) ' but CinputNames has only ' ...
        num2str(Ninput) ' input factors']);
    
    if length(CsobolComponentsIndices{n})==1
        warining('openCOSSAN:output:SensitivityMeasures', ...
        ['CsobolComponentsIndices{' num2str(n) '} is a First Order Sobol'' indices.\n' ...
        ' Please use VsobolFirstIndices to store this value']);
    end
    
end

assert(length(CsobolComponentsIndices)==length(VsobolIndices),...    
        'openCOSSAN:output:SensitivityMeasures',...
        ['Numer of indices defined (' num2str(length(CsobolComponentsIndices)) ...
        ') do not correspond to the number of Sobol'' indices (' ...
        num2str(length(VsobolIndices)) ')']);

if ~isempty(Xobj.VsobolIndicesCoV)    
assert(length(CsobolComponentsIndices)==length(VsobolIndicesCoV),...    
        'openCOSSAN:output:SensitivityMeasures',...
        ['Number of indices defined (' num2str(length(CsobolComponentsIndices)) ...
        ') do not correspond to the number of estimation error of  the Sobol'' indices (' ...
        num2str(length(VsobolIndicesCoV)) ')']);
end
    
    
%% add Sobol' indices
if size(CsobolComponentsIndices,2)==1
    CsobolComponentsIndices=transpose(CsobolComponentsIndices);
end

if size(VsobolIndices,2)==1
    VsobolIndices=transpose(VsobolIndices);
end

if size(VsobolIndices,2)==1
    VsobolIndicesCoV=transpose(VsobolIndicesCoV);
end

Xobj.CsobolComponentsIndices=[Xobj.CsobolComponentsIndices CsobolComponentsIndices];
Xobj.VsobolIndices=[Xobj.VsobolIndices VsobolIndices];
Xobj.VsobolIndicesCoV=[Xobj.VsobolIndicesCoV VsobolIndicesCoV];



