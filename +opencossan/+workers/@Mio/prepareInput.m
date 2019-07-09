function PinputMio=prepareInput(Xobj,varargin)
%PREPAREINPUT this method prepare the input for the evaluation of the Mio
%object. The method is usually called by the APPLY method of Evaluation.
%
% The methods takes one or two inputs
%
% The first input is a structure of input value (Pinput)
% The second optional input is a SimulationData object
%
% See Also: http://cossan.co.uk/wiki/index.php/prepareInput@Mio
%
% Author: Edoardo Patelli
% Institute for Risk and Uncertainty, University of Liverpool, UK
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

%%  In case the argument Pinput is an Input object
TinputSolver=varargin{1};

assert(isa(TinputSolver,'struct'),'OpenCossan:Mio:prepareInput:wrongInput', ...
    'The method prepareInput requires a structure first argument. \n Provided type %s',class(TinputSolver))

if Xobj.Liostructure
    PinputMio=TinputSolver;
elseif Xobj.Liomatrix
    PinputMio = zeros(length(TinputSolver),length(Xobj.Cinputnames));
    if nargin==3 
        % A simulationData object is available and the inputs for the Mio are extracted from this object 
        XSimOut=varargin{2};
        switch class(Pinput)
            case 'Samples'
                % Check variables present in the SimulationData object
                CmioInputNames=Xob.Cinputnames;
                Vindout=ismember(CmioInputNames,XSimOut.Cnames);
                % Extract quantity of interest
                MoutOUT=XSimOut.getValues('Cnames',CmioInputNames(Vindout));
                
                % Process Inputs
                % Extract Matrix
                MoutIN  = Pinput.MsamplesPhysicalSpace;
                Vindinput=ismember(CmioInputNames,Pinput.Cnames);
                
                % Reorder Matrix
                PinputMio=[MoutIN(:,Vindinput) MoutOUT];
            case 'Input'
                % Check variables present in the SimulationData object
                CmioInputNames=Xobj.Cinputnames;
                Vindout=ismember(CmioInputNames,XSimOut.Cnames);
                % Extract quantity of interest
                MoutOUT=XSimOut.getValues('Cnames',CmioInputNames(Vindout));
                
                % Process Inputs
                Vindinput=ismember(CmioInputNames,Pinput.Cnames);
                MoutIN  = Pinput.getValues('Cnames',CmioInputNames(Vindinput));
                
                % Reorder Matrix
                PinputMio(:,Vindout) = MoutOUT;
                PinputMio(:,Vindinput)= MoutIN;
            case 'struct'
                % No conversion required
                PinputMio=TinputSolver;
        end
    else
        % The input is extracted only from the Input structure 
        PinputMio=TinputSolver;
    end
else
    %TODO: INPUT/OUTPUT separate matrix
    PinputMio=TinputSolver;
end
