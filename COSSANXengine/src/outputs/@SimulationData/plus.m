function XSimOut = plus(XSimOut1,XSimOut2)
%PLUS adds one SimulationData object to the other
%
%
%  Usage: PLUS(XSimOut1,XSimOut2) adds the values of the Output object XSimOut2
%  to the  valus of the Output object XSimOut1
%  Example:  plus(XSimOut1,XSimOut2)
%
% See Also: https://cossan.co.uk/wiki/index.php/plus@SimulationData
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

Vindex = isfield(XSimOut1.Tvalues,XSimOut2.Cnames);
if ~all(Vindex)==1
    error('openCOSSAN:SimulationData:minus',...
        'the two objects do not contain the same output variables');
end

if XSimOut1.Nsamples ~= XSimOut2.Nsamples
    error('openCOSSAN:SimulationData:minus',...
        'the two objects do not contain the same number of simulations');
end


for i=1:length(XSimOut1.Cnames)
    for isim = 1:XSimOut1.Nsamples
     Tvalues(isim).(XSimOut1.Cnames{i}) = ...
        XSimOut1.Tvalues(isim).(XSimOut1.Cnames{i}) + XSimOut2.Tvalues(isim).(XSimOut1.Cnames{i});
    end
end
        
XSimOut = SimulationData('Tvalues',Tvalues);
end

