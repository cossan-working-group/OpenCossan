function [Lcheck, Xrv] = addrv(Cmembers)
%ADDRV
% This is a private function for the rvset class
% Add the RVs present in the workspace to the rvset

%  See Also: http://cossan.cfd.liv.ac.uk/wiki/index.php/@RandomVariable
%
% $Copyright~1993-2013,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% Author: Edoardo Patelli and Pierre Beaurepiere
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

%% 1. Processing Inputs

Tv=evalin('base', 'whos'); % read the content of the basic workspace

Crv=cell(length(Cmembers),1);
ifound=0;

for ick=1:length(Tv)
    if strcmp(Tv(ick).class,'RandomVariable') || strcmp(Tv(ick).class,'UserDefRandomVariable')
        Nrv=sum((strcmp(Cmembers,Tv(ick).name)));
        if Nrv>0
            for irv=1:Nrv
                Crv{ifound+Nrv}=Tv(ick).name;
            end
            ifound=ifound+Nrv;
        end
    end
end

if ifound==length(Cmembers)
    Lcheck=true;
    for im=1:length(Cmembers)
        Xrv{im}=evalin('base',Cmembers{im}); %#ok<AGROW>
    end
else
    Lcheck=false;
    Xrv = [];
end
