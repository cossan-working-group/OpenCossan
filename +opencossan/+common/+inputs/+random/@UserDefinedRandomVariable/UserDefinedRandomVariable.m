classdef UserDefinedRandomVariable < opencossan.common.inputs.random.RandomVariable
    %USERDEFRANDOMVARIABLE is a subclass of RANDOMVARIABLE. This class creates
    %user defined random variables.
    %
    % COSSAN = opencossan.OpenCossan.getInstance()
    %
    % See also RANDOMVARIABLE
    
    %{
    This file is part of OpenCossan <https://cossan.co.uk>.
    Copyright (C) 2006-2018 COSSAN WORKING GROUP

    OpenCossan is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or,
    (at your option) any later version.

    OpenCossan is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with OpenCossan. If not, see <http://www.gnu.org/licenses/>.
    %}
    properties
        cdf(1,:)             % Values of the cdf at the support points
        pdf(1,:)             % Values of the pdf at the support points
        Bounds(1,2) double {mustBeNumeric} = [-Inf;Inf];
        Smoothing(1,1) logical = true   %Flag for distribution smoothing, ecdf used otherwise
    end
    
    properties (Access=private)
        data_(1,:)
        support_(1,:)
    end
    
    properties (SetAccess=private,Hidden)
        NsampleFit=5000;    % samples used to estimate mean and std of the UserDefRandomVariable
        NsupportPoints=100; % Number of points used to estimated the cdf/pdf
    end
    
    properties (Dependent)
        data
        Mean
        Std
        support
    end
    
    methods
        function obj = UserDefinedRandomVariable(varargin)
            %USERDEFINEDRANDOMVARIABLE is a subclass of RANDOMVARIABLE. This class creates
            %user defined random variables.
            %
            %
            % See Also: RandomVariable https://cossan.co.uk/wiki LAST
            %
            % Options: User can either proivde:
            %           1. Samples -> paretotails fit with kernel smoothing
            %           2. cdf and support -> inverse cdf sampling
            %           3. pdf and support -> pdf integrated and icdf
            %           sampling
            %           Bounds can be defined, random number generator
            %           truncated
            %  Copyright 1993-2011, COSSAN Working Group
            %  University of Innsbruck, Austria
            
            % Notes for development:
            % Remove predefined distribution
            if nargin == 0
                super_args = {};
            else
                [results, super_args] = ...
                    opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["data", "cdf", "pdf", "support", "bounds", "smoothing"], ...
                    {[], [], [], [], [-inf, inf], true}, varargin{:});
                checkInputs(results);
            end
            obj@opencossan.common.inputs.random.RandomVariable(super_args{:});
            
            if nargin > 0
                % Class properties
                obj.data_ = results.data;
                obj.cdf = results.cdf;
                obj.pdf = results.pdf;
                obj.support_ = results.support;
                obj.Bounds = results.bounds;
                obj.Smoothing = results.smoothing;
                
                check_1 = ~isempty(obj.data);
                check_2 = ~isempty(obj.cdf);
                check_3 = ~isempty(obj.pdf);
                
                if check_1
                    obj = from_realizations(obj);
                elseif check_2
                    obj = from_cdf(obj);
                elseif check_3
                    obj = from_pdf(obj);
                end
            end
        end
        
        function obj = set.support(obj,value)
            obj.support_ = value;
        end
        
        function support=get.support(obj)
            support = obj.support_;
        end
        
        function obj = set.data(obj,values)
            obj.data_ = values;
        end
        
        function data = get.data(obj)
            data = obj.data_;
        end
        
        function pdf=get.pdf(obj)
            pdf=obj.pdf;
        end
        
        function Vcdf=get.cdf(obj)
            Vcdf=obj.cdf;
        end
        
        function value = get.Mean(obj)
            value = mean(obj.data);
        end
        
        function value = get.Std(obj)
            value = std(obj.data);
        end
        
        % Transformations
        function VX = cdf2physical(obj,VU)
            %CDF2PHYSICAL Inverse normal cumulative distribution function.
            % VX = cdf2physical(obj,VX) returns the inverse cdf of the
            % normal distribution, evaluated at the values VU.
            VX = interp1(obj.cdf,obj.support,VU,[],'extrap');
        end
        
        function VU = physical2cdf(obj,VX)
            %PHYSICAL2CDF Normal cumulative distribution function.
            % VU = physical2cdf(obj,VX) returns the cdf of the normal
            % distribution, evaluated at the values VX.
            VU = interp1(obj.support,obj.cdf,VX,[],'extrap');
        end
        
        function VX = map2physical(obj,VU)
            % MAP2PHYSICAL Map from standard normal into physical space.
            % VX = map2physical(obj,VU) maps the values in VU from standard
            % normal into physical space.
            %VX = VU * obj.Std + obj.Mean;
            VX = obj.cdf2physical(normcdf(VU));
        end
        
        function VU = map2stdnorm(obj,VX)
            % MAP2STDNORM Map from physical into standard normal space.
            % VU = map2stdnorm(obj,VX) maps the values in VX from physical
            % into standard normal space.
            VU = norminv(obj.physical2cdf(VX));
        end
        
        function Vpdf_vX = evalpdf(obj,Vx)
            %EVALPDF user defined random variable
            % Y = evalpdf(obj,X) returns the pdf of the normal
            % distribution, evaluated at the values X.
            Vpdf_vX = interp1(obj.support,obj.pdf,Vx,[],'extrap');
        end
        
    end
    
    methods (Access=private)
        obj = from_cdf(obj);
        obj = from_pdf(obj);
        obj = from_realizations(obj);
    end
    
    methods (Access = protected)
        function samples = getSamples(obj,size)
            samples = interp1(obj.cdf,obj.support,rand(size),[],'extrap');
        end
    end
    
    methods(Static)
        
        function fromMeanAndStd(varargin)
            % FROMMEANANDSTD Create a new object from mean and std.
            %
            % This method is not supported for the
            % UserDefinedRandomVariable. Use the constructor instead.
            ME = MException('UserDefinedRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of UserDefinedRandomVariable using the constructor.']);
            throw(ME);
        end
        
        function fit(varargin)
            % FIT Fit a random variable to data
            %
            % This method is not supported for the
            % UserDefinedRandomVariable. Use the constructor instead
            ME = MException('UserDefinedRandomVariable:UnsupportedOperation',...
                ['Unsupported operation.\n' ...
                'Create objects of UserDefinedRandomVariable using the constructor.']);
            throw(ME);
        end
        
    end
end

function checkInputs(results)

% Class input checks

C1 = ~isempty(results.data);
C2 = ~isempty(results.cdf);
C3 = ~isempty(results.pdf);
C4 = ~isempty(results.support);

assert(C1 + C2 + C3 == 1,...
    'UserDefinedRandomVariable:UnambiguousArguments', 'Only one of the following can be passed: data, pdf or cdf')
assert(C2 + C4 == 2 || ~C2,...
    'UserDefinedRandomVariable:NoSupport', 'Please provide a support with your cdf')
assert(C3 + C4 == 2 || ~C3,...
    'UserDefinedRandomVariable:NoSupport', 'Please provide a support with your pdf')

% Inputs validation
C5 = isempty(results.support) || length(unique(results.support(:,1))) == length(results.support(:,1));
C6 = issorted(results.cdf);
C7 = issorted(results.support);
C8 = length(results.cdf) == length(results.support);
C9 = length(results.pdf) == length(results.support);
C10 = issorted(results.bounds);

assert(C4 + C5 == 2 || ~C4,...
    'UserDefinedRandomVariable:SupportError', 'The support points must be unique')
assert(C4 + C7 == 2 || ~C4 ,...
    'UserDefinedRandomVariable:SupportError', 'Support must be monotonic')
assert(C2 + C6 == 2 || ~C2,...
    'UserDefinedRandomVariable:CdfError', 'cdf must be monotonic')
assert(C8 || ~C2 ,...
    'UserDefinedRandomVariable:Cdf:supportLengthsUnequal', 'cdf and support must be the same length')
assert(C9 || ~C3 ,...
    'UserDefinedRandomVariable:Pdf:supportLengthsUnequal', 'pdf and support must be the same length')
assert(C10 ,...
    'UserDefinedRandomVariable', 'Lower bound must be less than upper bound')

if C3
    pdfArea=trapz(results.support,results.pdf);
    C11 = logical( pdfArea<1+0.0001 && pdfArea>1-0.0001);
    assert(C11,...
        'UserDefinedRandomVariable:PdfError', 'pdf is not normalised, or more points needed to accurately define')    
end
end

