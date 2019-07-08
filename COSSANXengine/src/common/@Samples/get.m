function Poutput = get(Xs,varargin)
%GET retrieves some data from object Xs
%   
%   The method GET takes one required input, an object Samples.
%   The method then takes a token value.  This
%   token value get properties of the object Samples.
%
%   The function GET returns data in different formats depending on the
%   property being retrieved
%
%   MANDATORY ARGUMENTS:
%
%    - Xs   : object of the class Samples
%
%   OPTIONAL ARGUMENTS:
%
%   - Tsamples : by passing this argument, a structure is returned
%   that contains the samples (in the physical
%   space) in a structure form, where the name of each field is the name of
%   each random variable
%
%   OUTPUT
%
%    According to specified property
%
%  EXAMPLE:
%   Pout  = get(Xs,'PropertyName') retrieves
%       PropertyValue
%
% =====================================================
% COSSAN - COmputational Stochastic Structural Analysis
% IfM, Chair of Engineering Mechanics, LFU Innsbruck, A
% Copyright 1993-2010 IfM
% =====================================================

%% 1.   Process arguments passed by the user
for k=1:2:length(varargin)
    switch lower(varargin{k}),
        %1.1.   Samples in physical space including names
        case {'tsamples'},
            warning('openCOSSAN:Samples:get',...
                'Please use dependet field Tsamples to retrive samples in a structure form ');
            % Preallocation of the memory
            Poutput = cell2struct(num2cell(Xs.MsamplesPhysicalSpace), Xs.CnamesRandomVariable, 2);
 
        %1.2.   Other cases
        case {'msamplesphysicalspace','msamplesatandardnormalapace',...
                'msampleshypercube','mdoedesignvariables','msamplesepistemicspace','msamplesunithypercube'}
            Poutput = Xs.(varargin{k});
        otherwise
            Poutput = [];
            warning('openCOSSAN:Samples:get',...
                ['argument ' varargin{k} ' has been ignored']);
    end
end

return
