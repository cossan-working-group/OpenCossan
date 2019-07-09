classdef RandomVariableSet < opencossan.common.CossanObject
    %RANDOMVARIABLESET   Constructs object RandomVariableSet
    
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
    
    properties (SetAccess = private, Hidden)
        NatafModel;
    end
    
    properties (SetAccess = private)
        % Array of the RandomVariable objects in the RandomVariableSet
        Members(1,:) opencossan.common.inputs.random.RandomVariable
        % Names of the RandomVariable objects as an array of Strings
        Names(1,:) string {mustBeUnique}                            
        % Correation matrix in physical space
        Correlation(:,:) double {mustBeValidCorrelationMatrix} = 1
        % Covariance matrix in physical space
        Covariance(:,:) double {mustBeValidCovarianceMatrix} = 1
    end
    
    properties (Dependent)
        Nrv; % Number of RandomVariable defined in the RandomVariableSet
    end
    
    methods
        function obj = RandomVariableSet(varargin)
            % RANDOMVARIABLESET Create a new RandomVariableSet
            %
            % obj = RandomVariableSet('members',[rv1, rv2], 'names',
            % ["RV1", "RV2"], 'correlation', corr) will create a new
            % RandomVariableSet with the Members rv1 and rv2, the Names
            % "RV1" and "RV2" and the Correlation set to corr.
            %
            % Correlation can be set by passing a correlation matrix or a
            % covariance matrix. You can not pass both at the same time.
            if nargin == 0
                super_args = {};
            else
                [required, varargin] = opencossan.common.utilities.parseRequiredNameValuePairs(...
                    ["members", "names"], varargin{:});
                [optional, super_args] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                    ["Correlation", "Covariance"],{[],[]}, varargin{:});
            end
            
            obj@opencossan.common.CossanObject(super_args{:});
            
            if nargin > 0
                obj.Members = required.members;
                obj.Names = required.names;
                
                obj.Correlation = expandTriangularMatrix(optional.correlation);
                obj.Covariance = expandTriangularMatrix(optional.covariance);
                
                assert(numel(obj.Names) == numel(obj.Members),...
                    'RandomVariableSet:IllegalArguments',...
                    'If Names is specified, the size must match Members');
                
                assert(~(~isempty(obj.Correlation) && ~isempty(obj.Covariance)),...
                    'RandomVariableSet:IllegalArguments',...
                    'Cannot specify both correlation and covariance matrix');
                
                if ~isempty(obj.Correlation)
                    std = obj.getStd();
                    obj.Covariance = std*std' .* obj.Correlation;
                elseif ~isempty(obj.Covariance)
                    [obj.Correlation, ~] = corrcov(obj.Covariance);
                else
                    obj.Correlation = eye(numel(required.members));
                end
                
                if ~obj.isIndependent()
                    obj.NatafModel = opencossan.common.inputs.random.NatafModel(obj);
                end
            end
        end
        
        means = getMean(obj,Names)
        stds = getStd(obj,Names)
        covs = getCoV(obj,Names)
        shifts = getShift(obj,Names)
        bounds = getBounds(obj,Names)
        InfoTable = getRVInfo(obj,Names)
        samples = sample(obj,varargin)
        MS = map2stdnorm(obj,varargin)
        mx = map2physical(obj,varargin)
        varargout = evalpdf(obj,varargin)
        Vout = pdfRatio(obj,varargin)                        % Computes the ratio between two points of the pdf
        MX = cdf2physical(obj,varargin)
        MS = cdf2stdnorm(obj,varargin)
        MU = physical2cdf(obj,varargin)
        MU = stdnorm2cdf(obj,varargin)
        
        function outdata = get.Nrv(obj)
            outdata = length(obj.Members);
        end
        
        function bool = isIndependent(obj)
            bool = all(all(obj.Correlation == eye(size(obj.Correlation))));
        end
    end
    
    methods (Static)
        function obj = fromIidRandomVariables(rv,n,varargin)
            import opencossan.common.inputs.random.RandomVariableSet
            p = inputParser;
            p.FunctionName = 'opencossan.common.inputs.random.RandomVariableSet.fromIidRandomVariables';
            p.addRequired('rv')
            p.addRequired('n');
            
            p.parse(rv,n);
            
            [optional, varargin] = opencossan.common.utilities.parseOptionalNameValuePairs(...
                "basename", {"RV"}, varargin{:});
            
            members(1:p.Results.n) = p.Results.rv;
            
            names = strings(1,n);
            for i = 1:p.Results.n
                names(i) = sprintf("%s_%d", optional.basename, i);
            end
            
            varargin = [varargin {'members', members, 'names', names}];
            obj = RandomVariableSet(varargin{:});
        end
    end
end

function mustBeSquare(A)
    if size(A,1) ~= size(A,2)
        error('OpenCossan:ValidationError','Matrix must be square');
    end
end

function mustBeSymmetric(A)
    if ~issymmetric(A)
        error('OpenCossan:ValidationError','Matrix must be symmetric');
    end
end

function mustBePositiveDefinite(A)
    if ~all(eig(A) >= 0)
        error('OpenCossan:ValidationError','Matrix must be positive-definite');
    end
end

function mustBeValidCorrelationMatrix(A)
    mustBeSquare(A);
    mustBeSymmetric(A);
    mustBePositiveDefinite(A);
    mustBeGreaterThanOrEqual(A,-1);
    mustBeLessThanOrEqual(A,1);
    if ~all(diag(A) == 1)
        error('OpenCossan:ValidationError',...
            'Diagonal entries must be equal to 1');
    end
end

function mustBeValidCovarianceMatrix(A)
    mustBeSquare(A);
    mustBeSymmetric(A);
    mustBePositiveDefinite(A);
end

function mustBeUnique(A)
    if numel(unique(A)) ~= numel(A)
        error('OpenCossan:ValidationError','Entries must be unique');
    end
end

function A = expandTriangularMatrix(A)
    if xor(istriu(A),istril(A))
        A = (A+A') - eye(size(A,1)).*diag(A);
    end
end
