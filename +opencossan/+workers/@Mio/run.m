function [XsimOut,Poutput] = run(Xmio,Psamples)
%RUN This method evaluate the user defined script/function
%
% See Also: http://cossan.co.uk/wiki/index.php/run@Mio
%
%
% Copyright~1993-2013, COSSAN Working Group
%
% Author: Edoardo Patelli, Matteo Broggi, Marco De Angelis
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

%% Check Inputs
% Check if Psamples contains samples (if it is an Input object)
if isa(Psamples,'Input')
    assert(~isempty(Psamples.Xsamples), ...
        'openCOSSAN:Mio:run', ...
        'It is not possible to run a Mio object with an Input object with no samples')
end

%% Run the matlab script/function
if isdeployed,
    % checks whether or not the code is running in deployed mode (GUI)
    if Xmio.Lfunction,  %in case of a function, stop code
        assert(~isempty(OpenCossan.getMatlabPath),...
            'openCOSSAN:connectors:mio:run',...
            ['It is necessary to indicate the matlab installation directory '...
            'to run a mio with a function\nPlease define MatlabPath in OpenCossan']);
        [Poutput]=runFunction(Xmio,Psamples);
    else    %in case of script, continue execution
        assert(~isempty(Xmio.Sscript),...
            'openCOSSAN:connectors:mio:run',...
                ['The content of the user defined script must be copied' ...
                ' in the field Sscript in the deployed version of OpenCossan'])        
        [Poutput]=runScript(Xmio,Psamples);
    end
else
    %% in case Cossan is being runned from command line
    if Xmio.IsFunction,  
         Tinput = checkPinput(Xmio,Psamples);            
%             % Evaluate the function
            Poutput  = feval(Xmio.FunctionHandle,Tinput);
        % Run a function 
%         if strcmp(Xmio.Sformat,'structure')
%             %% Function with structure
%             % check inputs
%             Tinput = checkPinput(Xmio,Psamples);            
%             % Evaluate the function
%             Poutput  = feval(Xmio.FunctionHandle,Tinput);
%         elseif strcmp(Xmio.Sformat,'matrix')
%             %% Function with Matrix
%             % Convert the Pinput into a Matrix
%             if isa(Psamples,'double')
%                 MinputMIO=Psamples;
%             else
%                 MinputMIO = checkPinput(Xmio,Psamples);
%             end		
% 
%             % Evaluate the function
%             Poutput = feval(Xmio.FunctionHandle,MinputMIO);
%         elseif strcmp(Xmio.Sformat,'vectors')
%             %% Function with vectors
%             
%             
%         elseif strcmp(Xmio.Sformat,'table')
%             %% Function with Table
%             % Convert the Pinput into a Table 
%                 TableInputMIO = checkPinput(Xmio,Psamples);           
%             % Evaluate the function
%             Poutput = feval(Xmio.FunctionHandle,TableInputMIO);
% 
%         else
%             %% Function with multiple input and output
%             % Create Input variables
%             Cinput = checkPinput(Xmio,Psamples);
%             Nsamples = length(Cinput{1});
%             Poutput = zeros(Nsamples,length(Xmio.Coutputnames)); 
%             % Define execution script
%             Sexec='[';
%             for iout=1:length(Xmio.Coutputnames)-1
%                 Sexec=[Sexec 'Poutput(:,' num2str(iout) '), ']; %#ok<AGROW>
%             end
%             Sexec=[Sexec 'Poutput(:,' num2str(length(Xmio.Coutputnames)) ...
%                   ')]=feval(Xmio.FunctionHandle, Cinput{:});'];
%             
%             % Evaluate Mio
%             eval(Sexec);
% 
%         end
    else    %in case of script
        Poutput=runScript(Xmio,Psamples);
    end
    
end

XsimOut = Xmio.createSimulationData(Poutput);

if ~exist('Poutput','var')
    Poutput=[];
end
