function [Lstatus, vargout]=test(Xconnector)
% This function test the connector Xconnector and report the
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
Lstatus=true;

Sdiagnostic{1}=['Connector diagnostic tool for the object ' inputname(1) ];
OpenCossan.cossanDisp(Sdiagnostic,1);

% testing working directory
Sdiagnostic{end+1}=['Testing the working directory: ' Xconnector.Sworkingdirectory];
OpenCossan.cossanDisp(Sdiagnostic{end},1);

if not(exist(Xconnector.Sworkingdirectory,'dir')),
    Sdiagnostic{end+1}=' F A I L E D';
    Lstatus=false;
else
    Sdiagnostic{end+1}=' P A S S E D';
end
OpenCossan.cossanDisp(Sdiagnostic{end},1)

% testing path and executable file
Sdiagnostic{end+1}=['Testing the executable file:  ' Xconnector.Ssolverbinary];
OpenCossan.cossanDisp(Sdiagnostic{end},1);

if not(exist([Xconnector.Ssolverbinary],'file')),
    Sdiagnostic{end+1}=' F A I L E D';
    Lstatus=false;
else
    Sdiagnostic{end+1}=' P A S S E D';
end
OpenCossan.cossanDisp(Sdiagnostic{end},1)


%% Test Injectors
OpenCossan.cossanDisp('******** INJECTORS ********',1);
if ~any(Xconnector.Linjectors)
    Sdiagnostic{end+1}=' No injector defined';
    OpenCossan.cossanDisp(Sdiagnostic{end},1)
else
    for ii=find(Xconnector.Linjectors)
        Sdiagnostic{end+1}=fullfile(Xconnector.CXmembers{ii}.Sscanfilepath,Xconnector.CXmembers{ii}.Sscanfilename); %#ok<AGROW>
        OpenCossan.cossanDisp(Sdiagnostic{end},1);
        % Testing injector
        if not(exist(Sdiagnostic{end},'file')),
            Sdiagnostic{end+1}=' F A I L E D'; %#ok<AGROW>
            Lstatus=false;
        else
            Sdiagnostic{end+1}=' P A S S E D'; %#ok<AGROW>
        end
        OpenCossan.cossanDisp(Sdiagnostic{end},1)
    end
end
%% Test Extractors
OpenCossan.cossanDisp('******** EXTRACTORS ********',1);
if ~any(Xconnector.Lextractors)
    Sdiagnostic{end+1}=' No extractor defined';
    OpenCossan.cossanDisp(Sdiagnostic{end},1)
else
    for ie=find(Xconnector.Lextractors)
        Sdiagnostic{end+1}=fullfile(Xconnector.CXmembers{ii}.Sscanfilepath,Xconnector.CXmembers{ii}.Sscanfilename); %#ok<AGROW>
        OpenCossan.cossanDisp(Sdiagnostic{end},1);
        % Testing Extractor
        if not(exist(Sdiagnostic{end},'file')),
            Sdiagnostic{end+1}=' F A I L E D'; %#ok<AGROW>
            Lstatus=false;
        else
            Sdiagnostic{end+1}=' P A S S E D'; %#ok<AGROW>
        end
        OpenCossan.cossanDisp(Sdiagnostic{end},1)
    end
end
%% Output
if nargout > 1
    vargout{2}=Sdiagnostic;
end