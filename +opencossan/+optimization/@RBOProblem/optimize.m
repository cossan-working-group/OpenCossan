function  [Xopt, varargout]  = optimize(Xobj,varargin)
%OPTIMIZE This method is a common interface for different reliability based
%optimization approaches. 
%
% See also: https://cossan.co.uk/wiki/index.php/Optimize@RBOproblem
%
% Copyright  1993-2018 Cossan Working Group
% Author: Edoardo Patelli
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

%% Process inputs
% validate input arguments
OpenCossan.validateCossanInputs(varargin{:})

% Process arguments
for k=1:2:length(varargin)
    switch lower(varargin{k})
        case 'smetamodeltype'
            Xobj.SmetamodelType=varargin{k+1};
        case 'xsimulator'
            Xobj.Xsimulator=varargin{k+1};
        case 'cxsimulator'
            Xobj.Xsimulator=varargin{k+1}{1};
        case 'nmaxlocalrboiterations'
            Xobj.NmaxLocalRBOIteration=varargin{k+1};
        case 'vperturbation'
            Xobj.VperturbationSize=varargin{k+1};
    end
end

if ~isempty(Xobj.VperturbationSize) || ~isempty(Xobj.NmaxLocalRBOIteration)
    %% Perform Optimization Using local Meta-Model
    [Xopt, XSimOutput]= optimizeLocalMetaModel(Xobj,varargin{:});
else
    if ~isempty(Xobj.SmetamodelType)
       %% Perform Optimization Using global Meta-Model
        [Xopt, XSimOutput]= optimizeGlobalMetaModel(Xobj,varargin{:});
    else
       %% Perform Optimization Using direct approach 
       [Xopt, XSimOutput]= optimizeDirectApproach(Xobj,varargin{:});
    end   
end

if nargout>1
    varargout{1}=XSimOutput;
end

end % of optimize
