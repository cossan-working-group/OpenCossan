function inject(Xc,Tinput)
%INJECT This method injects the input values into INPUT ASCII FILE
%
%   This method requires ad a input a Structure of Input
%   "injector"
%
%
%   EXAMPLE:  inject(Xc,Tinput)
%
%   See Also: http://cossan.co.uk/wiki/index.php/inject@Connector
%
% $Copyright~1993-2014,~COSSAN~Working~Group,~University~of~Liverpool,~UK$
% $Author: Edoardo Patelli and Matteo Broggi$

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
import opencossan.OpenCossan
%% Check input
if ~isa(Tinput,'struct')
    error('openCOSSAN:connector:inject', ...
        'The second argument MUST BE an Tinput structure');
end

%% Update input files
if ~any(Xc.Linjectors)
    OpenCossan.cossanDisp('[COSSAN-X.Connector.inject] No injector defined',2)    
    return
end

OpenCossan.cossanDisp(['[COSSAN-X.Connector.inject] ' num2str(sum(Xc.Linjectors)) ' injector(s) present into the connector'],2);

for iinj=find(Xc.Linjectors)
    OpenCossan.cossanDisp(['[COSSAN-X.Connector.inject] Current working directory:' pwd],3)
    OpenCossan.cossanDisp(['[COSSAN-X.Connector.inject] Injecting values in the file: '...
        Xc.CXmembers{iinj}.Srelativepath Xc.CXmembers{iinj}.Sfile ],3)
    
    % set the injector working directory to the same of connector
    Xc.CXmembers{iinj}.Sworkingdirectory = Xc.SfolderTimeStamp;
    inject(Xc.CXmembers{iinj},Tinput);
end

OpenCossan.cossanDisp(['[COSSAN-X.Connector.inject] method: -END -' datestr(now) ],3)


