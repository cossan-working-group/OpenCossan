classdef Sensitivity
    %SENSITIVITY Sensitivity Toolbox for OpenCossan
    % This is an abstract class for creating sensitivity objects
    % See also: https://cossan.co.uk/wiki/index.php/@Sensitivity
    %
    % Author: Edoardo Patelli
    % email address: openengine@cossan.co.uk
    % Website: http://www.cossan.co.uk
    
    % =====================================================================
    % This file is part of openCOSSAN.  The open general purpose matlab
    % toolbox for numerical analysis, risk and uncertainty quantification.
    %
    % openCOSSAN is free software: you can redistribute it and/or modify
    % it under the terms of the GNU General Public License as published by
    % the Free Software Foundation, either version 3 of the License.
    %
    % openCOSSAN is distributed in the hope that it will be useful,
    % but WITHOUT ANY WARRANTY; without even the implied warranty of
    % MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    % GNU General Public License for more details.
    %
    %  You should have received a copy of the GNU General Public License
    %  along with openCOSSAN.  If not, see <http://www.gnu.org/licenses/>.
    % =====================================================================
    
    properties (SetAccess=protected,GetAccess=public)
        Sdescription
        Xtarget
        LperformanceFunction
        Cinputnames={};
        Coutputnames={};
        Xinput
    end
    
    properties (SetAccess=protected,GetAccess=public)
        Sevaluatedobjectname='N/A'
        Xsamples0
        fx0
    end    
       
    methods (Abstract)
        display(Xobj)                   % Show summary of Sensitivity object
        varargout=computeIndices(Xobj)  % Perform Sensitivity on the Target object
        Xobj=validateSettings(Xobj)     % Validate settings 
    end
    
    methods (Access=protected)
        Xobj=addModel(Xobj,Xtarget) 
        setAnalysisName(Xobj)
    end
    
end

